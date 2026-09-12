import 'dart:async';
import 'package:finch/app.dart';
import 'package:finch/console.dart';
import 'package:finch/finch_mysql.dart';
import 'package:finch/src/finch_mysql_client.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:sqlite3/sqlite3.dart';

class DBManager {
  FinchConfigs config;
  bool isConnected = false;
  final List<DBConnection> connections = [];
  DBManager(this.config);

  Future<void> connectAll() async {
    await Future.wait([
      if (config.dbConfig.enable)
        mongodb.connect().then((conn) => connections.add(conn)),
      if (config.mysqlConfig.enable)
        mysql.connect().then((conn) => connections.add(conn)),
      if (config.sqliteConfig.enable)
        sqlite.connect().then((conn) => connections.add(conn)),
    ]).then((_) => isConnected = true);
  }

  Future<void> closeAll() async {
    await Future.wait(connections.map((conn) => conn.close()));
    connections.clear();
    isConnected = false;
  }

  MongodbConn? _mongodb;
  MySqlConn? _mysql;
  SqliteConn? _sqlite;

  MongodbConn get mongodb => _mongodb ??= MongodbConn(config.dbConfig);
  MySqlConn get mysql => _mysql ??= MySqlConn(config.mysqlConfig);
  SqliteConn get sqlite => _sqlite ??= SqliteConn(config.sqliteConfig);
}

typedef SessionCallBack<R> = Future<void> Function(R data);

abstract interface class DBConnection<T> {
  Future<DBConnection<T>> connect();
  Future<DBConnection<T>> close();
  T get db;
  bool get isConnected;
  Future<void> session(SessionCallBack sessionEvent);
  @override
  String toString() => runtimeType.toString();
}

class MongodbConn extends DBConnection<Db> {
  Db? _db;
  FinchDBConfig config;

  MongodbConn(this.config);

  @override
  Future<DBConnection<Db>> connect() async {
    if (config.enable) {
      _db = Db.pool(List.filled(config.maxConnections, config.link));
      await _db!.open().onError((err, stack) {
        Console.e(err.toString());
      });
    }
    return this;
  }

  @override
  Future<void> session(SessionCallBack<Db> sessionEvent) async {
    await sessionEvent.call(db);
  }

  @override
  Future<DBConnection<Db>> close() async {
    await _db?.close();
    return this;
  }

  @override
  Db get db {
    return _db!;
  }

  @override
  bool get isConnected {
    return _db?.isConnected ?? false;
  }
}

class MySqlConn extends DBConnection<MySQLConnectionPool> {
  FinchMysqlConfig config;
  MySQLConnectionPool? _db;
  MySqlConn(this.config);

  @override
  Future<DBConnection<MySQLConnectionPool>> connect() async {
    if (config.enable) {
      _db = MySQLConnectionPool(
        host: config.host,
        port: config.port,
        userName: config.user,
        password: config.pass,
        databaseName: config.databaseName,
        maxConnections: config.maxConnections,
      );
    }
    return this;
  }

  @override
  Future<DBConnection<MySQLConnectionPool>> close() async {
    await _db?.close();
    return this;
  }

  @override
  MySQLConnectionPool get db {
    return _db!;
  }

  @override
  bool get isConnected {
    return (_db?.allConnectionsQty ?? 0) > 0;
  }

  DatabaseDriver<MySQLConnectionPool> get driver =>
      DatabaseDriver<MySQLConnectionPool>(db);

  @override
  Future<void> session(
      Future<void> Function(MySQLConnection db) sessionEvent) async {
    await db.transactional((sessionDB) {
      sessionEvent.call(sessionDB);
    });
  }
}

class SqliteConn extends DBConnection<Database> {
  FinchSqliteConfig config;
  Database? _db;

  SqliteConn(this.config);

  @override
  Future<DBConnection<Database>> connect() async {
    if (config.enable) {
      _db = sqlite3.open(config.filePath);
    }
    return this;
  }

  @override
  Future<DBConnection<Database>> close() async {
    _db?.close();
    return this;
  }

  @override
  Database get db {
    return _db!;
  }

  @override
  bool get isConnected {
    if (_db == null) return false;
    return _db?.select('SELECT 1') != null;
  }

  @override
  Future<void> session(Future<void> Function(Database db) sessionEvent) async {
    await sessionEvent.call(db);
  }

  DatabaseDriver<Database> get driver => DatabaseDriver<Database>(db);
}
