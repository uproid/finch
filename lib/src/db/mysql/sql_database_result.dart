import 'package:mysql_client/mysql_client.dart' as mysql;
import 'package:mysql_client/mysql_protocol.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:finch/src/tools/convertor/string_validator.dart';
import 'package:finch/finch_mysql.dart';
import 'package:finch/finch_sqlite.dart';

abstract class SqlDatabaseResult<T, R, S> {
  static const String countRecordsField = 'count_records';
  T database;
  final R resultSet;
  String errorMsg;
  SqlDatabaseResult({
    required this.database,
    required this.resultSet,
    this.errorMsg = '',
  });
  bool get success;
  bool get error;
  List<S> get rows;
  int get affectedRows;
  int get insertId;
  int get numFields;
  int get numRows;
  List<Map<String, String?>> get assoc;
  Map<String, String?>? get assocFirst;
  int get countRecords;

  Future<List<Map<String, Object?>>> assocBy(DataAssoc dataAssoc);
}

class DatabaseDriver<T> {
  final T database;

  DatabaseDriver(this.database);
  Future<SqlDatabaseResult> execute(Sqler sqler) async {
    if (database is Database) {
      return _executeSqlite(database as Database, sqler);
    } else if (database is mysql.MySQLConnection) {
      return _executeMysql(database as mysql.MySQLConnection, sqler);
    } else {
      throw UnsupportedError(
          'Unsupported database type: ${database.runtimeType}');
    }
  }

  Future<SqlDatabaseResult> executeString(String sql) async {
    if (database is Database) {
      return _executeSqliteString(database as Database, sql);
    } else if (database is mysql.MySQLConnection) {
      return _executeMysqlString(database as mysql.MySQLConnection, sql);
    } else {
      throw UnsupportedError(
          'Unsupported database type: ${database.runtimeType}');
    }
  }

  Future<bool> existTable(String name) async {
    if (database is Database) {
      return _existsSqliteTable(database as Database, name);
    } else if (database is mysql.MySQLConnection) {
      return _existsTableMysql(database as mysql.MySQLConnection, name);
    } else {
      throw UnsupportedError(
          'Unsupported database type: ${database.runtimeType}');
    }
  }

  Future<SqliteResult> _executeSqlite(
    Database conn,
    Sqler sqler,
  ) async {
    try {
      var resultSet = conn.select(sqler.toSQL<Sqlite>());
      return SqliteResult(conn, resultSet);
    } catch (e) {
      return SqliteResult(
        conn,
        ResultSet([], [], []),
        errorMsg: e.toString(),
      );
    }
  }

  Future<MySqlResult> _executeMysql(
    mysql.MySQLConnection conn,
    Sqler sqler,
  ) async {
    try {
      var resultSet = await conn.execute(sqler.toSQL<Mysql>());
      return MySqlResult(
        resultSet: resultSet,
        database: conn,
      );
    } catch (e) {
      return MySqlResult(
        database: conn,
        resultSet: mysql.EmptyResultSet(
            okPacket: MySQLPacketOK(
          header: 0,
          affectedRows: BigInt.zero,
          lastInsertID: BigInt.zero,
        )),
        errorMsg: e.toString(),
      );
    }
  }

  SqliteResult _executeSqliteString(
    Database conn,
    String sql,
  ) {
    try {
      var resultSet = conn.select(sql);
      return SqliteResult(conn, resultSet);
    } catch (e) {
      return SqliteResult(
        conn,
        ResultSet([], [], []),
        errorMsg: e.toString(),
      );
    }
  }

  Future<MySqlResult> _executeMysqlString(
    mysql.MySQLConnection conn,
    String sql,
  ) async {
    try {
      var resultSet = await conn.execute(sql);
      return MySqlResult(
        resultSet: resultSet,
        database: conn,
      );
    } catch (e) {
      return MySqlResult(
        database: conn,
        resultSet: mysql.EmptyResultSet(
            okPacket: MySQLPacketOK(
          header: 0,
          affectedRows: BigInt.zero,
          lastInsertID: BigInt.zero,
        )),
        errorMsg: e.toString(),
      );
    }
  }

  Future<bool> _existsTableMysql(
    mysql.MySQLConnection conn,
    String name,
  ) async {
    Sqler sqler = Sqler()
      ..from(QField('information_schema.tables'))
      ..selects([
        QSelect('table_name'),
        SQL.count(QField('table_name', as: 'count')),
      ])
      ..where(WhereOne(
        QField('table_name'),
        QO.EQ,
        QVar(name),
      ));
    var result = await _executeMysql(conn, sqler);
    var count = result.rows.first.colByName('count')?.toInt(def: 0);
    return (count ?? 0) > 0;
  }

  Future<bool> _existsSqliteTable(Database conn, String name) async {
    Sqler sqler = Sqler()
      ..from(QField('sqlite_master'))
      ..selects([
        QSelect('name'),
        SQL.count<Sqlite>(QField('name', as: 'count')),
      ])
      ..whereAnd([
        Condition(QField('name'), QO.EQ, QVar(name)),
        Condition(QField('type'), QO.EQ, QVar('table')),
      ]);
    var result = await _executeSqlite(conn, sqler);
    var count = result.assocFirst?['count']?.toInt(def: 0);
    return (count ?? 0) > 0;
  }

  Future<SqlDatabaseResult> createTable(MTable mTable) async {
    String sql;
    if (database is Database) {
      sql = mTable.toSQL<Sqlite>();
    } else if (database is mysql.MySQLConnection) {
      sql = mTable.toSQL<Mysql>();
    } else {
      throw UnsupportedError(
          'Unsupported database type: ${database.runtimeType}');
    }
    return executeString(sql);
  }

  bool connected() {
    if (database is Database) {
      var row = _executeSqliteString(
        database as Database,
        'SELECT SQLITE_VERSION()',
      );
      return row.rows.isNotEmpty;
    } else if (database is mysql.MySQLConnection) {
      var db = database as mysql.MySQLConnection;
      return db.connected;
    } else {
      throw UnsupportedError(
        'Unsupported database type: ${database.runtimeType}',
      );
    }
  }
}
