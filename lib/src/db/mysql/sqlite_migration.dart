import 'dart:io';
import 'package:finch/src/db/dart_migraion.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';
import 'package:finch/src/tools/console.dart';
import 'package:finch/src/tools/path.dart';
import 'package:finch/src/finch_app.dart';
import 'package:finch/finch_mysql.dart';

/// A class for handling SQLite database migrations.
/// This class provides functionality to create, execute, and rollback
/// database migrations using SQL files stored in a migrations directory.
/// It maintains a migration history table to track which migrations
/// have been executed.
class SqliteMigration {
  /// The SQLite database connection used for executing migrations.
  DatabaseDriver<Database> db;

  /// Creates a new [SqliteMigration] instance with the provided database connection.
  /// [db] The SQLite connection to use for migration operations.
  SqliteMigration(this.db);

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
        length: 255,
      ),
      MFieldDateTime(
        name: 'created_at',
        isPrimaryKey: false,
        isAutoIncrement: false,
        isNullable: false,
        defaultValue: 'CURRENT_TIMESTAMP',
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

        try {
          await db.executeString('BEGIN TRANSACTION;');
          final sqls = migration.upSQLs;
          for (var sql in sqls) {
            var res = await db.executeString(sql, separateStatements: true);
            if (res.error) {
              throw res.errorMsg;
            }
          }
          await db.executeString('COMMIT;');
          executedFiles.add(migration.uniqueName);
          await migrationTable.insert(db, {
            'file': QVar(migration.uniqueName),
            'sort': QVar(DateTime.now().millisecondsSinceEpoch.toString()),
          });
        } catch (e) {
          await db.executeString('ROLLBACK;');
          throw Exception(
            'Error executing migration: ${migration.uniqueName}\nError message: $e',
          );
        }
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
        try {
          await db.executeString('BEGIN TRANSACTION;');
          var res = await db.executeString(
            sqlContent,
            separateStatements: true,
          );
          if (res.success) {
            executedFiles.add(filename);
            await migrationTable.insert(db, {
              'file': QVar(filename),
              'sort': QVar(DateTime.now().millisecondsSinceEpoch.toString()),
            });
          } else {
            throw res.errorMsg;
          }
          await db.executeString('COMMIT;');
        } catch (e) {
          await db.executeString('ROLLBACK;');
          throw Exception(
            'Error executing migration file: $filename\nError message: $e',
          );
        }
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
    for (var row in resMigrations.assoc) {
      if (migrations.length >= deep) break;
      var filename = row['file'];
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
            for (var sql in dartMigration.downSQLs) {
              rollbackContent.add(sql.trim());
            }
            break;
          }
        }
      } else {
        var file = File(path.join(
          pathTo(
            FinchApp.config.pathMigrationSQLite,
          ),
          filename,
        ));
        if (!file.existsSync()) continue;
        var sqlContent = await file.readAsString();
        if (!sqlContent.contains('-- ## ROLL BACK:')) continue;
        rollbackContent.add(sqlContent.split('-- ## ROLL BACK:')[1].trim());
        rollbackTarget = file.path;
      }
      if (rollbackContent.isEmpty) continue;
      // trans action rollback
      try {
        await db.executeString('BEGIN TRANSACTION;');
        for (var sql in rollbackContent) {
          var res = await db.executeString(sql, separateStatements: true);
          if (res.error) {
            throw Exception(
              'Error executing rollback for migration: $filename,$rollbackTarget\nError message: ${res.errorMsg}',
            );
          }
        }
        await db.executeString('COMMIT;');
      } catch (e) {
        await db.executeString('ROLLBACK;');
        rethrow;
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
      successRollbackFiles.add(rollbackTarget);
    }

    return successRollbackFiles;
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
  /// 1. Scans the `./migrations_sqlite` directory for files
  /// 2. Filters for files with `.sql` extension
  /// 3. Sorts them alphabetically by filename
  /// The alphabetical sorting ensures migrations are executed in the correct
  /// order based on their timestamp prefixes.
  /// Returns a list of [File] objects representing the migration files.
  /// Returns an empty list if the migrations directory doesn't exist.
  Future<List<File>> _getMigrationFiles() async {
    // Get all migration files from the migrations directory
    var dir = Directory(pathTo(FinchApp.config.pathMigrationSQLite));
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
}
