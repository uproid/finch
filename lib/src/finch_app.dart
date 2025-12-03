import 'dart:async';
import 'dart:io';
import 'package:capp/capp.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:finch/src/db/mysql/mysql_migration.dart';
import 'package:finch/src/db/mysql/sql_database_result.dart';
import 'package:finch/src/db/mysql/sqlite_migration.dart';
import 'package:finch/src/widgets/widget_console.dart';
import 'package:finch/finch_mysql.dart';
import 'package:finch/finch_route.dart';
import 'package:finch/finch_app.dart';
import 'package:finch/src/tools/console.dart';
import 'package:finch/src/tools/multi_language/language.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:finch/finch_tools.dart';

/// A comprehensive web application server framework for Dart.
/// The [FinchApp] class provides a complete HTTP server implementation with
/// built-in support for routing, database connectivity (MongoDB and MySQL),
/// WebSocket management, scheduled tasks (cron jobs), and development tools.
/// Features:
/// - HTTP request/response handling with middleware support
/// - MongoDB and MySQL database integration
/// - WebSocket server capabilities
/// - Cron job scheduling
/// - Multi-language support
/// - Development debugging tools
/// - Migration system for database schema management
/// Example usage:
/// ```dart
/// final config = FinchConfigs(
///   ip: '0.0.0.0',
///   port: 8080,
///   dbConfig: DbConfig(
///     enable: true,
///     link: 'mongodb://localhost:27017/myapp'
///   ),
/// );
/// final server = FinchApp(configs: config);
/// await server.start();
/// ```
class FinchApp {
  /// A list of command-line arguments passed to the server.
  List<String> _args = [];

  /// Provides information about the version of the server.
  static final info = _Info();

  /// The HTTP server instance.
  HttpServer? server;

  /// A function that takes a [Request] and returns a [Future] containing the modified [Request].
  Future<Request> Function(Request rq)? onRequest;

  /// Manages WebSocket connections.
  SocketManager? socketManager;

  /// A boolean indicating if the server has an active WebSocket manager.
  bool get hasSocket => socketManager != null;

  /// The MongoDB database instance.
  mongo.Db? _mongoDb;

  /// The MySQL database connection instance.
  MySQLConnection? _mysqlDb;
  DatabaseDriver<MySQLConnection> get mysqlDriver =>
      DatabaseDriver<MySQLConnection>(mysqlDb);
  DatabaseDriver<Database> get sqliteDriver =>
      DatabaseDriver<Database>(sqliteDb);

  Database? _sqliteDb;

  /// A list of [FinchCron] instances representing scheduled tasks.
  final List<FinchCron> crons = [];

  /// A map of application languages, where the key is the language code and the value is a map of strings.
  static Map<String, Map<String, String>> appLanguages = {};

  /// The server configuration.
  static late FinchConfigs config;

  /// A list of functions that return a [Future] containing a list of [FinchRoute] based on the [Request].
  final List<Future<List<FinchRoute>> Function(Request rq)> _webRoutes = [];

  List<CappController> commands = [];

  /// Creates an instance of [FinchApp] with the specified [FinchConfigs] and an optional [onRequest] function.
  /// The [configs] parameter is required and provides the configuration for the server.
  /// The [onRequest] parameter, if provided, allows customization of the [Request] before handling.
  FinchApp({
    required FinchConfigs configs,
    this.onRequest,
  }) {
    FinchApp.config = configs;
    debuggerInit();
  }

  /// WebSocket-based debugger for local development.
  /// Provides real-time debugging capabilities including route inspection,
  /// memory monitoring, language reloading, and server restart functionality.
  /// Only active when `config.enableLocalDebugger` and `config.isLocalDebug` are true.
  SocketManager? debugger;

  /// Adds a routing function to the server.
  /// The [router] function returns a [Future] containing a list of [FinchRoute] based on the provided [Request].
  /// This allows for dynamic routing based on the request.
  /// Returns the [FinchApp] instance to allow method chaining.
  FinchApp addRouting(Future<List<FinchRoute>> Function(Request rq) router) {
    _webRoutes.add(router);

    return this;
  }

  /// Get routing list of Server
  /// Here you can get all routing of server that added to server
  /// Returns a list of [FinchRoute] instances.
  Future<List<FinchRoute>> getAllRoutes() async {
    List<FinchRoute> routing = [];

    for (var webRoute in _webRoutes) {
      routing.addAll(await webRoute(Context.rq));
    }

    return routing;
  }

