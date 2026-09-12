import 'core/configs.dart';
import 'dart_migration/sqlite1_create_database.dart';
import 'dart_migration/sqlite2_insert_database.dart';
import 'dart_migration/sqlite3_fix_database.dart';
import 'dart_migration/sqlite4_insert_database.dart';
import 'core/local_events.dart';
import 'package:finch/finch_route.dart';
import 'db/job_collection_free.dart';
import 'db/person_collection_free.dart';
import 'package:finch/finch_model_less.dart';
import 'db/example_collections.dart';
import 'models/example_model.dart';
import 'package:finch/finch_console.dart';
import 'package:finch/finch_app.dart';
import 'route/meeting_route.dart';
import 'route/socket_route.dart';
import 'route/web_route.dart';
import 'package:finch/finch_capp.dart';

final app = FinchApp(configs: configs)
  ..registerDartMigration([
    M1createDatabase(),
    M2insertDatabase(),
    M3fixDatabase(),
    M4insertDatabase(),
  ]);

var jobCollectionFree = JobCollectionFree(db: app.mongoDb);
var personCollectionFree = PersonCollectionFree(db: app.mongoDb);

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
      MeetingRoomManager.instance.onDisconnect(socket);
    },
  ),
  routes: {
    ...getSocketRoute(),
    ...MeetingRoomManager.instance.getRoutes(),
  },
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
        Console.p(
            "#1) `${FinchCron.evryDay(2)}` Cron job executed at ${DateTime.now()}, index: $index");
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
        Console.p(
            "#2) `0 * * * *` Cron job executed at ${DateTime.now()}, index: $index");
        if (app.mongoDb.isConnected) {
          ExampleCollections().insertExample(ExampleModel(
            title: DateTime.now().toString(),
            slug: 'slug-$index',
          ));
        }
      },
    ).start(),
  );

  // Clear all route cache (memory and file) every restart
  RouteCache.clearAllCache();
}

void printDB() {
  DBCollectionFree.printDesign();
}
