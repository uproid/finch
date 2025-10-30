import 'package:test/test.dart';
import 'package:finch/src/tools/console.dart';
import 'package:finch/finch_route.dart';
import 'package:finch/finch_app.dart';
import 'package:finch/finch_tools.dart';
import 'package:http/http.dart' as http;

void main() async {
  FinchApp server = FinchApp(
    configs: FinchConfigs(
      port: 8089,
      publicDir: 'public',
      languagePath: joinPaths([pathApp, '../example/lib/languages']),
      widgetsPath: '../example/lib/widgets',
      widgetsType: 'j2.html',
      dbConfig: FinchDBConfig(
        enable: false,
      ),
      enableLocalDebugger: true,
    ),
  );

  Future<List<FinchRoute>> routing(Request rq) async {
    return [
      FinchRoute(
        path: "/",
        index: () => rq.renderString(text: "TEST"),
        children: [
          FinchRoute(
            path: 'checkurl',
            index: () {
              return rq.renderView(
                path: "<?= \$e.url('test') ?>",
                isFile: false,
              );
            },
          ),
          FinchRoute(
            path: 'error',
            index: () {
              throw ("test error page");
            },
          ),
          FinchRoute(
            path: 'debug_test',
            methods: Methods.ALL,
            index: () {
              return rq.renderView(path: "<h1>Debug Test</h1>", isFile: false);
            },
          ),
          FinchRoute(
            path: 'widget',
            index: () {
              rq.addParam("testParam", "paramValue");
              return rq.renderView(
                path: "<?= \$e.url('test') ?>\n"
                    "<?= testParam ?>\n"
                    "<?= \$t('test.translate') ?>\n",
                isFile: false,
              );
            },
          ),
          FinchRoute(
            path: "api/info",
            methods: Methods.ONLY_GET,
            index: () {
              rq.addParam("data", "TEST");
              return rq.renderData(data: rq.getParams());
            },
          ),
          FinchRoute(
            path: "api/post",
            methods: Methods.ONLY_POST,
            index: () {
              return rq.renderData(data: {
                'sended': rq.getAll(),
                'cookies': {
                  'sessionId': rq.getCookie('sessionId', safe: false),
                  'username': rq.getCookie('username', safe: false),
                },
              });
            },
          ),
        ],
      ),
    ];
  }

  server.addRouting(routing);
  var httpServer = await server.start([], false).then((value) {
    Console.p("Example app started: http://localhost:${value.port}");
    return value;
  });

  group("test debugger", () {
    test("checking Debugger1", () async {
      var req = await http.get(
        Uri.parse("http://localhost:${httpServer.port}/debugger/console.js"),
      );

      expect(
        req.statusCode,
        200,
        reason:
            "Response success should contain 'console.js' it used for debugging",
      );
      expect(req.statusCode, 200, reason: "Status code should be 200");
    });

    test("checking Debugger2", () async {
      var req = await http.get(
        Uri.parse("http://localhost:${httpServer.port}/debug_test/"),
      );
      var content = req.body;
      expect(
        content.contains(
            "<script src='http://localhost:${httpServer.port}/debugger/console.js'></script>"),
        true,
        reason:
            "Response success should contain '<script src=...>' used for debugging",
      );
      expect(req.statusCode, 200, reason: "Status code should be 200");
    });

    test("checking Debugger3", () async {
      var req = await http.get(
        Uri.parse("http://localhost:${httpServer.port}/api/info"),
      );
      var content = req.body;
      print(content);
      expect(
        content.contains("<script src='/debugger/console.js'></script>"),
        false,
        reason: "debugger used only on HTML pages",
      );
      expect(req.statusCode, 200, reason: "Status code should be 200");
    });
  });
}