  /// Gets the MongoDB database instance.
  /// If the database is not connected, this method will attempt to connect to MongoDB.
  /// Throws an exception if the database is not running.
  mongo.Db get mongoDb {
    if (_mongoDb == null) {
      connectMongoDb().then((value) => _mongoDb = value);
      throw ('Error DB is not running');
    }

    return _mongoDb!;
  }

  MySQLConnection get mysqlDb {
    if (_mysqlDb == null || !_mysqlDb!.connected) {
      connectMysqlDb();
    }
    return _mysqlDb!;
  }

  Database get sqliteDb {
    if (_sqliteDb == null) {
      connectSqliteDb();
    }
    return _sqliteDb!;
  }

  /// Stops the server and closes the database connection.
  /// The [force] parameter specifies whether to forcefully close the server.
  Future stop({bool force = true}) async {
    if (server != null) {
      await server!.close(force: force);
    }

    await mongoDb.close();
    await mysqlDb.close();
    sqliteDb.dispose();

    _mongoDb = null;
    _mysqlDb = null;
    _sqliteDb = null;
    server = null;
  }

  /// Restarts the server by stopping and starting it again.
  /// This method performs a graceful restart by:
  /// 1. Stopping the current server instance with force flag
  /// 2. Waiting for 2 seconds to ensure proper cleanup
  /// 3. Starting the server again with the same configuration
  /// Any errors during the stop process are logged but don't prevent the restart.
  /// This is useful for applying configuration changes or recovering from errors.
  Future<void> restart() async {
    try {
      await stop(force: true);
    } catch (e) {
      Console.e("Error on stop server: $e");
    }
    await Future.delayed(Duration(seconds: 2));
    await start();
  }

  /// Starts the server and binds it to the specified IP and port.
  /// If `config.noStop` is true, the server will run within a guarded zone to handle errors.
  /// Otherwise, it runs normally.
  /// Returns a [Future] containing the [HttpServer] instance.
  /// If [awaitCommands] is true, it will also handle command-line inputs.
  Future<HttpServer> start([List<String>? args, bool awaitCommands = true]) {
    _args = args ?? [];
    if (config.noStop) {
      return runZonedGuarded(
        () => _run(args, awaitCommands: awaitCommands),
        (error, stack) {
          Console.e({
            'error': error,
            'stack': stack.toString().split("#"),
          });
        },
      )!;
    } else {
      return _run(args);
    }
  }

  /// Initializes and starts the HTTP server, sets up the database connection, and handles requests.
  /// This method is called internally by [start]. It waits for the database to load and sets up request handling.
  /// Returns a [Future] containing the [HttpServer] instance.
  Future<HttpServer> _run(
    List<String>? args, {
    bool awaitCommands = true,
  }) async {
    appLanguages = await MultiLanguage(
      languagePath: config.languagePath,
      source: config.languageSource,
      dartLanguages: config.dartLanguages,
    ).init();

    _mongoDb = await connectMongoDb().onError((_, __) {
      throw ("Error connect to MongoDB");
    });

    await connectMysqlDb();

    server = await HttpServer.bind(
      config.ip,
      config.port,
    );

    server!.address;

    Console.p({
      'url': config.uri,
      'path': pathApp,
      'DB': {
        'path db': config.dbPath,
      }
    });

    await handleRequests(server!);
    if (awaitCommands) {
      await handleCommands(server!);
    }
    return server!;
  }

  /// Handles incoming HTTP requests by processing them through routing functions and the [onRequest] function.
  /// If `config.dbConfig.enable` is true, this method ensures the MongoDB database is connected before handling requests.
  /// The request is processed in a guarded zone to catch and log errors, and an error response is sent if needed.
  Future<void> handleRequests(HttpServer server) async {
    server.forEach((HttpRequest httpRequest) async {
      if (config.fakeDelay != 0) {
        await Future.delayed(Duration(seconds: config.fakeDelay)).then(
          (value) => Console.i("Server has fake delay"),
        );
      }

      Request(httpRequest).init().then((Request rq) {
        Context.run(rq, () async {
          var router = Route(routing: await getAllRoutes());

          runZonedGuarded(() async {
            if (config.dbConfig.enable) {
              if (_mongoDb == null) {
                _mongoDb =
                    await connectMongoDb().onError((error, stackTrace) async {
                  throw ("Error connect to DB");
                });
              } else if (!_mongoDb!.isConnected) {
                await _mongoDb!.open().onError((error, stackTrace) async {
                  throw ("Error connect to DB");
                });
              }
            }

            if (onRequest != null) {
              rq = await onRequest!(rq);
            }

            router.handle();
          }, (error, StackTrace stack) async {
            Console.e({
              'error': error,
              'stack': stack.toString().split("#"),
            });

            rq.addParams({
              'error': error,
              'stack': stack.toString().split("#"),
            });

            await rq.renderError(502);

            await rq.writeAndClose('');
          });
        });
      }).catchError((error, stack) {
        Console.e({
          'error': error,
          'stack': stack.toString().split("#"),
        });
      });
    });
  }

