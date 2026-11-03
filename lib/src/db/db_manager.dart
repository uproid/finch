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
    try {
      await Future.wait([
        if (config.dbConfig.enable)
          mongodb.connect().then((conn) => connections.add(conn)),
        if (config.mysqlConfig.enable)
          mysql.connect().then((conn) => connections.add(conn)),
        if (config.sqliteConfig.enable)
          sqlite.connect().then((conn) => connections.add(conn)),
      ]).then((_) => isConnected = true);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> closeAll() async {
    await Future.wait(connections.map((conn) => conn.close()));
    connections.clear();
    isConnected = false;
  }

  Future<void>? _reconnecting;

  /// Reports an error caught elsewhere (typically the app's global request
  /// error handler) so a dropped database connection can heal itself.
  ///
  /// Nothing is checked on a timer and nothing is checked per-request: this
  /// only runs from the (rare) error path, and even then it only does real
  /// work for connections that are actually down ([DBConnection.isConnected]
  /// is false) — any other error (validation, a bad query, business logic,
  /// ...) just logs and returns immediately, costing nothing.
  ///
  /// [error] isn't pattern-matched against driver-specific exception text on
  /// purpose: every mongo_dart/mysql/sqlite driver phrases a dropped
  /// connection differently (`No master connection`, `No Primary found`,
  /// `Connection closed`, ...) and keeping a list of those strings in sync
  /// is exactly the kind of brittle, driver-specific code this is meant to
  /// avoid. [DBConnection.isConnected] is the one signal every driver
  /// already exposes reliably, so that's what gates the reconnect; `error`
  /// is kept only for logging context.
  ///
  /// If several callers report a drop at once, they share a single
  /// reconnect attempt instead of racing one another.
  Future<void> recoverFromError(Object error) {
    final down = connections.where((conn) => !conn.isConnected).toList();
    if (down.isEmpty) {
      return Future.value();
    }

    return _reconnecting ??= Future(() async {
      for (var conn in down) {
        try {
          Console.w('$conn connection lost ($error), reconnecting...');
          await conn.reconnect();
          Console.i('$conn reconnected.');
        } catch (e) {
          Console.e('Failed to reconnect $conn: $e');
        }
      }
    }).whenComplete(() => _reconnecting = null);
  }

  MongodbConn? _mongodb;
  MySqlConn? _mysql;
  SqliteConn? _sqlite;

  MongodbConn get mongodb => _mongodb ??= MongodbConn(config.dbConfig);
  MySqlConn get mysql => _mysql ??= MySqlConn(config.mysqlConfig);
  SqliteConn get sqlite => _sqlite ??= SqliteConn(config.sqliteConfig);
}

typedef SessionCallBack<R> = Future<void> Function(R data);

abstract class DBConnection<T> {
  Future<DBConnection<T>> connect();
  Future<DBConnection<T>> close();
  T get db;
  bool get isConnected;
  Future<void> session(SessionCallBack sessionEvent);

  /// Re-establishes the connection after it was dropped on its own.
  ///
  /// The default implementation just closes and reconnects, which is enough
  /// for connections that are always fetched fresh (e.g. through a getter).
  /// Override it when callers may keep a long-lived reference to [db]
  /// itself (as [MongodbConn] does), so that reference keeps working after
  /// a reconnect instead of pointing at a dead, replaced object.
  Future<DBConnection<T>> reconnect() async {
    try {
      await close();
    } catch (_) {
      // Ignore errors while closing an already broken connection.
    }
    return connect();
  }

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
        throw ErrorMongoDBConnection(err.toString());
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

  /// Reconnects by closing and re-opening the *same* [Db] instance, instead
  /// of creating a new one (unlike the default [DBConnection.reconnect]).
  ///
  /// Many places in a Finch app (e.g. [DBCollectionFree]) keep a direct,
  /// long-lived reference to the [Db] object returned by [FinchApp.mongoDb]
  /// at startup. Replacing [_db] with a brand new instance would leave those
  /// references pointing at a dead connection forever, so we keep the
  /// identity of the object stable and only re-open its underlying socket.
  @override
  Future<DBConnection<Db>> reconnect() async {
    if (_db == null) {
      return connect();
    }
    try {
      await _db!.close();
    } catch (_) {
      // Ignore errors while closing an already broken connection.
    }
    await _db!.open().onError((err, stack) {
      throw ErrorMongoDBConnection(err.toString());
    });
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
      try {
        _db = MySQLConnectionPool(
          host: config.host,
          port: config.port,
          userName: config.user,
          password: config.pass,
          databaseName: config.databaseName,
          maxConnections: config.maxConnections,
        );
      } catch (e) {
        throw ErrorMySqlConnect(e.toString());
      }
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
      try {
        _db = sqlite3.open(config.filePath);
      } catch (e) {
        throw ErrorSQLiteConnect(e.toString());
      }
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

class ErrorDBManagement implements Exception {
  final String message;
  ErrorDBManagement([this.message = "Error DB Management"]);

  @override
  String toString() => message;
}

class ErrorMongoDBConnection extends ErrorDBManagement {
  ErrorMongoDBConnection([super.message]);
}

class ErrorSQLiteConnect extends ErrorDBManagement {
  ErrorSQLiteConnect([super.message]);
}

class ErrorMySqlConnect extends ErrorDBManagement {
  ErrorMySqlConnect([super.message]);
}
