import 'dart:io';
import 'package:capp/capp.dart';
import 'package:finch/finch_tools.dart';
import 'package:finch/mysql.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:mysql_client_plus/mysql_client_plus.dart';
import 'package:finch/src/tools/console.dart';
import 'package:finch/finch_app.dart';

/// A class for handling MySQL database migrations.
/// This class provides functionality to create, execute, and rollback
/// database migrations using SQL files stored in a migrations directory.
/// It maintains a migration history table to track which migrations
/// have been executed.
class MysqlMigration {
  /// The MySQL database connection used for executing migrations.
  DatabaseDriver<MySQLConnectionPool> db;

  /// Creates a new [MysqlMigration] instance with the provided database connection.
  /// [db] The MySQL connection to use for migration operations.
  MysqlMigration(this.db);

  /// The migration tracking table structure.
  /// This table keeps track of executed migrations with the following fields:
  /// - `file`: The name of the migration SQL file (primary key)
  /// - `created_at`: Timestamp when the migration was executed
  /// - `sort`: Sort order for migration execution
  MTable migrationTable = MTable(
    name: 'wa_migration',
    fields: [
      MFieldVarchar(
        name: 'file',
        isNullable: false,
        isPrimaryKey: true,
        comment: 'Name of the migration SQL file',
        length: 255,
      ),
      MFieldTimestamp(
        name: 'created_at',
        isPrimaryKey: false,
        isAutoIncrement: false,
        isNullable: false,
        defaultValue: 'CURRENT_TIMESTAMP',
        comment: 'Time when the record was created',
      ),
      MFieldVarchar(
        name: 'sort',
        isNullable: false,
        defaultValue: '',
        length: 255,
      ),
    ],
  );

  /// Creates the migration tracking table if it doesn't exist.
  /// This is a private method called internally to ensure the migration
  /// table exists before performing any migration operations.
  Future<void> _createTable() async {
    if (!await migrationTable.existsTable(db)) {
      await migrationTable.createTable(db);
      Console.i('\nMigration table created: OK!');
    }
  }

  /// Initializes and executes all pending migrations.
  /// This method:
  /// 1. Creates the migration table if it doesn't exist
  /// 2. Scans the migrations directory for SQL files
  /// 3. Executes any migrations that haven't been run yet
  /// 4. Records executed migrations in the tracking table
  /// Migration files should contain SQL statements followed by an optional
  /// rollback section marked with `-- ## ROLL BACK:`. Only the portion
  /// before the rollback marker is executed during migration.
  /// Returns a success message listing the executed migration files,
  /// or a message indicating no migrations were needed.
  Future<List<String>> migrateInit({
    List<DartMigration> migrations = const [],
  }) async {
    await _createTable();
    var files = await _getMigrationFiles();
    var executedFiles = <String>[];
    if (migrations.isNotEmpty) {
      for (var migration in migrations) {
        var check = await _checkExcutedMigration(migration.uniqueName);
        if (check.exist) continue;

        await db.database.transactional((MySQLConnection dbSession) async {
          await dbSession.execute('START TRANSACTION;');
          try {
            final sqls = migration.upSQLs;
            for (var sql in sqls) {
              var arrSql = DatabaseDriver.splitSqlStatements(sql);
              for (var sql in arrSql) {
                await db.database.execute(sql);
              }
            }
            await dbSession.execute('COMMIT;');
            executedFiles.add(migration.uniqueName);
            await migrationTable.insert(db, {
              'file': QVar(migration.uniqueName),
              'sort': QVar(DateTime.now().millisecondsSinceEpoch.toString()),
            });
          } catch (e) {
            await dbSession.execute('ROLLBACK;');
            throw Exception(
              'Error executing migration: ${migration.uniqueName}\nError message: \n$e',
            );
          }
        });
      }
    } else if (files.isEmpty) {
      throw Exception(
        'No migration files found in the migrations directory.',
      );
    } else {
      for (var file in files) {
        var filename = path.basename(file.path);
        var exists = await _checkExcutedMigration(filename);
        if (exists.exist) continue;
        var sqlContent = await file.readAsString();
        sqlContent = sqlContent.split('-- ## ROLL BACK:')[0];
        if (sqlContent.isEmpty) continue;

        db.database.transactional((sessionDb) async {
          try {
            await sessionDb.execute('START TRANSACTION;');
            var arrSql = DatabaseDriver.splitSqlStatements(sqlContent.trim());
            for (var sql in arrSql) {
              await sessionDb.execute(
                sql.trim(),
              );
            }
            executedFiles.add(filename);
            await migrationTable.insert(db, {
              'file': QVar(filename),
              'sort': QVar(DateTime.now().millisecondsSinceEpoch.toString()),
            });
            await sessionDb.execute('COMMIT;');
          } catch (e) {
            await sessionDb.execute('ROLLBACK;');
            throw Exception(
              'Error executing migration file: $filename\nError message: \n$e',
            );
          }
        });
        await db.executeString('COMMIT;');
      }
    }

    if (executedFiles.isEmpty) {
      return [];
    }
    return executedFiles;
  }