  /// Handles commands for the server, such as starting or stopping the server.
  Future<void> handleCommands(HttpServer server) async {
    var welcomeFinch = [
      "",
      r"     ¸    ┬─┐        ┬",
      r"    (@)>  ├─ . ┬─┐┌─ ├─┐",
      r"  >(/\)   ┴  ┴ ┴ ┴└─ ┴ ┴",
      r"    ┴┴    v" "${info.version}",
    ];

    CappConsole.write(welcomeFinch.join('\n'));

    await _runCommands(_args);
  }

  /// Creates and configures the command manager for interactive CLI operations.
  /// Sets up a [CappManager] with all available server commands including:
  /// - `help` - Shows help information for all available commands
  /// - `migrate` - Database migration tools (init, create, rollback, list)
  /// - `language` - Multi-language support management (list, reload)
  /// - `info` - Displays server information (version, memory, connections)
  /// - `route` - Route inspection and listing tools
  /// - `exit` - Graceful server shutdown
  /// Each command includes relevant options and provides structured output
  /// using tables and progress indicators for better user experience.
  /// [args] - Command-line arguments to initialize the manager
  /// Returns a configured [CappManager] instance ready for command processing
  CappManager _getCommandManager(List<String> args) => CappManager(
        main: CappController(
          '',
          options: [],
          run: (c) async {
            return CappConsole.empty;
          },
        ),
        args: args,
        controllers: [
          CappController('clear', options: [], run: (c) async {
            CappConsole.clear();
            return CappConsole.empty;
          }),
          CappController(
            'help',
            options: [
              CappOption(
                name: 'help',
                shortName: 'h',
                description: 'Show help',
              ),
            ],
            run: (c) async {
              return CappConsole(
                c.manager.getHelp(c.manager.controllers),
                CappColors.warning,
              );
            },
          ),
          CappController(
            'migrate',
            options: [
              CappOption(
                name: 'init',
                shortName: 'i',
                description: 'Init migration',
              ),
              CappOption(
                name: 'sqlite',
                shortName: 'sqlite',
                description: 'Init SQLite migration',
              ),
              CappOption(
                name: 'create',
                shortName: 'c',
                description: 'Create migration',
              ),
              CappOption(
                name: 'name',
                shortName: 'n',
                description: 'Name of migration file while creating',
                value: '',
              ),
              CappOption(
                name: 'rollback',
                shortName: 'r',
                description: 'Rollback migration',
              ),
              CappOption(
                name: 'list',
                shortName: 'l',
                description: 'List migration',
              ),
            ],
            description: 'Migration commands',
            run: (c) async {
              if (c.existsOption('init')) {
                var res = await CappConsole.progress<List<String>>(
                  "Initializing migration...",
                  () async => MysqlMigration(mysqlDriver).migrateInit(),
                );
                var index = 1;
                var table = res.map((e) => [(index++).toString(), e]).toList();
                if (table.isEmpty) {
                  table.add(['migrations to execute.']);
                } else {
                  table.insert(0, ['#', 'Migration Files']);
                }
                CappConsole.writeTable(table, color: CappColors.success);

                if (c.existsOption('sqlite')) {
                  var res = await CappConsole.progress<List<String>>(
                    "Initializing migration...",
                    () async => SqliteMigration(sqliteDriver).migrateInit(),
                  );
                  var index = 1;
                  var table =
                      res.map((e) => [(index++).toString(), e]).toList();
                  if (table.isEmpty) {
                    table.add(['SQLITE: migrations to execute.']);
                  } else {
                    table.insert(0, ['#', 'Migration Files']);
                  }
                  CappConsole.writeTable(table, color: CappColors.success);
                  return CappConsole("");
                }
                return CappConsole("");
              }

              if (c.existsOption('create')) {
                var name = "";
                if (c.existsOption('name')) {
                  name = c.getOption('name');
                } else {
                  name = CappConsole.read(
                    "Enter name of migration: ",
                    isRequired: true,
                  );
                }

                var res = await CappConsole.progress<String>(
                  "Creating migration...",
                  () async =>
                      MysqlMigration(mysqlDriver).migrateCreate(name: name),
                );
                return CappConsole(res);
              }

              if (c.existsOption('rollback')) {
                int deep = c.getOption('rollback', def: '1').toInt(def: 1);
                var res = await CappConsole.progress<String>(
                  "Rolling back migration...",
                  () async => MysqlMigration(mysqlDriver).migrateRollback(deep),
                );
                return CappConsole(res);
              }

              if (c.existsOption('list')) {
                var res =
                    await MysqlMigration(mysqlDriver).checkMigrationStatus();
                res.insert(
                    0, ["#", 'Migration Files', 'Executed', 'Created At']);
                CappConsole.writeTable(res, color: CappColors.success);
                return CappConsole("");
              }

              return CappConsole(
                "Please run the migration commands",
                CappColors.warning,
              );
            },
          ),
          CappController(
            'migrate_sqlite',
            options: [
              CappOption(
                name: 'init',
                shortName: 'i',
                description: 'Init migration',
              ),
              CappOption(
                name: 'create',
                shortName: 'c',
                description: 'Create migration',
              ),
              CappOption(
                name: 'name',
                shortName: 'n',
                description: 'Name of migration file while creating',
                value: '',
              ),
              CappOption(
                name: 'rollback',
                shortName: 'r',
                description: 'Rollback migration',
              ),
              CappOption(
                name: 'list',
                shortName: 'l',
                description: 'List migration',
              ),
            ],
            description: 'Migration commands',
            run: (c) async {
              if (c.existsOption('init')) {
                var res = await CappConsole.progress<List<String>>(
                  "Initializing migration...",
                  () async => SqliteMigration(sqliteDriver).migrateInit(),
                );
                var index = 1;
                var table = res.map((e) => [(index++).toString(), e]).toList();
                if (table.isEmpty) {
                  table.add(['No migrations to execute.']);
                } else {
                  table.insert(0, ['#', 'Migration Files']);
                }
                CappConsole.writeTable(table, color: CappColors.success);
                return CappConsole("");
              }

              if (c.existsOption('create')) {
                var name = "";
                if (c.existsOption('name')) {
                  name = c.getOption('name');
                } else {
                  name = CappConsole.read(
                    "Enter name of migration: ",
                    isRequired: true,
                  );
                }

                var res = await CappConsole.progress<String>(
                  "Creating migration...",
                  () async =>
                      SqliteMigration(sqliteDriver).migrateCreate(name: name),
                );
                return CappConsole(res);
              }

              if (c.existsOption('rollback')) {
                int deep = c.getOption('rollback', def: '1').toInt(def: 1);
                var res = await CappConsole.progress<String>(
                  "Rolling back migration...",
                  () async =>
                      SqliteMigration(sqliteDriver).migrateRollback(deep),
                );
                return CappConsole(res);
              }

              if (c.existsOption('list')) {
                var res =
                    await SqliteMigration(sqliteDriver).checkMigrationStatus();
                res.insert(
                    0, ["#", 'Migration Files', 'Executed', 'Created At']);
                CappConsole.writeTable(res, color: CappColors.success);
                return CappConsole("");
              }

              return CappConsole(
                "Please run the migration commands",
                CappColors.warning,
              );
            },
          ),
          CappController(
            'language',
            options: [
              CappOption(
                name: 'list',
                shortName: 'l',
                description: 'List languages',
              ),
              CappOption(
                name: 'reload',
                shortName: 'r',
                description: 'Reload language',
              )
            ],
            run: (c) async {
              if (c.existsOption('list')) {
                var languages = appLanguages.keys.toList();
                var table = <List<String>>[];
                var index = 1;
                for (var lang in languages) {
                  table.add([
                    (index++).toString(),
                    lang,
                    appLanguages[lang]?.length.toString() ?? '0',
                  ]);
                }
                if (table.isEmpty) {
                  table.add(['No languages found.']);
                } else {
                  table.insert(0, ['#', 'Language', 'Strings']);
                }
                CappConsole.writeTable(table, color: CappColors.success);
                return CappConsole("");
              }

              if (c.existsOption('reload')) {
                var res = await CappConsole.progress<String>(
                  "Reloading language...",
                  () async {
                    appLanguages = await MultiLanguage(
                      languagePath: config.languagePath,
                      source: config.languageSource,
                      dartLanguages: config.dartLanguages,
                    ).init();
                    return appLanguages.length.toString();
                  },
                );
                return CappConsole("Count of languages: $res");
              }

              return CappConsole("Language commands");
            },
          ),
          CappController('info', options: [], run: (c) async {
            CappConsole.writeTable(
              [
                ['Info', 'Details'],
                ['Finch version', info.version],
                ['Dart Versions', Platform.version],
                [
                  'Memory Usage',
                  ConvertSize.toLogicSizeString(ProcessInfo.currentRss)
                ],
                [
                  'Max Memory Usage',
                  ConvertSize.toLogicSizeString(ProcessInfo.maxRss)
                ],
                [
                  'Socket Connections',
                  (socketManager?.countClients ?? 0).toString(),
                ],
                ['Socket Users', (socketManager?.countUsers ?? 0).toString()],
              ],
              color: CappColors.info,
            );
            return CappConsole('\n');
          }),
          CappController('exit', options: [], run: (c) async {
            await CappConsole.progress(
              "Bye bye!",
              () async {
                await stop(force: true);
                await Future.delayed(Duration(seconds: 1), () {
                  exit(0);
                });
              },
              type: CappProgressType.circle,
            );
          }),
          ...commands,
        ],
      );

