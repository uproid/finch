import 'dart:io';
import 'package:finch/finch_route.dart';
import '../finch_app.dart';
import 'package:mime/mime.dart';
import '../tools/path.dart';

/// A comprehensive route management and request processing system for web applications.
/// The [Route] class serves as the core routing engine that processes incoming HTTP requests,
/// matches them against defined route patterns, and handles the appropriate response rendering.
/// It supports features like nested routing, URL parameters, authentication, permission checks,
/// static file serving, and widget rendering.
/// Key features:
/// - Pattern-based route matching with URL parameters (`{id}`, `{name}`, etc.)
/// - Nested route structures with parent-child relationships
/// - Host and port-based routing restrictions
/// - Authentication and authorization integration
/// - Static file serving from public directory
/// - Widget and controller-based response handling
/// - Automatic MIME type detection for static files
/// Example usage:
/// ```dart
/// final routes = [
///   WebRoute(
///     path: '/api/users/{id}',
///     methods: [RequestMethods.GET],
///     index: () async => handleUserRequest(),
///   ),
/// ];
/// final router = Route(routing: routes);
/// router.handle(); // Process the current request
/// ```
class Route {
  /// A list of [FinchRoute] objects defining the routing paths and configurations.
  List<FinchRoute> routing = [];

  /// An optional [AuthController] instance used for managing authentication.
  AuthController? seenAuth;

  /// The [Request] object representing the current web request.
  Request get rq => Context.rq;

  /// Creates a [Route] instance.
  ///
  /// The [routing] parameter is required to initialize the list of routes, and the [rq]
  /// parameter is required for the current web request.
  Route({required this.routing});

  /// Initiates the route processing workflow for the current request.
  ///
  /// This method serves as the main entry point for route handling. It begins
  /// the route matching process by delegating to [checkAll] with the configured
  /// routing table. The method will attempt to find a matching route pattern
  /// for the current request's path, method, host, and port constraints.
  ///
  /// The routing process follows this hierarchy:
  /// 1. Match route patterns (including URL parameters)
  /// 2. Validate HTTP methods, hosts, and ports
  /// 3. Execute authentication and authorization checks
  /// 4. Render appropriate response (controller, widget, or static file)
  /// 5. Fallback to static file serving or 404 error
  ///
  /// Note: The method name contains a typo and should be `handle()` in future versions.
  void handle() async {
    if (!await checkAll(routing)) {
      _readFromPublic();
    }
  }

  /// Checks all routes to determine if a request matches any defined route.
  ///
  /// The [routing] parameter is a list of [FinchRoute] objects to check. The [parentPath]
  /// parameter is used for constructing nested routes.
  ///
  /// Returns a [Future<bool>] indicating whether a matching route was found. If no match
  /// is found, it attempts to serve static files from the public directory or returns a 404
  /// error if the file is not found. If an error occurs during file access, a 502 error is returned.
  Future<bool> checkAll(
    List<FinchRoute> routing, {
    String parentPath = '',
  }) async {
    for (var i = 0; i < routing.length; i++) {
      var route = routing[i];
      if (route.hosts.isNotEmpty && !route.hosts.contains('*')) {
        if (!route.hosts.contains(rq.host)) {
          continue;
        }
      }

      if (route.ports.isNotEmpty) {
        if (!route.ports.contains(rq.port)) {
          continue;
        }
      }

      List<String> paths = [route.path, ...route.extraPath];
      for (var path in paths) {
        path = joinPaths([parentPath, path]);
        route.setPathRender(path);
        rq.route = route;
        var res = await checkOne(route, path);
        if (res.found) {
          return true;
        }
      }
    }

    return false;
  }

  /// this lines works when nginx is not in local
  /// then it helps to load other files from public
  /// try to use nginx in production for better performance
  /// and security
  bool _readFromPublic() {
    var publicFile = getFileFromPublic(rq.uri.path);
    try {
      if (publicFile.existsSync()) {
        renderFile(publicFile);
        return true;
      }
      rq.renderError(404, toData: rq.isApiEndpoint);
    } catch (e) {
      rq.renderError(502, toData: rq.isApiEndpoint);
    }

    return false;
  }

  /// Checks a single route to see if it matches the given key.
  ///
  /// The [route] parameter is the [FinchRoute] object to check, and the [key] parameter is
  /// the route path to match.
  ///
  /// Returns a [Future] with a tuple containing:
  /// - `found`: A boolean indicating whether a matching route was found.
  /// - `urlParams`: A map of URL parameters extracted from the route.
  Future<({bool found, Map<String, Object?> urlParams})> checkOne(
    FinchRoute route,
    final String key,
  ) async {
    var urlParams = <String, Object?>{};
    final pathClient = Context.rq.uri.path;
    var endpoint = endpointNorm([key]);
    var path = endpointNorm([pathClient]);
    rq.addParams(route.params);

    // Check is param or not
    if (key.contains("{")) {
      var paramPath = getParamsPath(path, endpoint);
      urlParams = paramPath.$2;
      endpoint = paramPath.$1;
    }

    if (endpoint.endsWith('*/')) {
      endpoint = endpoint.replaceAll('*/', '');

      var isTarget = true;
      final starPath = path.replaceFirst(endpoint, '');
      for (var excluded in route.excludePaths) {
        final special = endpointNorm([starPath]);
        excluded = endpointNorm([excluded]);

        if (special.startsWith(excluded)) {
          isTarget = false;
          break;
        }
      }

      if (isTarget && path.endsWith(starPath)) {
        path = path.replaceFirst(starPath, '');
      }
    }

    if (endpoint == path) {
      if (!route.allowMethod()) {
        return (found: false, urlParams: urlParams);
      }

      if (route.widget.isNotEmpty) {
        if (!await checkPermission(seenAuth)) {
          return (found: false, urlParams: urlParams);
        }
        rq.addParams(urlParams);
        renderWidget(route.widget);
        return (found: true, urlParams: urlParams);
      }

      if (route.auth != null) {
        seenAuth = route.auth;
        var res = await route.auth!.auth();
        if (res == false) return (found: false, urlParams: urlParams);
      }

      if (route.index == null) {
        if (route.controller != null) {
          if (!await checkPermission(seenAuth)) {
            return (found: false, urlParams: urlParams);
          }
          rq.addParams(urlParams);

          await route.controller!.index();
          return (found: true, urlParams: urlParams);
        } else {
          return (found: false, urlParams: urlParams);
        }
      } else {
        if (!await checkPermission(seenAuth)) {
          return (found: false, urlParams: urlParams);
        }
        rq.addParams(urlParams);
        await route.index!();
        return (found: true, urlParams: urlParams);
      }
    } else if (route.children.isNotEmpty && path.contains(endpoint)) {
      if (route.auth != null) {
        seenAuth = route.auth;
        var res = await route.auth!.auth();
        if (res == false) return (found: false, urlParams: urlParams);
      }
      if (await checkAll(route.children, parentPath: key)) {
        return (found: true, urlParams: urlParams);
      }
    }
    return (found: false, urlParams: urlParams);
  }

