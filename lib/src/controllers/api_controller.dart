import 'package:finch/finch_route.dart';
import 'package:finch/finch_app.dart';
import 'package:finch/finch_tools.dart';

/// The `ApiController` class is responsible for managing API routes and generating
/// OpenAPI documentation for the API.
/// This controller extends the `Controller` and includes functionality for
/// configuring API routes, generating Swagger UI documentation, and handling
/// security settings.
/// Example usage:
/// ```dart
/// ApiController(
///   rq,
///   router: myRouter,
///   title: 'My API',
///   security: 'apiKey',
/// );
/// ```
class ApiController extends Controller {
  /// A list of functions that return a list of [FinchRoute] objects based on the
  /// incoming [Request] `rq`.
  ///
  /// These functions are used to define the routes available for the API.
  FinchApp app;

  /// The title of the API, used in generated documentation.
  String title;

  /// The security scheme used for the API. Defaults to `'apiKey'`.
  ///
  /// This is used to configure security settings for the OpenAPI documentation.
  String security;

  /// Constructs a [ApiController] with the given request `rq`, router, title, and
  /// optional security scheme.
  ///
  /// The [title] parameter is required and sets the API title.
  /// The [security] parameter defaults to `'apiKey'`.
  /// [app] is the FinchServer instance containing the routes.
  ApiController({
    required this.app,
    required this.title,
    this.security = 'apiKey',
  });

  /// Generates and returns OpenAPI documentation as a JSON string.
  ///
  /// The [showPublic] parameter determines whether to show the documentation
  /// publicly. If set to `false`, documentation is only shown in local debug mode.
  ///
  /// Returns a [Future] that completes with a JSON string containing the
  /// OpenAPI 3.1 documentation.
  @override
  Future<String> index({bool showPublic = false}) async {
    var config = FinchApp.config;
    if (!showPublic && !config.isLocalDebug) {
      return rq.renderError(403);
    }

    var paths = {};
    List<FinchRoute> routes = await app.getAllRoutes();

    var webRoutes = _convert(routes, '', null);

    for (var route in webRoutes) {
      if (route.apiDoc == null) {
        continue;
      }

      var apiDoc = await route.apiDoc!.call();

      if (!route.path.startsWith('/api') || apiDoc == null) {
        continue;
      }
      var res = {};

      for (var method in route.methods) {
        var data = {};
        RegExp regex = RegExp(r'{.*?}');
        data['tags'] = [
          //pathNorm(route.path, normSlashs: true),
          pathNorm(route.path.replaceAll(regex, ''), normSlashs: true),
        ];
        data['summary'] = route.title;
        data['description'] = route.title;
        data['operationId'] = "${route.title} [$method] ${route.path}";
        if (route.auth != null) {
          data['security'] = [
            {
              "auth": ["write", "read"]
            }
          ];
        }
        var requestBody = {};
        var responses = {};
        var parameters = [];

        var doc = ApiDoc(
          body: List.from(apiDoc.body),
          response: Map.from(apiDoc.response),
          parameters: List.from(apiDoc.parameters),
          description: apiDoc.description,
          post: apiDoc.post,
          delete: apiDoc.delete,
          get: apiDoc.get,
          put: apiDoc.put,
        );

        if (method.toLowerCase() == 'get' && doc.get != null) {
          doc.body.addAll(doc.get!.body);
          doc.response.addAll(doc.get!.response);
          doc.parameters.addAll(doc.get!.parameters);
          doc.description = doc.get!.description;
        } else if (method.toLowerCase() == 'post' && doc.post != null) {
          doc.body.addAll(doc.post!.body);
          doc.response.addAll(doc.post!.response);
          doc.parameters.addAll(doc.post!.parameters);
          doc.description = doc.post!.description;
        } else if (method.toLowerCase() == 'put' && doc.put != null) {
          doc.body.addAll(doc.put!.body);
          doc.response.addAll(doc.put!.response);
          doc.parameters.addAll(doc.put!.parameters);
          doc.description = doc.put!.description;
        } else if (method.toLowerCase() == 'delete' && doc.delete != null) {
          doc.body.addAll(doc.delete!.body);
          doc.response.addAll(doc.delete!.response);
          doc.parameters.addAll(doc.delete!.parameters);
          doc.description = doc.delete!.description;
        }

        if (doc.body.isNotEmpty) {
          var responseShema = <dynamic, dynamic>{
            "type": "object",
          };
          var properties = {};
          var description = "";
          for (var pro in doc.body) {
            properties[pro.name] = {
              'type': pro.typeString,
              'format': pro.typeString,
              'examples': [pro.def],
            };

            description +=
                "<b>${pro.name}</b>: ${pro.isRequired ? '* Is required' : 'Not required'} ${pro.description != null ? '| $pro.description' : ""}\n\n";
          }
          responseShema['type'] = 'object';
          responseShema['properties'] = properties;
          requestBody['description'] = description;
          requestBody['content'] = {
            'application/json': {
              'schema': responseShema,
            },
          };
        }

        if (doc.response.isNotEmpty) {
          for (var res in doc.response.keys) {
            var listResponse = doc.response[res]!;
            var responseShema = {};
            var properties = {};
            for (var response in listResponse) {
              properties[response.name] = {
                'type': response.typeString,
                'format': response.typeString,
                'examples': [response.def],
              };
            }
            responseShema['type'] = 'object';
            responseShema['properties'] = properties;
            responses[res] = {
              'description': res,
              'content': {
                'application/json': {
                  'schema': responseShema,
                },
              },
            };
          }
        }

        for (var param in doc.parameters) {
          parameters = [
            ...parameters,
            {
              "name": param.name,
              "in": param.paramIn.toString(),
              "description": param.description ?? "",
              "required": param.isRequired,
              "schema": {
                "type": param.typeString,
                "format": param.typeString,
              }
            },
          ];
        }

        data['responses'] = responses;
        data['requestBody'] = requestBody;
        data['parameters'] = parameters;

        res[method.toLowerCase()] = data;
      }
      var standardPath = route.path;
      if (paths.containsKey(standardPath)) {
        res = {...paths[standardPath], ...res};
      }
      paths = {...paths, standardPath: res};
    }

    var data = {
      "openapi": "3.1.0",
      "info": {
        "title": "$title - OpenAPI 3.1",
        "description":
            "Finch Api documentation maker v${FinchApp.info.version}",
        "contact": {"email": "info@uproid.com"},
        "license": {
          "name": "Apache 2.0",
          "url": "http://www.apache.org/licenses/LICENSE-2.0.html"
        },
        "version": config.version
      },
      "externalDocs": {
        "description": "Find out more about Finch",
        "url": rq.url("/")
      },
      "servers": [
        {"url": rq.url("/")}
      ],
      "paths": {
        ...paths,
      },
      "components": {
        "securitySchemes": {
          "auth": {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT",
            "name": security,
            "in": "header"
          },
        }
      }
    };

    return rq.renderData(data: data);
  }