  /// Processes command-line arguments and enters interactive command mode.
  /// Handles the execution of server commands such as:
  /// - `help` - Display available commands
  /// - `migrate` - Database migration operations
  /// - `language` - Language management commands
  /// - `info` - Server information display
  /// - `route` - Route inspection
  /// - `exit` - Graceful server shutdown
  /// If no arguments are provided, the method returns immediately.
  /// Otherwise, it starts an interactive command prompt (Finch>) where
  /// users can continue entering commands.
  /// [args] - List of command-line arguments to process
  Future<void> _runCommands(List<String> args) async {
    if (args.isEmpty) {
      return;
    }

    return _getCommandManager(args).processWhile(
      initArgs: args,
      promptLabel: 'Finch> ',
    );
  }

  /// Connects to MongoDB using the connection string from the configuration.
  /// If `config.dbConfig.enable` is true, the database connection is opened.
  /// Returns a [Future] containing the [mongo.Db] instance.
  Future<mongo.Db> connectMongoDb() async {
    var db = mongo.Db(config.dbConfig.link);
    if (config.dbConfig.enable) {
      await db.open().onError((err, stack) {
        Console.e(err.toString());
      });
    }
    return db;
  }

  /// Connects to MySQL using the connection string from the configuration.
  Future<void> connectMysqlDb() async {
    if (config.mysqlConfig.enable) {
      _mysqlDb = await MySQLConnection.createConnection(
        host: config.mysqlConfig.host,
        port: config.mysqlConfig.port,
        userName: config.mysqlConfig.user,
        password: config.mysqlConfig.pass,
        databaseName: config.mysqlConfig.databaseName,
        secure: config.mysqlConfig.secure,
        collation: config.mysqlConfig.collation,
      );
      _mysqlDb!.onClose(
        () => Console.e("MySQL connection closed"),
      );
      if (config.mysqlConfig.enable) {
        await _mysqlDb!.connect().onError((err, stack) {
          Console.e(err.toString());
        });
      }
    }
  }