  /// Rolls back the most recent migrations.
  /// This method:
  /// 1. Identifies the most recently executed migrations
  /// 2. Executes the rollback SQL statements for each migration
  /// 3. Removes the migration records from the tracking table
  /// [deep] The number of migrations to roll back (starting from most recent)
  /// Migration files must contain a rollback section marked with
  /// `-- ## ROLL BACK:` followed by the SQL statements to undo the migration.
  /// Returns a success message listing the rolled back migration files.
  Future<List<String>> migrateRollback(
    int deep, {
    List<DartMigration> dartMigrations = const [],
  }) async {
    List<String> successRollbackFiles = [];
    var resMigrations = await migrationTable.select(
      db,
      Sqler()
        ..addSelect(QSelect('file'))
        ..from(QField(migrationTable.name))
        ..orderBy(QOrder('sort', desc: true)),
    );

    var migrations = <String>[];
    for (var row in resMigrations.rows) {
      if (migrations.length >= deep) break;
      var filename = row.colByName('file');
      if (filename == null || filename.isEmpty) continue;
      migrations.add(filename);
    }
    for (var migration in migrations) {
      List<String> rollbackContent = [];
      var filename = migration;
      var rollbackTarget = '';
      if (filename.isEmpty) continue;
      if (dartMigrations.isNotEmpty) {
        for (var dartMigration in dartMigrations.reversed) {
          if (dartMigration.uniqueName == filename) {
            if (dartMigration.uniqueName.isEmpty) continue;
            rollbackTarget = dartMigration.uniqueName;
            rollbackContent.addAll(dartMigration.downSQLs);
            break;
          }
        }
      } else {
        var file = File(path.join(
          pathTo(
            FinchApp.config.pathMigrationMySQL,
          ),
          filename,
        ));
        if (!file.existsSync()) continue;
        var sqlContent = await file.readAsString();
        if (!sqlContent.contains('-- ## ROLL BACK:')) continue;
        rollbackContent.add(sqlContent.split('-- ## ROLL BACK:')[1]);
        rollbackTarget = file.path;
      }
      if (rollbackContent.isEmpty) continue;

      for (var sql in rollbackContent) {
        await db.executeString('START TRANSACTION;');
        try {
          var res = await db.executeString(
            sql,
            separateStatements: true,
          );
          if (res.error) {
            throw res.errorMsg;
          }
          await db.executeString('COMMIT;');
        } catch (e) {
          await db.executeString('ROLLBACK;');
          throw Exception(
            'Error executing rollback for migration: $filename\nError message: $e',
          );
        }
      }

      await migrationTable.delete(
        db,
        Sqler()
          ..delete()
          ..from(QField(migrationTable.name))
          ..where(
            WhereOne(QField('file'), QO.EQ, QParam('file')),
          )
          ..addParam('file', QVar(filename)),
      );
      successRollbackFiles.add(File(rollbackTarget).fileFullName);
    }

    return successRollbackFiles;
  }

  /// Creates a new migration file template.
  /// This method generates a new SQL migration file in the migrations directory
  /// with a timestamp-based filename. The file contains a basic template with
  /// sections for:
  /// - Migration SQL statements (-- ## NEW VERSION:)
  /// - Rollback SQL statements (-- ## ROLL BACK:)
  /// The filename format is: `{timestamp}_migration.sql`
  /// Returns a success message with the path of the created file.
  static Future<String> migrateCreate({
    String name = '',
    String? migrationPath,
    bool isSqlite = false,
    String type = 'sql',
  }) async {
    File file = File(
      path.join(
        migrationPath ?? pathTo(FinchApp.config.pathMigrationMySQL),
        'z${DateTime.now().millisecondsSinceEpoch}_'
        '${name.isNotEmpty ? '${name.toSlug().replaceAll('-', '_')}_' : ''}'
        'migration.$type',
      ),
    );

    file.createSync(recursive: true);
    file.writeAsString(
      _getMigrationTemplate(
        name: name,
        isSqlite: isSqlite,
        type: type,
      ),
    );
    CappConsole.write("\n");
    CappConsole.writeTable(
      [
        ['Migration file created at:'],
        [file.path],
      ],
      dubleBorder: true,
      color: CappColors.success,
    );
    return 'Create migration file command executed successfully.\n'
        'Register this migration file in your FinchApp '
        'instance using the registerDartMigration method.';
  }

