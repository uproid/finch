### Run

```shel
docker compose up --build
```

## Examples
  Please refer to the documentation and the GitHub page for a comprehensive review of the examples. You can also view the example as a [Demo](https://finch.uproid.com).

### [View Examples](https://github.com/uproid/finch/tree/master/example)  |  [Live Demo](https://finch.uproid.com) | [Documentations](https://github.com/uproid/finch/tree/master/doc)

```dart
import 'package:finch/finch_console.dart';
import 'package:finch/finch_app.dart';
import 'package:finch/finch_tools.dart';
import 'lib/route/socket_route.dart';
import 'lib/route/web_route.dart';

FinchConfigs configs = FinchConfigs(
  widgetsPath: pathTo(env['WIDGETS_PATH'] ?? "./example/widgets"),
  widgetsType: env['WIDGETS_TYPE'] ?? 'j2.html',
  languagePath: pathTo(env['LANGUAGE_PATH'] ?? "./example/languages"),
  publicDir: pathTo(env['PUBLIC_DIR'] ?? './example/public'),
  dbConfig: FinchDBConfig(enable: false),
  port: 8085,
);

FinchServer server = FinchServer(configs: configs);

final socketManager = SocketManager(
  server,
  event: SocketEvent(
    onConnect: (socket) {
      server.socketManager?.sendToAll(
        "New user connected! count: ${server.socketManager?.countClients}",
        path: "output",
      );
      socket.send(
        {'message': 'Soccuess connect to socket!'},
        path: 'connected',
      );
    },
    onMessage: (socket, data) {},
    onDisconnect: (socket) {
      var count = server.socketManager?.countClients ?? 0;
      server.socketManager?.sendToAll(
        "User disconnected! count: ${count - 1}",
        path: "output",
      );
    },
  ),
  routes: getSocketRoute(),
);

void main() async {
  server.addRouting(getWebRoute);
  server.start().then((value) {
    Console.p("Example app started: http://localhost:${value.port}");
  });
}

```