  /// Connects to SQLite using the connection string from the configuration.
  Future<void> connectSqliteDb() async {
    if (config.sqliteConfig.enable) {
      try {
        _sqliteDb = sqlite3.open(config.sqliteConfig.filePath);
      } catch (e) {
        Console.e("Error connecting to SQLite: $e");
        _sqliteDb = null;
      }
    }
  }

  /// Registers a [FinchCron] instance to be scheduled.
  /// The [cron] parameter is the [FinchCron] instance to be registered.
  void registerCron(FinchCron cron) {
    crons.add(cron);
  }

  Future<List<Map>> exploreAllRoutes() async {
    var allRoutes = await getAllRoutes();

    List<Map> convert(List<FinchRoute> routes, String parentPath, hasAuth) {
      var result = <Map>[];

      for (final route in routes) {
        for (var method in route.methods) {
          var map = route.toMap(
            parentPath,
            hasAuth || route.auth != null,
            method,
          );
          result.addAll(map);
        }
        if (route.children.isNotEmpty) {
          result.addAll(
            convert(
              route.children,
              "$parentPath${route.path}",
              hasAuth || route.auth != null,
            ),
          );

          for (var epath in route.extraPath) {
            result.addAll(
              convert(
                route.children,
                "$parentPath$epath",
                hasAuth || route.auth != null,
              ),
            );
          }
        }
      }

      return result;
    }

    var webRoutes = convert(allRoutes, '', false);
    var index = 1;

    webRoutes.sort(
        (a, b) => a['fullPath'].toString().compareTo(b['fullPath'].toString()));
    webRoutes = webRoutes.map((e) {
      e['#'] = index++;
      return e;
    }).toList();
    return webRoutes;
  }