  Future<String> indexPublic() async {
    return index(showPublic: true);
  }

  /// Renders the Swagger UI for the API documentation.
  ///
  /// The [docUrl] parameter specifies the URL of the OpenAPI document.
  /// The [swaggerUIPath] parameter sets the path to the Swagger UI assets.
  /// The [showPublic] parameter controls whether the Swagger UI is shown
  /// publicly or restricted to local debug mode.
  ///
  /// Returns a [Future] that completes with the HTML content for the Swagger UI.
  Future<String> swagger(
    String docUrl, {
    String swaggerUIPath = '/swagger',
    bool showPublic = false,
  }) async {
    var config = FinchApp.config;
    if (showPublic || config.isLocalDebug) {
      return rq.renderView(
        path: /*HTML*/ """<!DOCTYPE html>
                <html lang="en">
                  <head>
                    <meta charset="UTF-8">
                    <title>Swagger UI</title>
                    <link rel="stylesheet" type="text/css" href="${rq.url('$swaggerUIPath/swagger-ui.css')}" />
                    <link rel="stylesheet" type="text/css" href="${rq.url('$swaggerUIPath/index.css')}" />
                    <link rel="icon" type="image/png" href="${rq.url('$swaggerUIPath/favicon-32x32.png')}" sizes="32x32" />
                    <link rel="icon" type="image/png" href="${rq.url('$swaggerUIPath/favicon-16x16.png')}" sizes="16x16" />
                  </head>

                  <body>
                    <div data-url="$docUrl" id="swagger-ui"></div>
                    <script src="${rq.url('$swaggerUIPath/swagger-ui-bundle.js')}" charset="UTF-8"> </script>
                    <script src="${rq.url('$swaggerUIPath/swagger-ui-standalone-preset.js')}" charset="UTF-8"> </script>
                    <script src="${rq.url('$swaggerUIPath/swagger-initializer.js')}" charset="UTF-8"> </script>
                  </body>
                </html>""",
        isFile: false,
      );
    }

    return rq.renderError(403);
  }

  /// Converts a list of [FinchRoute] objects into fully configured routes, applying
  /// parent paths and authentication settings recursively.
  ///
  /// The [routes] parameter contains the list of routes to be converted.
  /// The [parentPath] parameter sets the base path for the routes.
  /// The [auth] parameter specifies the authentication controller for the routes.
  ///
  /// Returns a list of fully configured [FinchRoute] objects.
  List<FinchRoute> _convert(
    List<FinchRoute> routes,
    String parentPath,
    AuthController? auth,
  ) {
    var result = <FinchRoute>[];

    for (final route in routes) {
      route.path = endpointNorm([
        parentPath,
        route.path,
      ]);
      route.auth ??= auth;
      result.add(route);

      if (route.children.isNotEmpty) {
        result.addAll(
          _convert(
            route.children,
            route.path,
            route.auth,
          ),
        );
      }
      var res = _convert(
        FinchRoute.makeList(
          paths: route.extraPath,
          index: route.index,
          apiDoc: route.apiDoc,
          auth: auth,
          children: route.children,
          controller: route.controller,
          excludePaths: route.excludePaths,
          extraPath: [],
          methods: route.methods,
          params: route.params,
          permissions: route.permissions,
          title: route.title,
          widget: route.widget,
          hosts: route.hosts,
          ports: route.ports,
        ),
        parentPath,
        route.auth,
      );
      result.addAll(res);
    }

    return result;
  }
}
