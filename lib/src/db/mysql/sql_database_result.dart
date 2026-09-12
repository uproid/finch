import 'package:finch/finch_tools.dart';
import 'package:mysql_client_plus/mysql_client_plus.dart' as mysql;
import 'package:mysql_client_plus/mysql_protocol.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:finch/src/tools/convertor/string_validator.dart';
import 'package:finch/finch_mysql.dart';
import 'package:finch/finch_sqlite.dart';

abstract class SqlDatabaseResult<T, R, S> {
  final int countSqlStatements;
  static const String countRecordsField = 'count_records';
  T database;
  final R resultSet;
  String errorMsg;
  SqlDatabaseResult({
    required this.database,
    required this.resultSet,
    this.errorMsg = '',
    this.countSqlStatements = 1,
  });
  bool get success;
  bool get error;
  List<S> get rows;
  int get affectedRows;
  int get insertId;
  int get numFields;
  int get numRows;
  List<Map<String, dynamic>> get assoc;
  Map<String, dynamic>? get assocFirst;
  int get countRecords;

  Future<List<Map<String, Object?>>> assocBy(DataAssoc dataAssoc);
}

class DatabaseDriver<T> {
  final T database;

  DatabaseDriver(this.database);
  Future<SqlDatabaseResult> execute(Sqler sqler) async {
    if (database is Database) {
      return _executeSqlite(database as Database, sqler);
    } else if (database is mysql.MySQLConnectionPool) {
      return _executeMysql(database as mysql.MySQLConnectionPool, sqler);
    } else {
      throw UnsupportedError(
          'Unsupported database type: ${database.runtimeType}');
    }
  }

  Future<SqlDatabaseResult> executeString(
    String sql, {
    bool separateStatements = false,
  }) async {
    if (database is Database) {
      return _executeSqliteString(database as Database, sql,
          separateStatements: separateStatements);
    } else if (database is mysql.MySQLConnectionPool) {
      return _executeMysqlString(
        database as mysql.MySQLConnectionPool,
        sql,
        separateStatements: separateStatements,
      );
    } else {
      throw UnsupportedError(
          'Unsupported database type: ${database.runtimeType}');
    }
  }