  /// Flag to track whether the debugger has been initialized.
  /// Prevents multiple initialization of the debugging system
  /// when [debuggerInit] is called multiple times.
  var _isDebuggerInit = false;

  /// Initializes the local development debugger system.
  /// Sets up a WebSocket-based debugging interface that provides:
  /// - Real-time route inspection and listing
  /// - Language file reloading capabilities
  /// - Server restart functionality
  /// - Memory usage monitoring
  /// - Error and log message broadcasting
  /// - Console widget for debugging
  /// The debugger is only initialized when both `config.enableLocalDebugger`
  /// and `config.isLocalDebug` are true, and prevents duplicate initialization.
  /// Automatically adds debugging routes to the server:
  /// - `/debugger` - Main debugger interface
  /// - `/debugger/console.js` - Console widget JavaScript
  void debuggerInit() {
    if (config.enableLocalDebugger && config.isLocalDebug && !_isDebuggerInit) {
      _isDebuggerInit = true;
      debugger = SocketManager(
        this,
        routes: {
          'get_routes': SocketEvent(onMessage: (socket, data) async {
            var res = await exploreAllRoutes();
            debugger?.sendToAll({
              'routes': res,
            }, path: 'get_routes');
          }),
          'update_languages': SocketEvent(onMessage: (socket, data) async {
            appLanguages = await MultiLanguage(
              languagePath: config.languagePath,
              source: config.languageSource,
              dartLanguages: config.dartLanguages,
            ).init();
            await debugger?.sendToAll(
              {'message': 'Language updated'},
              path: 'update_languages',
            );
          }),
          'restart': SocketEvent(onMessage: (socket, data) async {
            await debugger?.sendToAll({}, path: 'restartStarted');
            await stop(force: true);
            await start();
            await getAllRoutes();
          }),
          'get_data': SocketEvent(onMessage: (socket, data) async {
            debugger?.sendToAll({
              'error': {
                'params': socket.rq.getParams(),
                'uri': socket.rq.uri.toString(),
                'buffer': socket.rq.buffer,
                'headers': socket.rq.headers.toString().split(';'),
                'session_cookies': socket.rq.getAllSession(),
              },
            }, path: 'console');
          }),
          'reinit': SocketEvent(onMessage: (socket, data) async {
            print("Server is restarting...");
            await restart();
            await getAllRoutes();
          }),
        },
      );

      Console.onError.add((error, type) {
        debugger?.sendToAll({
          'error': error.toString(),
          'type': type,
        }, path: "console");
      });

      Console.onLogging.add((error, type) {
        debugger?.sendToAll({
          'message': error.toString(),
          'type': type,
        }, path: "log");
      });

      FinchCron(
        schedule: FinchCron.evrySecond(1),
        delayFirstMoment: false,
        onCron: (index, cron) async {
          debugger?.sendToAll({
            'memory': ConvertSize.toLogicSizeString(ProcessInfo.currentRss),
            'max_memory': ConvertSize.toLogicSizeString(ProcessInfo.maxRss),
          }, path: "updateMemory");
        },
      ).start();
      _webRoutes.add((Request rq) async {
        rq.buffer.writeln(
            "<script src='${rq.url('/debugger/console.js')}'></script>");
        return [
          FinchRoute(
            path: 'debugger',
            index: () async {
              await debugger?.requestHandle(rq, userId: "LOCAL_USER");
              debugger?.sendToAll({
                'type': 'user_connected',
                'userId': "LOCAL_USER",
              });
              return rq.renderSocket();
            },
            children: [
              FinchRoute(
                path: 'console.js',
                index: () async {
                  return rq.renderString(
                    text: ConsoleWidget().layout,
                    contentType: ContentType(
                      'text',
                      'javascript',
                      charset: 'utf-8',
                    ),
                  );
                },
              )
            ],
          )
        ];
      });
    }
  }

