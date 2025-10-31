import '../controllers/auth_controller.dart';
import '../controllers/htmler_controller.dart';
import '../configs/setting.dart';
import '../app.dart';
import '../controllers/api_document.dart';
import 'package:finch/finch_route.dart';
import '../controllers/home_controller.dart';

Future<List<FinchRoute>> getWebRoute(Request rq) async {
  final homeController = HomeController();
  final htmlerController = HtmlerController();
  final authController = AppAuthController(homeController);
  final includeController = IncludeJsController();
  final apiController = ApiController(
    title: "API Documentation",
    app: app,
  );

  var paths = [
    FinchRoute(
      key: 'root.sse',
      path: 'sse',
      methods: Methods.ALL,
      index: homeController.sseExample,
    ),
    FinchRoute(
      key: 'root.api.docs',
      path: 'api/docs',
      index: apiController.indexPublic,
    ),
    FinchRoute(
      key: 'root.swagger',
      path: 'swagger',
      index: () => apiController.swagger(rq.url('api/docs')),
    ),
    FinchRoute(
      key: 'root.ws',
      path: 'ws',
      methods: Methods.ALL,
      index: homeController.socket,
    ),
    FinchRoute(
      key: 'root.includes',
      path: 'app/includes.js',
      methods: Methods.ALL,
      index: includeController.index,
    ),
    FinchRoute(
      key: 'root.example',
      path: 'example',
      index: homeController.redirectToRoot,
      children: [
        FinchRoute(
          key: 'root.localhost',
          path: 'host',
          hosts: ['localhost'],
          ports: [80, 8085],
          index: homeController.renderLocalhost,
          methods: Methods.ALL,
        ),
        FinchRoute(
          key: 'root.host',
          path: 'host',
          ports: [80, 8085],
          hosts: ['127.0.0.1'],
          index: homeController.render127001,
          methods: Methods.ALL,
        ),
        FinchRoute(
          key: 'root.form',
          path: 'form',
          methods: Methods.ONLY_GET,
          index: homeController.exampleForm,
        ),
        FinchRoute(
          key: 'root.form.post',
          path: 'form',
          methods: Methods.ONLY_POST,
          index: authController.loginPost,
        ),
        FinchRoute(
          key: 'root.panel',
          path: 'panel',
          methods: Methods.ALL,
          auth: authController,
          index: homeController.exampleAuth,
          permissions: ['admin'],
        ),
        FinchRoute(
          key: 'root.language',
          path: 'language',
          methods: Methods.ONLY_GET,
          index: homeController.exampleLanguage,
        ),
        FinchRoute(
          key: 'root.cookie',
          path: 'cookie',
          methods: Methods.ONLY_GET,
          index: homeController.exampleCookie,
        ),
        FinchRoute(
          key: 'root.cookie.post',
          path: 'cookie',
          methods: Methods.ONLY_POST,
          index: homeController.exampleAddCookie,
        ),
        FinchRoute(
          key: 'root.cookie.add',
          path: 'cookie',
          methods: Methods.ONLY_GET,
          index: homeController.exampleAddCookie,
        ),
        FinchRoute(
          key: 'root.route',
          path: 'route',
          methods: Methods.ONLY_GET,
          index: homeController.exampleRoute,
        ),
        FinchRoute(
          key: 'root.socket',
          path: 'socket',
          methods: Methods.ONLY_GET,
          index: homeController.exampleSocket,
        ),
        FinchRoute(
          key: 'root.email',
          path: 'email',
          methods: Methods.ONLY_GET,
          index: homeController.exampleEmail,
        ),
        FinchRoute(
          key: 'root.email.post',
          path: 'email',
          methods: Methods.ONLY_POST,
          index: homeController.exampleEmailSend,
        ),
        FinchRoute(
          key: 'root.error',
          path: 'error',
          index: homeController.exampleError,
        ),
        FinchRoute(
          key: 'root.dump',
          path: 'dump',
          index: homeController.exampleDump,
        ),
        FinchRoute(
          key: 'root.database',
          path: 'database',
          methods: [
            Methods.GET,
            Methods.POST,
            Methods.PUT,
            Methods.DELETE,
          ],
          index: homeController.exampleDatabase,
        ),
        FinchRoute(
          key: 'root.pagination',
          path: 'pagination',
          methods: [
            Methods.GET,
          ],
          index: homeController.paginationExample,
        ),
        FinchRoute(
          key: 'root.htmler',
          path: 'htmler',
          methods: Methods.GET_POST,
          index: htmlerController.exampleHtmler,
        ),
      ],
    ),
    FinchRoute(
      key: 'root.mysql',
      path: 'example/mysql',
      extraPath: ['api/example/mysql'],
      methods: Methods.GET_POST,
      index: homeController.exampleMysql,
    ),
    FinchRoute(
      key: 'root.sqlite',
      path: 'example/sqlite',
      extraPath: ['api/example/sqlite'],
      methods: Methods.GET_POST,
      index: homeController.exampleSqlite,
    ),
    FinchRoute(
      key: 'root.info',
      path: 'info',
      extraPath: ['api/info'],
      index: homeController.info,
      apiDoc: ApiDocuments.info,
    ),
    FinchRoute(
      key: 'root.person.post',
      path: 'api/person',
      extraPath: ['example/person'],
      index: homeController.addNewPerson,
      methods: Methods.ONLY_POST,
      apiDoc: ApiDocuments.allPerson,
    ),
    FinchRoute(
      key: 'root.persons',
      path: 'example/persons',
      extraPath: [
        'api/persons',
        'example/person',
      ],
      index: homeController.allPerson,
      methods: Methods.ONLY_GET,
      apiDoc: ApiDocuments.allPerson,
    ),
    FinchRoute(
      key: 'root.person.show',
      path: 'api/person/{id}',
      extraPath: ['example/person/{id}'],
      index: homeController.onePerson,
      methods: Methods.GET_POST,
      apiDoc: ApiDocuments.onePerson,
    ),
    FinchRoute(
      key: 'root.person.replace',
      path: 'api/person/replace/{id}',
      extraPath: ['example/person/replace/{id}'],
      index: homeController.replacePerson,
      methods: Methods.ONLY_POST,
    ),
    FinchRoute(
      key: 'root.person.delete',
      path: 'api/person/delete/{id}',
      extraPath: ['example/person/delete/{id}'],
      index: homeController.deletePerson,
      methods: Methods.ONLY_POST,
      apiDoc: ApiDocuments.onePerson,
    ),
    FinchRoute(
      key: 'root.logout',
      path: 'logout',
      methods: Methods.ALL,
      index: authController.logout,
    ),
  ];

  return [
    FinchRoute(
      key: 'root.home',
      path: '/',
      methods: Methods.ALL,
      controller: homeController,
      children: [
        ...paths,
        FinchRoute(
          key: 'root.language.change',
          path: 'fa/*',
          extraPath: Setting.languages.keys.map((e) => '$e/*').toList(),
          index: homeController.changeLanguage,
        )
      ],
    ),
  ];
}