  /// Checks if a migration file has already been executed.
  /// [filename] The name of the migration file to check
  /// Returns `true` if the migration has been executed, `false` otherwise.
  Future<({bool exist, String createdAt})> _checkExcutedMigration(
    String filename,
  ) async {
    var query = Sqler()
      ..from(migrationTable.qName)
      ..addSelect(QSelectAll())
      ..where(
        WhereOne(QField('file'), QO.EQ, QParam('file')),
      )
      ..addParam('file', QVar(filename));
    var res = await migrationTable.select(db, query);
    var exist = res.numRows > 0;
    var createdAt = res.assocFirst?['created_at']?.toString() ?? '';
    return (exist: exist, createdAt: createdAt);
  }

  /// Retrieves all migration files from the migrations directory.
  /// This method:
  /// 1. Scans the `./migrations` directory for files
  /// 2. Filters for files with `.sql` extension
  /// 3. Sorts them alphabetically by filename
  /// The alphabetical sorting ensures migrations are executed in the correct
  /// order based on their timestamp prefixes.
  /// Returns a list of [File] objects representing the migration files.
  /// Returns an empty list if the migrations directory doesn't exist.
  Future<List<File>> _getMigrationFiles() async {
    // Get all migration files from the migrations directory
    var dir = Directory(pathTo(FinchApp.config.pathMigrationMySQL));
    if (!dir.existsSync()) {
      return [];
    }
    var files = dir.listSync().whereType<File>().toList();
    var res = <File>[];
    for (var file in files) {
      if (file.path.endsWith('.sql')) {
        res.add(file);
      }
    }
    res.sort((a, b) => a.path.compareTo(b.path));
    return res;
  }

  Future<List<List<String>>> checkMigrationStatus({
    List<DartMigration> migrations = const [],
  }) async {
    var statusList = <List<String>>[];
    if (migrations.isNotEmpty) {
      var index = 1;
      for (var migration in migrations) {
        var executed = await _checkExcutedMigration(migration.uniqueName);
        statusList.add([
          "${index++}",
          migration.uniqueName,
          executed.exist ? 'Yes' : 'No',
          executed.createdAt.isNotEmpty
              ? DateFormat('yyyy-MM-dd HH:mm:ss').format(
                  DateTime.parse(executed.createdAt),
                )
              : '',
        ]);
      }
    } else {
      var migrationFiles = await _getMigrationFiles();
      var index = 1;
      for (var file in migrationFiles) {
        var fileName = path.basename(file.path);
        var executed = await _checkExcutedMigration(fileName);
        statusList.add([
          "${index++}",
          fileName,
          executed.exist ? 'Yes' : 'No',
          DateFormat('yyyy-MM-dd HH:mm:ss').format(file.statSync().modified),
        ]);
      }
    }
    return statusList;
  }

  static String _getMigrationTemplate({
    required String name,
    bool isSqlite = false,
    String type = 'sql',
  }) {
    if (type.trim() != 'dart') {
      return '-- ${DateTime.now()} \n'
          '-- ${isSqlite ? 'SQLite' : 'MySQL'} Migration File \n'
          '${name.isNotEmpty ? '-- Name: $name \n' : ''}'
          '-- ## NEW VERSION:\n\n\n\n'
          '-- ## ROLL BACK:\n\n\n\n';
    } else {
      return '''import 'package:finch/${isSqlite ? 'sqlite' : 'mysql'}.dart';
/// A Dart migration class for ${isSqlite ? 'SQLite' : 'MySQL'} database migrations.
/// Create at: ${DateTime.now()}
/// Name: $name
/// @TODO Important: Create a new instance of this class into registerDartMigration method in your FinchApp instance.
class M${name.toSlug().toPascalCase()} extends DartMigration {
  @override
  MigrationTarget get target => MigrationTarget.${isSqlite ? 'sqlite' : 'mysql'};

  M${name.toSlug().toPascalCase()}() : super('migrate_${name.toSlug()}_${DateTime.now().millisecondsSinceEpoch}');

  @override
  void up() {
    /// @TODO: Add your migration SQL statements here
    addSql('');
  }

  @override
  void down() {
    /// @TODO: Add your migration rollback SQL statements here
    addSql('');
  }
}
''';
    }
  }
}