  FinchApp all({
    required String path,
    Future<String> Function(Request rq)? index,
    List<String> methods = Methods.ALL,
    AuthController? auth,
    List<FinchRoute> children = const [],
    List<String> extraPath = const [],
    Future<ApiDoc>? Function()? apiDoc,
    Controller? controller,
    List<String> excludePaths = const [],
    List<String> hosts = const ['*'],
    List<int> ports = const [],
    String? key,
    Map<String, dynamic> params = const {},
    List<String> permissions = const [],
  }) {
    _webRoutes.add((Request rq) async {
      return [
        FinchRoute(
          path: path,
          index: index != null ? () => index(rq) : null,
          methods: methods,
          auth: auth,
          children: children,
          extraPath: extraPath,
          apiDoc: apiDoc,
          controller: controller,
          excludePaths: excludePaths,
          hosts: hosts,
          ports: ports,
          key: key,
          params: params,
          permissions: permissions,
        )
      ];
    });
    return this;
  }

  FinchApp get({
    required String path,
    Future<String> Function(Request rq)? index,
    AuthController? auth,
    List<FinchRoute> children = const [],
    List<String> extraPath = const [],
    Future<ApiDoc>? Function()? apiDoc,
    Controller? controller,
    List<String> excludePaths = const [],
    List<String> hosts = const ['*'],
    List<int> ports = const [],
    String? key,
    Map<String, dynamic> params = const {},
    List<String> permissions = const [],
  }) {
    return all(
      path: path,
      index: index,
      methods: Methods.ONLY_GET,
      auth: auth,
      children: children,
      extraPath: extraPath,
      apiDoc: apiDoc,
      controller: controller,
      excludePaths: excludePaths,
      hosts: hosts,
      ports: ports,
      key: key,
      params: params,
      permissions: permissions,
    );
  }

  FinchApp post({
    required String path,
    Future<String> Function(Request rq)? index,
    AuthController? auth,
    List<FinchRoute> children = const [],
    List<String> extraPath = const [],
    Future<ApiDoc>? Function()? apiDoc,
    Controller? controller,
    List<String> excludePaths = const [],
    List<String> hosts = const ['*'],
    List<int> ports = const [],
    String? key,
    Map<String, dynamic> params = const {},
    List<String> permissions = const [],
  }) {
    return all(
      path: path,
      index: index,
      methods: Methods.ONLY_POST,
      auth: auth,
      children: children,
      extraPath: extraPath,
      apiDoc: apiDoc,
      controller: controller,
      excludePaths: excludePaths,
      hosts: hosts,
      ports: ports,
      key: key,
      params: params,
      permissions: permissions,
    );
  }

  FinchApp postGet({
    required String path,
    Future<String> Function(Request rq)? index,
    AuthController? auth,
    List<FinchRoute> children = const [],
    List<String> extraPath = const [],
    Future<ApiDoc>? Function()? apiDoc,
    Controller? controller,
    List<String> excludePaths = const [],
    List<String> hosts = const ['*'],
    List<int> ports = const [],
    String? key,
    Map<String, dynamic> params = const {},
    List<String> permissions = const [],
  }) {
    return all(
      path: path,
      index: index,
      methods: Methods.GET_POST,
      auth: auth,
      children: children,
      extraPath: extraPath,
      apiDoc: apiDoc,
      controller: controller,
      excludePaths: excludePaths,
      hosts: hosts,
      ports: ports,
      key: key,
      params: params,
      permissions: permissions,
    );
  }
}

/// Provides version and build information for the Finch server.
/// This class contains static information about the current server version
/// and can be extended to include additional build metadata such as
/// build date, commit hash, or environment information.
class _Info {
  /// The current version of the Finch server framework.
  /// Follows semantic versioning (SemVer) format: MAJOR.MINOR.PATCH[-PRERELEASE]
  /// - MAJOR: Breaking changes
  /// - MINOR: New features (backward compatible)
  /// - PATCH: Bug fixes (backward compatible)
  /// - PRERELEASE: Pre-release identifiers (alpha, beta, rc)
  final String version = '1.0.3';
}