  /// Checks if the current request has the required permissions.
  ///
  /// The [auth] parameter is an optional [AuthController] used for permission checking.
  ///
  /// Returns a [Future<bool>] indicating whether the permission check was successful.
  Future<bool> checkPermission(AuthController? auth) async {
    if (auth == null) {
      return true;
    }
    var res = await auth.checkPermission();

    if (!res) {
      rq.renderError(403, message: 'Access denied!', toData: rq.isApiEndpoint);
    }
    return res;
  }

  /// Retrieves a file from the public directory based on the provided path.
  ///
  /// The [path] parameter specifies the file path relative to the public directory.
  ///
  /// Returns a [File] object representing the file.
  File getFileFromPublic(String path) {
    String longPath = getPublicDirectory(path);
    return File(longPath);
  }

  /// Renders a file by streaming its content to the response.
  ///
  /// The [file] parameter is the [File] object to render.
  void renderFile(File file) {
    var fileStream = file.openRead();

    rq.response.headers
        .set('Content-type', lookupMimeType(file.path).toString());
    rq.response.addStream(fileStream).then((value) async {
      await rq.writeAndClose('');
    });
  }

  /// Constructs the full path to a file in the public directory.
  ///
  /// The [filePath] parameter is the relative path to the file.
  ///
  /// Returns the absolute path as a [String].
  String getPublicDirectory(String? filePath) {
    return pathTo("${FinchApp.config.publicDir}/$filePath");
  }

  /// Renders a widget-based view for the current request.
  ///
  /// This method handles the rendering of template-based responses using the
  /// configured view system. The widget is typically an HTML template that
  /// can include dynamic content and template engine features.
  ///
  /// [uri] The path to the widget/template file to render, relative to the
  /// configured views directory. The file should be a valid template supported
  /// by the view engine (e.g., HTML, Jinja2, etc.).
  ///
  /// The rendered content is automatically sent as the HTTP response with
  /// appropriate content-type headers.
  void renderWidget(String uri) {
    rq.renderView(
      path: uri,
    );
  }

  /// Extracts URL parameters from route patterns and matches them with request paths.
  ///
  /// This method performs pattern matching between a client's requested path and
  /// a server-defined route pattern that contains parameter placeholders. It
  /// supports dynamic URL segments defined with curly braces (e.g., `{id}`, `{slug}`).
  ///
  /// The matching process:
  /// 1. Compares path segment counts (must be equal)
  /// 2. Identifies parameter placeholders in the route pattern
  /// 3. Extracts corresponding values from the client path
  /// 4. Builds a parameter map with extracted values
  ///
  /// [clientPath] The actual path from the incoming HTTP request
  /// [serverPath] The route pattern with parameter placeholders (e.g., `/users/{id}/posts/{slug}`)
  ///
  /// Returns a record containing:
  /// - `$1`: The processed server path with placeholders replaced by actual values
  /// - `$2`: A map of parameter names to their extracted values
  ///
  /// Example:
  /// ```dart
  /// final result = getParamsPath('/users/123/posts/hello-world', '/users/{id}/posts/{slug}');
  /// // result.$1 = '/users/123/posts/hello-world'
  /// // result.$2 = {'id': '123', 'slug': 'hello-world'}
  /// ```
  (String, Map<String, Object?>) getParamsPath(
    String clientPath,
    String serverPath,
  ) {
    String resultKey = serverPath;
    Map<String, Object?> resultParams = {};

    var serverUri = Uri(path: serverPath);
    var clientUri = Uri(path: clientPath);

    if (serverUri.pathSegments.length != clientUri.pathSegments.length) {
      return (resultKey, resultParams);
    }

    for (int i = 0; i < clientUri.pathSegments.length; i++) {
      var key = Uri.decodeFull(serverUri.pathSegments[i]);
      if (!key.startsWith("{") || !key.endsWith("}")) {
        continue;
      } else {
        key = key.replaceAll("{", "").replaceAll("}", "");
        resultKey = resultKey.replaceFirst("{$key}", clientUri.pathSegments[i]);
        resultParams[key] = clientUri.pathSegments[i];
      }
    }

    return (resultKey, resultParams);
  }
}