  Future<bool> existTable(String name) async {
    if (database is Database) {
      return _existsSqliteTable(database as Database, name);
    } else if (database is mysql.MySQLConnectionPool) {
      return _existsTableMysql(database as mysql.MySQLConnectionPool, name);
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
    mysql.MySQLConnectionPool conn,
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
    String sql, {
    bool separateStatements = false,
  }) {
    try {
      if (separateStatements) {
        var arrSql = splitSqlStatements(sql);
        for (var statement in arrSql) {
          conn.execute(statement);
        }
        return SqliteResult(
          conn,
          ResultSet([], [], []),
          countSqlStatements: arrSql.length,
        );
      } else {
        var resultSet = conn.select(sql);
        return SqliteResult(conn, resultSet);
      }
    } catch (e) {
      return SqliteResult(
        conn,
        ResultSet([], [], []),
        errorMsg: e.toString(),
      );
    }
  }

  Future<MySqlResult> _executeMysqlString(
    mysql.MySQLConnectionPool conn,
    String sql, {
    bool separateStatements = false,
  }) async {
    sql = sql.trim();
    try {
      if (separateStatements) {
        var arrSql = splitSqlStatements(sql);
        for (var statement in arrSql) {
          await conn.execute(statement);
        }
        return MySqlResult(
          resultSet: mysql.EmptyResultSet(
              okPacket: MySQLPacketOK(
            header: 0,
            affectedRows: BigInt.zero,
            lastInsertID: BigInt.zero,
          )),
          database: conn,
          countSqlStatements: arrSql.length,
        );
      } else {
        var resultSet = await conn.execute(sql);

        // Check was successful
        if (resultSet is mysql.EmptyResultSet) {}
        return MySqlResult(
          resultSet: resultSet,
          database: conn,
        );
      }
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

  /// Robust SQL splitter (fixed dollar-quote detection).
  static List<String> splitSqlStatements(String sql) {
    final List<String> out = [];
    final int n = sql.length;
    if (n == 0) return out;

    String delimiter = ';';
    int start = 0;

    bool inSingle = false;
    bool inDouble = false;
    bool inBacktick = false;
    bool inLineComment = false;
    bool inBlockComment = false;
    bool escape = false;

    String? dollarTag; // e.g. $abc$
    bool atLineStart = true;

    String? readDelimiterAt(int pos) {
      const keyword = 'DELIMITER';
      if (pos + keyword.length > n) return null;
      final part = sql.substring(pos, pos + keyword.length);
      if (part.toUpperCase() != keyword) return null;
      int q = pos + keyword.length;
      if (q < n &&
          sql[q] != ' ' &&
          sql[q] != '\t' &&
          sql[q] != '\r' &&
          sql[q] != '\n') {
        return null;
      }
      while (q < n && (sql[q] == ' ' || sql[q] == '\t')) {
        q++;
      }
      int r = q;
      while (r < n && sql[r] != '\n' && sql[r] != '\r') {
        r++;
      }
      final newDelim = sql.substring(q, r).trim();
      return newDelim.isEmpty ? null : newDelim;
    }

    bool isTagChar(String ch) {
      // letters, digits, underscore
      final code = ch.codeUnitAt(0);
      return (code >= 48 && code <= 57) || // 0-9
          (code >= 65 && code <= 90) || // A-Z
          (code >= 97 && code <= 122) || // a-z
          (code == 95); // _
    }

    int i = 0;
    while (i < n) {
      final ch = sql[i];
      final next = (i + 1 < n) ? sql[i + 1] : null;

      if (inLineComment) {
        if (ch == '\n' || ch == '\r') {
          inLineComment = false;
          atLineStart = true;
        }
        i++;
        continue;
      }

      if (inBlockComment) {
        if (ch == '*' && next == '/') {
          inBlockComment = false;
          i += 2;
          atLineStart = false;
          continue;
        }
        if (ch == '\n' || ch == '\r') {
          atLineStart = true;
        } else if (ch != ' ' && ch != '\t') {
          atLineStart = false;
        }
        i++;
        continue;
      }

      if (escape) {
        escape = false;
        atLineStart = false;
        i++;
        continue;
      }

      if (atLineStart) {
        int j = i;
        while (j < n && (sql[j] == ' ' || sql[j] == '\t')) {
          j++;
        }
        final newDelim = readDelimiterAt(j);
        if (newDelim != null) {
          int k = j;
          while (k < n && sql[k] != '\n' && sql[k] != '\r') {
            k++;
          }
          i = k + 1;
          start = i;
          delimiter = newDelim;
          atLineStart = true;
          continue;
        }
      }

      if (!inSingle && !inDouble && !inBacktick) {
        if (ch == '-' && next == '-') {
          inLineComment = true;
          i += 2;
          continue;
        }
        if (ch == '#') {
          inLineComment = true;
          i++;
          continue;
        }
        if (ch == '/' && next == '*') {
          inBlockComment = true;
          i += 2;
          continue;
        }
      }

      // dollar-quoted string detection (fixed)
      if (!inSingle && !inDouble && !inBacktick && ch == r'$') {
        int k = i + 1;
        // read tag name characters (letters/digits/underscore), if any
        while (k < n && isTagChar(sql[k])) {
          k++;
        }
        if (k < n && sql[k] == r'$') {
          // we have a tag like $tag$
          final tag = sql.substring(i, k + 1);
          // if not currently in a dollar-quote, open it; if already opened it would be closed by matching later
          if (dollarTag == null) {
            dollarTag = tag;
            i = k + 1;
            atLineStart = false;
            continue;
          }
        }
      }

      if (dollarTag != null) {
        final tagLen = dollarTag.length;
        if (i + tagLen <= n && sql.substring(i, i + tagLen) == dollarTag) {
          dollarTag = null;
          i += tagLen;
          atLineStart = false;
          continue;
        } else {
          if (ch == '\n' || ch == '\r') {
            atLineStart = true;
          } else if (ch != ' ' && ch != '\t') {
            atLineStart = false;
          }
          i++;
          continue;
        }
      }

      if (!inDouble && !inBacktick && ch == "'") {
        if (inSingle) {
          if (next == "'") {
            i += 2;
            atLineStart = false;
            continue;
          } else {
            inSingle = false;
            i++;
            atLineStart = false;
            continue;
          }
        } else {
          inSingle = true;
          i++;
          atLineStart = false;
          continue;
        }
      }

      if (!inSingle && !inBacktick && ch == '"') {
        if (inDouble) {
          if (next == '"') {
            i += 2;
            atLineStart = false;
            continue;
          } else {
            inDouble = false;
            i++;
            atLineStart = false;
            continue;
          }
        } else {
          inDouble = true;
          i++;
          atLineStart = false;
          continue;
        }
      }

      if (!inSingle && !inDouble && ch == '`') {
        inBacktick = !inBacktick;
        i++;
        atLineStart = false;
        continue;
      }

      if ((inSingle || inDouble) && ch == r'\') {
        escape = true;
        i++;
        atLineStart = false;
        continue;
      }

      if (ch == '\n' || ch == '\r') {
        atLineStart = true;
      } else if (ch != ' ' && ch != '\t') {
        atLineStart = false;
      }

      if (!inSingle &&
          !inDouble &&
          !inBacktick &&
          !inLineComment &&
          !inBlockComment &&
          dollarTag == null) {
        final dlen = delimiter.length;
        if (dlen > 0 && i + dlen <= n) {
          if (sql.substring(i, i + dlen) == delimiter) {
            final stmt = sql.substring(start, i).trim();
            if (stmt.isNotEmpty) out.add(stmt);
            i = i + dlen;
            start = i;
            atLineStart = true;
            continue;
          }
        }
      }

      i++;
    }

    if (start < n) {
      final tail = sql.substring(start).trim();
      if (tail.isNotEmpty) out.add(tail);
    }

    return out;
  }

  Future<bool> _existsTableMysql(
    mysql.MySQLConnectionPool conn,
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
    var count =
        (result.rows.first.colByName('count')?.toString() ?? '0').toInt(def: 0);
    return count > 0;
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
    } else if (database is mysql.MySQLConnectionPool) {
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
    } else if (database is mysql.MySQLConnectionPool) {
      var db = database as mysql.MySQLConnectionPool;
      return db.allConnectionsQty > 0;
    } else {
      throw UnsupportedError(
        'Unsupported database type: ${database.runtimeType}',
      );
    }
  }
}
