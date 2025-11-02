### Run

```shel
docker compose up --build
```

## Examples
  Please refer to the documentation and the GitHub page for a comprehensive review of the examples. You can also view the example as a [Demo](https://example.uproid.com).

### [View Examples](https://github.com/uproid/finch/tree/master/example)  |  [Live Demo](https://example.uproid.com) | [Documentations](https://github.com/uproid/finch/tree/master/doc)

```dart
import 'package:finch/finch_console.dart';
import 'package:finch/finch_app.dart';
import 'package:finch/finch_tools.dart';
import 'package:finch/finch_route.dart';
import 'package:finch/finch_capp.dart';
import 'lib/route/socket_route.dart';
import 'lib/route/web_route.dart';

FinchConfigs configs = FinchConfigs(
  widgetsPath: pathTo(env['WIDGETS_PATH'] ?? "./lib/widgets"),
  widgetsType: env['WIDGETS_TYPE'] ?? 'j2.html',
  languagePath: pathTo(env['LANGUAGE_PATH'] ?? "./lib/languages"),
  publicDir: pathTo(env['PUBLIC_DIR'] ?? './public'),
  dbConfig: FinchDBConfig(
    enable: true,
    dbName: 'example',
    auth: 'admin',
    pass: 'PasswordMongoDB',
    host: env['MONGO_CONNECTION'] ?? 'localhost',
    port: env['MONGO_PORT'] ?? '27018',
    user: 'root',
  ),
  port: (env['DOMAIN_PORT'] ?? '8085').toInt(def: 8085),
  mysqlConfig: FinchMysqlConfig(
    enable: true,
    host: env['MYSQL_HOST'] ?? 'localhost',
    port: 3306,
    user: 'example_user',
    pass: 'example_password',
    databaseName: 'example_db',
  ),

  /// Enable local debugger
  enableLocalDebugger: (env['ENABLE_LOCAL_DEBUGGER'] ?? true).toString().toBool,

  /// SQLite configuration
  sqliteConfig: FinchSqliteConfig(
    enable: true,
    filePath: env['SQLITE_PATH'] ?? './example_database.sqlite',
  ),
);

final app = FinchApp(configs: configs);

final socketManager = SocketManager(
  app,
  event: SocketEvent(
    onConnect: (socket) {
      app.socketManager?.sendToAll(
        "New user connected! count: ${app.socketManager?.countClients}",
        path: "output",
      );
      socket.send(
        {'message': 'Soccuess connect to socket!'},
        path: 'connected',
      );
    },
    onMessage: (socket, data) {},
    onDisconnect: (socket) {
      var count = app.socketManager?.countClients ?? 0;
      app.socketManager?.sendToAll(
        "User disconnected! count: ${count - 1}",
        path: "output",
      );
    },
  ),
  routes: getSocketRoute(),
);

void main([List<String>? args]) async {
  /// Example Web Route
  app.addRouting(getWebRoute);

  /// Add custom commands
  app.commands.add(
    CappController('example', options: [
      CappOption(
        name: 'test',
        shortName: 't',
        description: 'An example option',
      ),
    ], run: (c) async {
      if (c.existsOption('test')) {
        CappConsole.writeTable(
          [
            ['Column 1', 'Column 2', 'Column 3'],
            ...List.filled(5, ['Data 1', 'Data 2', 'Data 3'])
          ],
          dubleBorder: true,
          color: CappColors.warning,
        );
      }

      return CappConsole(
        'This is an example command from Finch App! Time: ${DateTime.now()}',
        CappColors.success,
      );
    }),
  );

  /// Or add routes directly one by one
  app
    ..get(
      path: '/get',
      index: (rq) async {
        return rq.renderString(text: 'Hello from ${rq.method} /get request!');
      },
    )
    ..postGet(
      path: '/post',
      index: (rq) async {
        return rq.renderString(text: 'Hello from ${rq.method} /post request!');
      },
    );

  Request.localEvents.addAll(localEvents);
  Request.addLocalLayoutFilters(localLayoutFilters);
  app.start(args).then((value) {
    Console.p("Example app started: http://localhost:${value.port}");
  });

  /// Example Cron job
  app.registerCron(
    /// Evry 2 days clean the example collection of database
    FinchCron(
      schedule: FinchCron.evryDay(2),
      onCron: (index, cron) async {
        if (app.mongoDb.isConnected) {
          ExampleCollections().deleteAll();
        }
      },
      delayFirstMoment: true,
    ).start(),
  );

  app.registerCron(
    /// Add evry hour a new document to the example collection of database
    FinchCron(
      schedule: "0 * * * *",
      onCron: (index, cron) async {
        if (app.mongoDb.isConnected) {
          ExampleCollections().insertExample(ExampleModel(
            title: DateTime.now().toString(),
            slug: 'slug-$index',
          ));
        }
      },
      delayFirstMoment: true,
    ).start(),
  );
}

```