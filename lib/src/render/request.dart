// ignore_for_file: type_literal_in_constant_pattern

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:finch/src/tools/convertor/html_formatter.dart';
import 'package:finch/src/views/htmler.dart';
import 'package:finch/src/widgets/finch_string_widget.dart';
import 'package:finch/src/widgets/widget_dump.dart';
import 'package:finch/src/widgets/widget_inline_dump.dart';
import 'package:finch/finch_model_less.dart';
import 'package:finch/src/tools/console.dart';
import 'package:finch/src/tools/convertor/query_string.dart';
import 'package:finch/src/tools/convertor/safe_string.dart';
import 'package:finch/src/tools/convertor/serializable/value_converter/json_value.dart';
import 'package:finch/src/tools/convertor/string_validator.dart';
import 'package:finch/src/tools/convertor/translate_string.dart';
import 'package:finch/src/tools/path.dart';
import 'package:finch/src/widgets/widget_error.dart';
import 'package:intl/intl.dart';
import 'package:jinja/jinja.dart';
import 'package:jinja/loaders.dart';
import 'package:mime/mime.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:finch/finch_route.dart';
import 'package:finch/finch_app.dart';

/// Handles HTTP request processing and response generation for the Finch framework.
/// [Request] is the core class responsible for processing incoming HTTP requests
/// and generating appropriate responses. It provides a comprehensive API for:
/// **Request Processing:**
/// - HTTP method and URI handling
/// - Header and cookie management
/// - Query parameter and form data parsing
/// - File upload processing
/// - Session management
/// **Response Generation:**
/// - Template rendering with Jinja engine
/// - JSON and XML response formatting
/// - File serving and downloads
/// - Redirect handling
/// - Error page generation
/// **Framework Integration:**
/// - Asset management (CSS, JS)
/// - Multi-language support
/// - Security features (CORS, authentication)
/// - Database integration helpers
/// - Widget system integration
/// **Template Engine Features:**
/// - Jinja2-compatible template syntax
/// - Dynamic content injection
/// - Layout and partial support
/// The class uses a buffer-based approach for content generation, allowing
/// for efficient string building and content manipulation before sending
/// the final response to the client.
/// Example usage:
/// ```dart
/// // In a controller or route handler:
/// Future<String> handleRequest() async {
///   final data = await service.getData();
///   return rq.renderJson(data);
/// }
/// // Template rendering:
/// Future<String> renderPage() async {
///   return rq.renderView(
///     path: 'user/profile.html',
///     params: {'user': currentUser, 'title': 'Profile'},
///   );
/// }
/// ```
class Request {
  StringBuffer buffer = StringBuffer();

  /// The [HttpRequest] instance associated with this request.
  final HttpRequest _rq;
  var _defaultContentType = ContentType.html;
  static FinchStringWidget errorWidget = ErrorWidget();

  /// Manages assets like JavaScript and CSS for rendering.
  late final AssetManager assetManager = AssetManager();

  /// Indicates whether the response has been closed.
  var isClosed = false;

  set contentType(ContentType contentType) {
    _defaultContentType = contentType;
  }

  /// Stores the application settings for the request.
  static Map<String, Object?> _setting = {};

  /// The route associated with the request, if any.
  FinchRoute? route;

  /// Constructor to initialize the WebRequest with the given [HttpRequest].
  Request(this._rq);

  @override
  String toString() {
    return 'Instance of WebRequest: ${_rq.method} ${_rq.uri}';
  }

  /// Provides access to the underlying [HttpRequest].
  HttpRequest get httpRequest => _rq;

  /// Provides access to the session associated with the request.
  HttpSession get session => _rq.session;

  /// Provides access to the list of cookies included in the request.
  List<Cookie> get cookies => _rq.cookies;

  /// Provides access to the request stream.
  HttpRequest get stream => _rq;

  /// Provides access to the URI of the request.
  Uri get uri => _rq.uri;

  /// Provides access to the response associated with the request.
  HttpResponse get response => _rq.response;

  /// Provides access to the HTTP method (e.g., GET, POST) used in the request.
  String get method => _rq.method;

  /// Check method is Post
  bool get isPost => method == Methods.POST;

  /// Provides access to the HTTP headers included in the request.
  HttpHeaders get headers => _rq.headers;

  /// Sets application-specific settings for the request.
  ///
  /// If the `theme` cookie is present, it updates the theme setting accordingly.
  void setSetting(Map<String, Object?> setting) {
    ///To change theme when Cookie of theme is seted.
    var theme = getCookie(
      'theme',
      def: (setting['theme'] ?? 'light').toString(),
      safe: false,
    );
    if (['light', 'dark'].contains(theme)) {
      setting['theme'] = theme;
    }

    _setting = {
      ...setting,
    };
  }

  /// Initializes the request by setting response headers and parsing data.
  ///
  /// Returns the [Request] instance after initialization.
  Future<Request> init() async {
    _rq.response.headers.add('Access-Control-Allow-Origin', "*");
    _rq.response.headers.add(
      'Access-Control-Allow-Methods',
      'GET,HEAD,OPTIONS,POST,PUT,DELETE',
    );
    _rq.response.headers.add('Access-Control-Allow-Headers',
        'Origin, X-Requested-With, Content-Type, Accept, x-client-key, x-client-token, x-client-secret, Authorization');
    _rq.response.headers.add('Access-Control-Allow-Credentials', 'true');
    _rq.response.headers.add('X-Powered-By', FinchApp.config.poweredBy);
    await parseData();
    return this;
  }

  /// Holds parsed request data for GET, POST, content, and files.
  Map<String, dynamic> _dataRequest = {
    'POST': {},
    'GET': {},
    'CONTENT': '',
    'FILE': '',
  };

  /// Changes the language based on the given language code [ln].
  void changeLanguege(String ln) {
    addCookie('language', ln, safe: false);
    addSession('language', ln);
  }

  /// Retrieves the current language based on URI, session, or settings.
  String getLanguage() {
    var ln = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : '';
    if (ln.isNotEmpty && FinchApp.config.languages.contains(ln)) {
      changeLanguege(ln);
      return ln;
    }

    if (isApiEndpoint && hasData('lang')) {
      return data('lang', def: 'en');
    }

    ln = getCookie(
      'language',
      safe: false,
      def: getSession(
        'language',
        def: _setting['language'] ?? 'en',
      ).toString(),
    );

    return ln.trim().toLowerCase();
  }

  /// Writes the [layout] to the response and closes it.
  ///
  /// This method ensures the response is not written if it is already closed.
  Future writeAndClose(String layout) async {
    if (isClosed) return;

    layout = onClose(layout);
    response.write(layout);
    await _close();
  }

  /// Handles tasks to be performed before closing the response.
  ///
  /// This includes replacing placeholders for assets like JS and CSS in [layout].
  String onClose(String layout) {
    // 1. Replace assets values.
    if (dataJsId.isNotEmpty) {
      layout = layout.replaceFirst(dataJsId, assetManager.getDataJs());
    }
    // 2. Reolace assets url Js, Css
    if (cssRenderId.isNotEmpty) {
      layout = layout.replaceFirst(cssRenderId, assetManager.getCssUI());
    }
    if (jsRenderId.isNotEmpty) {
      layout = layout.replaceAll(jsRenderId, assetManager.getJsUI());
    }
    return layout;
  }

  /// Closes the response if it hasn't been closed yet.
  Future _close() async {
    if (!isClosed) {
      isClosed = true;
      await _rq.response.close();
    }
  }

  /// Parses and returns request data from GET, POST, and file fields.
  ///
  /// The result is stored in [_dataRequest].
  Future<Map> parseData() async {
    Map<String, dynamic> post = {};
    Map<String, dynamic> get = {};
    Map<String, dynamic> file = {};
    String content = "";

    // For GET
    var params = _rq.uri.queryParameters;
    get.addAll(_checkValues<Map<String, dynamic>>(params));

    // For POST or PUT
    if (method == Methods.POST || method == Methods.PUT) {
      // Form Forms
      if (headers.contentType
          .toString()
          .toLowerCase()
          .contains("application/x-www-form-urlencoded")) {
        try {
          content = await utf8.decoder.bind(stream).join();
          var body = QueryString.parse(content);
          post.addAll(_checkValues(body));
        } catch (e) {
          Console.e(e);
        }
      } else if (headers.contentType
          .toString()
          .toLowerCase()
          .contains("multipart/form-data")) {
        var data = await getHeaderFormData();
        post.addAll(_checkValues(data['fields']));
        file.addAll(data['files']);
      } else if (headers.contentType
          .toString()
          .toLowerCase()
          .contains("application/json")) {
        try {
          content = await utf8.decoder.bind(stream).join();
          var data = jsonDecode(content);
          post.addAll(_checkValues(data));
        } catch (e) {
          Console.e(e);
        }
      } else {
        try {
          var bodyBytes = await stream
              .fold<List<int>>([], (bytes, chunk) => bytes..addAll(chunk));
          content = String.fromCharCodes(bodyBytes);
        } catch (e) {
          Console.e(e);
        }
      }
    }
    _dataRequest = {
      'POST': post,
      'GET': get,
      'FILE': file,
      'CONTENT': content,
    };

    return _dataRequest;
  }

  R _checkValues<R>(R value) {
    return value;
  }

  /// Safely escapes HTML special characters in the input string.
  /// &lt;a href=&quot;javascript:alert(null)&quot;&gt;&lt;/a&gt;
  /// Will be converted to: `&lt;a href=&quot;javascript:alert(null)&quot;&gt;&lt;/a&gt;`
  String safe(String input) {
    return htmlEscape.convert(input);
  }

  Map<String, Object?> get _allData => <String, Object?>{
        ..._dataRequest['GET']!,
        ..._dataRequest['POST'],
        'POST': _dataRequest['POST'],
        'GET': _dataRequest['GET'],
        'FILE': _dataRequest['FILE'],
      };

  /// Retrieves all parsed request data including GET, POST, and FILE data.
  Map<String, Object?> getAllData({
    List<String> keys = const [],
    bool trim = true,
  }) {
    return getAll();
  }

  /// Retrieves form data including fields and files
  /// Returns a map with 'fields' and 'files' keys.
  /// `keys` in 'fields' contains form fields and their values.
  /// `trim` indicates whether to trim string values.
  Map<String, Object?> getAll({
    List<String> keys = const [],
    bool trim = true,
  }) {
    var all = _allData;
    if (keys.isNotEmpty) {
      var result = <String, Object?>{};
      for (var key in keys) {
        result[key] = get(key, trim: trim);
      }
      return result;
    } else if (trim) {
      all.forEach((key, value) {
        if (value is String) {
          all[key] = value.trim();
        }
      });
    }
    return all;
  }

  /// Retrieves the value associated with [key] from the request data.
  ///
  /// The value is sanitized to prevent script injection. An optional [def]
  /// (default value) can be provided if the key is not found.
  String data(String key, {String def = '', bool trim = true}) {
    ModelLess modelLess = ModelLess.fromMap(getAll());

    String res = modelLess.get<String>(key, def: def);
    return trim ? res.removeScripts().trim() : res.removeScripts();
  }

  /// Retrieves the value associated with [key] as an object from the request data.
  dynamic dataObject(String key, {dynamic def}) {
    var map = getAll(keys: [key]);
    return map[key] ?? def;
  }

  /// Retrieves the value associated with [key] from the request data, cast to type [T].
  T dataType<T>(String key, {T? def}) {
    var map = getAll();
    T res = map[key].asCast<T>(def: def) as T;
    return res;
  }

  /// Retrieves file data associated with [key] from the request.
  dynamic getFile(String key) {
    var map = _allData;
    if (map['FILE'] != null) {
      Object? res = map['FILE'];
      if (res is Map) {
        return res[key];
      }
    }
    return null;
  }

  /// Overloads the index operator to return the value for [key] using [data].
  String operator [](String key) {
    return data(key);
  }

  /// Checks if [key] exists in the request data.
  bool hasData(String key) => _allData.containsKey(key);

  /// Checks if [key] exists and has a non-empty value in the request data.
  bool hasDataValue(String key) =>
      _allData.containsKey(key) && this[key].isNotEmpty;

  /// Retrieves the value of [key] cast to type [T]. Supports type-specific operations.
  ///
  /// Supported types include [List], [bool], [int], [double], and [String].
  T get<T>(String key, {T? def, trim = true}) {
    switch (T) {
      case List:
        var res = dataObject(key, def: def);
        if (res is List) {
          return res as T;
        }
        if (res is String && res.isNotEmpty) {
          return FinchJson.tryJsonList(res, def: (def ?? []) as List) as T;
        }
        if (def != null) return def;
        return [] as T;
      case num:
        var res = (num.tryParse(data(key, trim: trim)) ?? -1);
        if (def != null && res == -1) return def;
        return res as T;
      case int:
        var res = (int.tryParse(data(key, trim: trim)) ?? -1);
        if (def != null && res == -1) return def;
        return res as T;
      case bool:
        if (!hasData(key)) {
          return (def ?? false) as T;
        }
        return data(key, trim: trim).toBool as T;
      case String:
        var res = data(key, trim: trim).toString();
        if (res.isEmpty && def != null) return def;
        return res as T;
      case double:
        var res = data(key, trim: trim).toString().asDouble();
        return res as T;
      default:
        return data(key, trim: trim) as T;
    }
  }

  /// Retrieves the value of [key] as a [String] from the request data.
  /// If the value is not found, returns [def] (default value).
  /// This method is used to retrieve string values from the request data.
  T? tryData<T>(String key, {T? def, bool trim = true}) {
    if (hasData(key)) {
      return get<T>(key, def: def, trim: trim);
    } else {
      return def;
    }
  }

  /// Renders an error view with the specified status and parameters.
  ///
  /// This method handles setting error-related parameters and generating the
  /// appropriate error view based on the [status] and other parameters.
  ///
  /// [status] - The HTTP status code for the error.
  /// [params] - Optional map of additional parameters to be added. Default is an empty map.
  /// [message] - Optional error message to be included. Default is an empty string.
  /// [toData] - Flag indicating whether to include the success parameter in the response. Default is false.
  ///
  /// Returns a [Future<String>] containing the rendered error view.
  Future<String> renderError(
    int status, {
    Map<String, Object?> params = const {},
    String message = '',
    bool toData = false,
  }) {
    if (message.isNotEmpty) {
      addParam('error', message);
    } else if (toData && !hasParam('success')) {
      if (!hasParam('message')) {
        addParam('message', status == 404 ? 'error.notfound' : 'error.$status');
      }
      addParam('success', false);
    }

    if (Console.isDebug) {
      addParams(params);
    }

    addParam('status', status);
    return renderView(
      path: errorWidget.generateHtml != null
          ? errorWidget.generateHtml!(getParams()).toHtml()
          : errorWidget.layout,
      status: status,
      isFile: false,
      toData: toData,
    );
  }

  Future<String> dump(dynamic object) async {
    addParam('output', object);
    response.headers.contentType = ContentType.html;
    var html = DumpWodget().generateHtml!({}).toHtml();
    var output = await renderView(
      path: html,
      isFile: false,
    );
    await writeAndClose(output);
    return "";
  }

  /// A model-less object holding parameters for the request.
  final ModelLess _params = ModelLess(fields: {
    'timestamp_start': DateTime.now().millisecondsSinceEpoch,
  });

  /// Retrieves the value of a parameter.
  ///
  /// [key] - The key of the parameter to retrieve.
  /// [def] - Optional default value to return if the parameter is not found. Default is null.
  ///
  /// Returns the value of the parameter if it exists, otherwise returns [def].
  Object? getParam(String key, {Object? def}) {
    return _params[key] ?? def;
  }

  /// Checks if a parameter exists.
  ///
  /// [key] - The key of the parameter to check.
  ///
  /// Returns true if the parameter exists, otherwise returns false.
  bool hasParam(String key) {
    return _params.fields.keys.contains(key);
  }

  /// Retrieves all parameters as a map.
  ///
  /// Returns a map containing all the parameters.
  Map<String, dynamic> getParams() {
    return _params.fields;
  }

  /// A map holding validators for different forms.
  final _validator = <String, Object?>{};

  /// Retrieves the validators map.
  ///
  /// Returns a map of validators for various forms.
  Map<String, Object?> getValidator() {
    return _validator;
  }

  /// Adds a validator for a specific form.
  ///
  /// [formName] - The name of the form for which the validator is added.
  /// [validator] - The map containing validation rules for the form.
  void addValidator(String formName, Map<String, dynamic> validator) {
    _validator[formName] = validator;
  }

  /// Adds multiple parameters to the request.
  ///
  /// [params] - A map of parameters to be added.
  ///
  /// Returns the current [Request] instance for method chaining.
  Request addParams(Map<String, Object?> params) {
    params.forEach((key, value) {
      _params[key] = value;
    });
    return this;
  }

  /// Adds a single parameter to the request.
  ///
  /// [key] - The key of the parameter to add.
  /// [param] - The value of the parameter to add.
  ///
  /// Returns the current [Request] instance for method chaining.
  Request addParam(String key, Object? param) {
    _params[key] = param;
    return this;
  }

  /// Removes a parameter from the request.
  ///
  /// [key] - The key of the parameter to remove.
  ///
  /// Returns the current [Request] instance for method chaining.
  Request removeParam(String key) {
    _params.remove(key);
    return this;
  }

  // Placeholder for the renderView method
  /// after this function everything will be stop and send to client
  Future<String> renderView({
    required String path,
    int status = 200,
    bool isFile = true,
    bool toData = false,
    Map<String, dynamic> data = const {},
    bool writeAndClose = true,
  }) async {
    if (isClosed) return '';

    if (toData) {
      return renderDataParam(status: status, data: data);
    }

    try {
      response.statusCode = status;
      response.headers.contentType = _defaultContentType;
    } catch (e) {
      Console.i(e);
    }
    var renderString = await render(path: path, isFile: isFile);
    if (writeAndClose) {
      await this.writeAndClose(renderString);
    }
    return renderString;
  }

  /// Renders a [Tag] object to HTML and sends it in the response.
  /// You can use this method to render any HTML tag or widget that implements the [Tag] interface.
  /// This method converts the [Tag] to an HTML string and then calls [renderView] to handle the response.
  /// [status] - The HTTP status code to be used. Default is 200.
  /// [toData] - A flag indicating whether to render the data as a parameter. Default is false.
  /// [data] - A map of parameters to be passed to the template. Default is an empty map.
  /// [pretty] - A flag indicating whether to pretty-print the HTML output. Default is false.
  /// Returns a [Future<String>] containing the rendered HTML string.
  Future<String> renderTag({
    required Tag tag,
    int status = 200,
    bool toData = false,
    Map<String, dynamic> data = const {},
    bool pretty = false,
  }) async {
    var htmlString = tag.toHtml();
    htmlString = await renderView(
      path: htmlString,
      isFile: false,
      status: status,
      toData: toData,
      data: data,
      writeAndClose: false,
    );
    if (pretty) {
      htmlString = HtmlFormatter.format(htmlString, indent: '\t');
    }
    await writeAndClose(htmlString);
    return htmlString;
  }

  /// Renders a template with the given parameters and configuration.
  ///
  /// This method supports rendering from a file or a raw template string. It can handle
  /// different types of rendering based on the [isFile] and [toData] parameters. It also
  /// manages the localization and filtering of data.
  ///
  /// [path] - The path or content of the template to be rendered. If [isFile] is true, this should be the file path.
  /// [viewParams] - A map of parameters to be passed to the template. Default is an empty map.
  /// [isFile] - A flag indicating whether [path] refers to a file (true) or a string template (false). Default is true.
  /// [toData] - A flag indicating whether to render the data as a parameter. Default is false.
  /// [status] - The HTTP status code to be used. Default is 200.
  ///
  /// Returns a [Future<String>] containing the rendered template as a string.
  Future<String> render({
    required String path,
    Map<String, Object?> viewParams = const {},
    bool isFile = true,
    bool toData = false,
    int status = 200,
  }) async {
    if (isClosed) return '';
    if (toData) {
      return renderDataParam(status: status, data: viewParams);
    }

    if (isFile) {
      File file = File(joinPaths([
        FinchApp.config.widgetsPath,
        "$path.${FinchApp.config.widgetsType}",
      ]));

      if (!file.existsSync()) {
        if (FinchApp.config.isLocalDebug) {
          return "The path: ${file.path} is not correct!";
        } else {
          return "The path: ${file.uri.pathSegments.last} is not correct!";
        }
      }
    }

    var env = getTemplateEnvironment();
    var params = getParams();
    params.addAll(viewParams);
    Template template;
    if (isFile) {
      template = env.getTemplate(File(
        joinPaths([
          FinchApp.config.widgetsPath,
          "$path.${FinchApp.config.widgetsType}",
        ]),
      ).path);
    } else {
      template = env.fromString(path);
    }
    var renderString = template.render(params);
    if (buffer.isNotEmpty &&
        response.headers.contentType?.mimeType == 'text/html') {
      renderString += buffer.toString();
      buffer.clear();
    }
    return renderString;
  }

  /// Render SSE (Server-Sent Events) stream to the client.
  /// This method sets up the necessary headers for SSE and streams data to the client.
  /// The [stream] function should return a stream of strings to be sent as SSE messages.
  /// Each message is formatted according to the SSE protocol.
  /// The connection is kept alive until the stream is closed.
  /// Returns a [Future<String>] that completes when the stream is closed.
  Future<String> renderSSE(
    Stream<SSE> stream, {
    ContentType? contentType,
    int status = HttpStatus.ok,
    Map<String, String>? headers,
    SSE? finish,
  }) async {
    contentType ??= ContentType('text', 'event-stream', charset: 'utf-8');

    headers ??= {
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
      'X-Accel-Buffering': 'no', // For Nginx
    };

    headers.forEach((key, value) {
      response.headers.set(key, value);
    });

    response.statusCode = status;
    response.headers.contentType = contentType;
    response.bufferOutput = false;

    await for (var sse in stream) {
      response.write(sse.toString());
      await response.flush();
    }

    finish ??= SSE(
      event: 'end',
      data: 'end',
      id: '-1',
      retry: 999999999999,
    );

    response.write(finish.toString());
    await response.flush();
    await response.close();
    return ""; // Return empty string for SSE completion
  }

  /// Render SSE (Server-Sent Events) stream to the client.
  /// This method sets up the necessary headers for SSE and streams data to the client.
  /// The [stream] function should return a stream of strings to be sent as SSE messages.
  /// Each message is formatted according to the SSE protocol.
  /// The connection is kept alive until the stream is closed.
  /// Returns a [Future<String>] that completes when the stream is closed.
  Future<String> renderSSEString(
    Stream<String> stream, {
    ContentType? contentType,
    int status = HttpStatus.ok,
    Map<String, String>? headers,
  }) async {
    contentType ??= ContentType('text', 'event-stream', charset: 'utf-8');

    headers ??= {
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
      'X-Accel-Buffering': 'no', // For Nginx
    };

    headers.forEach((key, value) {
      response.headers.set(key, value);
    });

    response.statusCode = status;
    response.headers.contentType = contentType;
    response.bufferOutput = false;

    await for (var sse in stream) {
      response.write(sse.toString());
      await response.flush();
    }

    await response.close();
    return ""; // Return empty string for SSE completion
  }

  /// Renders a template with the given parameters and configuration.
  ///
  /// This method supports rendering from a file or a raw template string. It can handle
  /// different types of rendering based on the [isFile] and [toData] parameters. It also
  /// manages the localization and filtering of data.
  ///
  /// [path] - The path or content of the template to be rendered. If [isFile] is true, this should be the file path.
  /// [viewParams] - A map of parameters to be passed to the template. Default is an empty map.
  /// [isFile] - A flag indicating whether [path] refers to a file (true) or a string template (false). Default is true.
  /// [status] - The HTTP status code to be used. Default is 200.
  ///
  /// Returns a [Future<String>] containing the rendered template as a string.
  String renderAsync({
    required String path,
    Map<String, Object?> viewParams = const {},
    bool isFile = true,
    int status = 200,
  }) {
    if (isClosed) return '';

    if (isFile) {
      File file = File(joinPaths([
        FinchApp.config.widgetsPath,
        "$path.${FinchApp.config.widgetsType}",
      ]));

      if (!file.existsSync()) {
        if (FinchApp.config.isLocalDebug) {
          return "The path: ${file.path} is not correct!";
        } else {
          return "The path: ${file.uri.pathSegments.last} is not correct!";
        }
      }
    }

    var env = getTemplateEnvironment();
    var params = getParams();
    params.addAll(viewParams);
    Template template;
    if (isFile) {
      template = env.getTemplate(File(
        joinPaths([
          FinchApp.config.widgetsPath,
          "$path.${FinchApp.config.widgetsType}",
        ]),
      ).path);
    } else {
      template = env.fromString(path);
    }
    var renderString = template.render(params);
    return renderString;
  }

  Environment getTemplateEnvironment() {
    return Environment(
        globals: getGlobalEvents(),
        autoReload: false,
        loader: FileSystemLoader(paths: <String>[FinchApp.config.widgetsPath]),
        leftStripBlocks: false,
        trimBlocks: false,
        blockStart: FinchApp.config.blockStart,
        blockEnd: FinchApp.config.blockEnd,
        variableStart: FinchApp.config.variableStart,
        variableEnd: FinchApp.config.variableEnd,
        commentStart: FinchApp.config.commentStart,
        commentEnd: FinchApp.config.commentEnd,
        filters: {
          ..._layoutFilters,
          'safe': (dynamic input) => safe(input.toString()),
          'unscape': (dynamic input) => input.toString().unescape(),
          'html': (dynamic input) => input.toString().unescape(),
        },
        getAttribute: (String key, dynamic object) {
          try {
            if (object is TString) {
              return object.write();
            }
            if (object is String && key == 'tr') {
              return object.tr.write();
            }
            if (object is Cookie) {
              return key == 'name' ? object.name : object.value;
            }

            if (object[key] != null) {
              if (object[key] is ObjectId) {
                return (object[key] as ObjectId).oid;
              }
            }
            if (object[key] is String) {
              return safe(object[key]);
            }
            return object[key];
          } on NoSuchMethodError {
            Console.e({
              'error': {
                'object': object,
                'key': key,
                'error': 'The key "$key" on "$object" not found',
              }
            });

            return null;
          } catch (e) {
            Console.w({
              'error': {
                'object': object,
                'key': key,
                'error': e,
              }
            });
            return null;
          }
        });
  }

  static final Map<String, Function> _layoutFilters = {
    'dateFormat': (dynamic dt, String format) {
      try {
        if (dt is DateTime) return DateFormat(format).format(dt);
        if (dt is String) return DateFormat(format).format(DateTime.parse(dt));
      } catch (e) {
        Console.e(e);
      }
      return dt.toString();
    },
    'oid': (Object? id) {
      if (id is ObjectId?) {
        return id?.oid;
      } else if (id is List<ObjectId?>) {
        return List<String>.from(id.map((e) => e?.oid));
      } else {
        return id;
      }
    },
    'safe': (dynamic input) {
      return htmlEscape.convert(input.toString());
    },
    'json': (Object? value) {
      return FinchJson.jsonEncoder(value!);
    },
    'json_decode': (Object? value) {
      return FinchJson.jsonDecoder(value.toString().unescape());
    },
    'bool': (Object? value) {
      return value.toString().toBool;
    },
    'isFalse': (Object? value) {
      String val = value.toString().trim().toLowerCase();
      return val != '' && (val == '0' || val == 'false' || val == 'no');
    },
    'isTrue': (Object? value) {
      return value.toString().toBool;
    },
    'check': (Object? value, Object? t, [Object? f = '']) {
      return value.toString().toBool ? t : f;
    },
  };

  static Map<String, Function> get layoutFilters => _layoutFilters;
  static void addLocalLayoutFilters(Map<String, Function> filters) {
    _layoutFilters.addAll(filters);
  }

  /// currently it just support the Basic Authentication
  /// You can develop the `Authorization` class.
  Authorization get authorization {
    var authString = headers.value(HttpHeaders.authorizationHeader) ?? '';
    return Authorization.parse(authString);
  }

  /// Handles rendering of data with additional parameters and status code.
  ///
  /// This method combines the existing parameters and validators with the provided
  /// data and renders it using the `renderData` method.
  ///
  /// [status] - The HTTP status code to be used for the rendering context. Default is 200.
  /// [data] - A map of additional data to be included in the rendering. Default is an empty map.
  ///
  /// Returns a [Future<String>] containing the rendered data as a string.
  Future<String> renderDataParam({
    int status = 200,
    Map<String, Object?> data = const {},
  }) {
    return renderData(
      data: {
        ...getParams(),
        ...getValidator(),
        ...data,
      },
      status: status,
    );
  }

  /// Renders a list of data as JSON and sends it in the response.
  ///
  /// Sets the HTTP status code and content type for the response. Encodes the provided data
  /// into a JSON string and writes it to the response. Handles errors and sets the status code
  /// to 502 in case of failure.
  ///
  /// [data] - A list of maps containing the data to be rendered as JSON.
  /// [status] - The HTTP status code to be set for the response. Default is 200.
  ///
  /// Returns a [Future<String>] containing the JSON string of the rendered data.
  Future<String> renderListData({
    required List<Map<String, Object?>> data,
    int status = 200,
  }) async {
    try {
      try {
        response.statusCode = status;
        response.headers.contentType = ContentType.json;
      } catch (e) {
        Console.i(e);
      }

      var renderString = FinchJson.jsonEncoder(data);
      await writeAndClose(renderString);
      return renderString;
    } catch (e) {
      try {
        response.statusCode = 502;
        response.headers.contentType = ContentType.json;
      } catch (e) {
        Console.i(e);
      }

      return jsonEncode({
        'status': 502,
        'error': e,
      });
    }
  }

  /// Renders a map of data as JSON and sends it in the response.
  ///
  /// Sets the HTTP status code and content type for the response. Encodes the provided data
  /// into a JSON string and writes it to the response. Handles errors and sets the status code
  /// to 502 in case of failure.
  ///
  /// [data] - A map containing the data to be rendered as JSON.
  /// [status] - The HTTP status code to be set for the response. Default is 200.
  ///
  /// Returns a [Future<String>] containing the JSON string of the rendered data.
  Future<String> renderData({
    required Map<String, Object?> data,
    int status = 200,
  }) async {
    try {
      try {
        response.statusCode = status;
        response.headers.contentType = ContentType.json;
      } catch (e) {
        Console.i(e);
      }

      var renderString = FinchJson.jsonEncoder(data);
      await writeAndClose(renderString);
      return renderString;
    } catch (e) {
      try {
        response.statusCode = 502;
        response.headers.contentType = ContentType.json;
      } catch (e) {
        Console.i(e);
      }

      return jsonEncode({
        'status': 502,
        'error': e,
      });
    }
  }

  /// Renders a socket request. Currently, this method only returns a string.
  /// this mean it will make a fake string to wait for socket response.
  String renderSocket() => 'Socket is requested!';

  /// Renders a plain text response.
  ///
  /// Sets the HTTP status code and content type for the response. Writes the provided text
  /// to the response and handles errors by logging them and returning a default error string.
  ///
  /// [text] - The text to be rendered in the response.
  /// [status] - The HTTP status code to be set for the response. Default is 200.
  /// [contentType] - The content type to be set for the response. Defaults to `ContentType.text` if not provided.
  ///
  /// Returns a [Future<String>] containing the rendered text.
  Future<String> renderString({
    required String text,
    int status = 200,
    ContentType? contentType,
  }) async {
    try {
      try {
        response.statusCode = status;
        response.headers.contentType = contentType ?? ContentType.text;
      } catch (e) {
        renderError(502, params: {'error': e});
      }
      await writeAndClose(text);
      return text;
    } catch (e) {
      renderError(502, params: {'error': e});
      return 'console.log("$e");';
    }
  }

  /// Renders an HTML response.
  ///
  /// Calls [renderString] with the `ContentType.html` to render the provided HTML content.
  ///
  /// [html] - The HTML content to be rendered.
  /// [status] - The HTTP status code to be set for the response. Default is 200.
  ///
  /// Returns a [Future<String>] containing the rendered HTML.
  Future<String> renderHtml({
    required String html,
    int status = 200,
  }) async {
    return renderString(
      text: html,
      status: status,
      contentType: ContentType.html,
    );
  }

  /// Redirects the response to the given URI.
  ///
  /// Sets the HTTP status code for the redirect and performs the redirection. Handles
  /// HTTP and HTTPS URLs differently based on the input URI.
  ///
  /// [uri] - The URI to redirect to.
  /// [status] - The HTTP status code to be used for the redirection. Default is 302 (moved temporarily).
  /// [checkApiPath] - A flag indicating whether to prefix the path with `/api` if it's an API endpoint. Default is true.
  ///
  /// Returns a [Future<String>] with a message indicating the redirection status.
  Future<String> redirectUri(
    Uri uri, {
    int status = HttpStatus.movedTemporarily,
    bool checkApiPath = true,
  }) {
    return redirect(
      uri.toString(),
      status: status,
      checkApiPath: checkApiPath,
    );
  }

  /// Redirects the response to the given URI and waits for the redirect to complete.
  ///
  /// Sets the HTTP status code for the redirect and performs the redirection. This method
  /// closes the response and waits for the redirection to complete.
  ///
  /// [uri] - The URI to redirect to.
  /// [status] - The HTTP status code to be used for the redirection. Default is 302 (moved temporarily).
  /// [checkApiPath] - A flag indicating whether to prefix the path with `/api` if it's an API endpoint. Default is true.
  ///
  /// Returns a [Future<String>] with a message indicating the redirection status.
  Future<String> redirectNextUri(
    Uri uri, {
    int status = HttpStatus.movedTemporarily,
    bool checkApiPath = true,
  }) async {
    if (isClosed) {
      return '';
    }
    isClosed = true;
    await response.redirect(
      uri,
      status: status,
    );
    return "Wait to redirect!?";
  }

  /// Redirects the response to the given path.
  ///
  /// Determines whether the path is a full URL or a relative path. If the path is a relative path and
  /// `checkApiPath` is true, it prefixes the path with `/api`. Performs the redirection with the specified
  /// HTTP status code.
  ///
  /// [path] - The path or URL to redirect to.
  /// [status] - The HTTP status code to be used for the redirection. Default is 302 (moved temporarily).
  /// [checkApiPath] - A flag indicating whether to prefix the path with `/api` if it's an API endpoint. Default is true.
  ///
  /// Returns a [Future<String>] with a message indicating the redirection status.
  Future<String> redirect(
    String path, {
    int status = HttpStatus.movedTemporarily,
    bool checkApiPath = true,
  }) async {
    if (isClosed) {
      return '';
    }
    isClosed = true;

    if (path.toLowerCase().startsWith("http") ||
        path.toLowerCase().startsWith("https")) {
      await response.redirect(
        Uri.parse(path),
        status: status,
      );
      return "Wait to redirect!?";
    }

    path = path.replaceAll('//', '/');

    var uri = Uri.parse(path);
    if (checkApiPath && isApiEndpoint) {
      uri = uri.replace(pathSegments: ['api', ...uri.pathSegments]);
    }

    uri = uri.normalizePath();
    await response.redirect(
      uri,
      status: status,
    );
    return "Wait to redirect!?";
  }

  /// Retrieves form data from a `multipart/form-data` request.
  ///
  /// This method processes the multipart form data, extracting fields and files from the request.
  /// Fields are stored as a map of strings, while files are stored as a map of byte lists.
  ///
  /// Returns a [Future<Map<String, dynamic>>] containing:
  /// - `fields`: A map of form fields with their respective values.
  /// - `files`: A map of files with their contents as byte lists.
  Future<Map> getHeaderFormData() async {
    final fields = <String, String>{};
    final files = <String, List<int>>{};

    /// Parse the multipart form data. beacuse some time the requested multipart/form-data is empty
    try {
      final contentType = _rq.headers.contentType;
      if (contentType?.mimeType == 'multipart/form-data') {
        final transformer =
            MimeMultipartTransformer(contentType!.parameters['boundary']!);

        final parts = await transformer.bind(_rq).toList();

        await Future.forEach(parts, (part) async {
          final contentDisposition = part.headers['content-disposition'];
          if (contentDisposition != null) {
            final nameMatch =
                RegExp(r'name="(.+?)"').firstMatch(contentDisposition);
            final filenameMatch =
                RegExp(r'filename="(.+?)"').firstMatch(contentDisposition);
            if (filenameMatch != null) {
              final filename = filenameMatch.group(1) ?? 'unknown';
              final fileBytes = await part
                  .fold<List<int>>([], (bytes, data) => bytes..addAll(data));
              files[nameMatch!.group(1)!] = fileBytes;
              fields["${nameMatch.group(1)!}_filename"] = filename;
            } else {
              final value = await utf8.decodeStream(part);
              fields[nameMatch!.group(1)!] = value;
            }
          }
        });
      }
    } catch (e) {
      Console.w(e);
    }

    return {
      'fields': fields,
      'files': files,
    };
  }

  /// JavaScript render ID for asset management.
  String jsRenderId = '';

  /// CSS render ID for asset management.
  String cssRenderId = '';

  /// Data JavaScript render ID for asset management.
  String dataJsId = '';

  /// Local events map for testing purposes.
  static final localEvents = <String, Object>{
    'test': (a) => "You passed '$a'",
    'macro': (String template, Object? data) {
      if (template.endsWith(FinchApp.config.widgetsType)) {
        template = template.replaceAll(".${FinchApp.config.widgetsType}", '');
      }
      var params = <String, Object?>{};
      if (data is Map) {
        for (var key in data.keys) {
          params[key.toString()] = data[key];
        }
      }
      return Context.rq.renderAsync(path: template, viewParams: params);
    },
    'updateUrlQuery': ([Object? updates]) {
      if (updates is String) {
        updates = jsonDecode(updates);
      }

      var newParams = <String, String>{};
      if (updates is Map) {
        for (var key in updates.keys) {
          newParams[key] = updates[key].toString();
        }
      }

      var queryParams = Context.rq.uri.queryParameters
          .map((key, value) => MapEntry(key, value));

      var newUrl = Uri(
        queryParameters: {
          ...queryParams,
          ...newParams,
        },
      );

      return newUrl.toString();
    },
    'removeUrlQuery': (dynamic keys) {
      var queryParams = Context.rq.uri.queryParameters
          .map((key, value) => MapEntry(key, value));

      for (var key in keys) {
        queryParams.remove(key);
      }

      var newUrl = Uri(
        queryParameters: queryParams,
      );

      return newUrl.toString();
    },
    'existUrlQuery': (dynamic keys) {
      for (var key in keys) {
        if (Context.rq.uri.queryParameters.containsKey(key) &&
            Context.rq.uri.queryParameters[key] != null &&
            Context.rq.uri.queryParameters[key]!.isNotEmpty) {
          return true;
        }
      }
      return false;
    },
    'endpointQuery': () {
      var endpoint = Context.rq.uri.path;
      if (Context.rq.uri.queryParameters.isNotEmpty) {
        endpoint += '?${Context.rq.uri.query}';
      }
      return endpoint;
    },
    'log': (Object? value) {
      Console.e(value);
      return value;
    },
    'pathStartsWith': (String path) {
      return Context.rq.uri.path.startsWith(path);
    },
    'checkPath': (String path) {
      var uri = Context.rq.uri.path;

      if (path.endsWith('/')) path = path.substring(0, path.length - 1);
      if (path.startsWith('/')) path = path.substring(1);
      if (uri.endsWith('/')) uri = uri.substring(0, uri.length - 1);
      if (uri.startsWith('/')) uri = uri.substring(1);

      var current = uri.split('/');
      var check = path.split('/');

      if (current.length != check.length &&
          check.isNotEmpty &&
          check.last != '?') {
        return false;
      }

      for (var i = 0; i < check.length; i++) {
        var section = check[i];
        if (section == "*") {
          continue;
        }
        if (section.contains('?')) {
          return true;
        }
        if (i >= current.length || section != current[i]) {
          return false;
        }
      }
      return true;
    },
  };

  /// Retrieves global events and parameters for rendering.
  ///
  /// Constructs a map of global events and parameters for rendering purposes.
  /// This includes configuration values, asset URLs, session data, and more.
  ///
  /// Returns a [Map<String, Object?>] with global parameters and events.
  Map<String, Object?> getGlobalEvents() {
    Map<String, Object?> params = {};
    params['isLocalDebug'] = FinchApp.config.isLocalDebug;
    params['assets'] = {
      'js': () {
        if (jsRenderId.isNotEmpty) return jsRenderId;
        jsRenderId = "<#DART-SERVER#>JS<#DART-SERVER#>";
        return jsRenderId;
      },
      'css': () {
        if (cssRenderId.isNotEmpty) return cssRenderId;
        cssRenderId = "<#DART-SERVER#>CSS<#DART-SERVER#>";
        return cssRenderId;
      },
      'dataJs': () {
        if (dataJsId.isNotEmpty) return dataJsId;
        dataJsId = "<#DART-SERVER#>JS-DATA<#DART-SERVER#>";
        return dataJsId;
        //assetManager.getDataJs();
      },
    };

    params['render'] = () => 'TODO';
    params['data'] = getAll();
    params['session'] = getAllSession();
    params['param'] = (String path) {
      return _params.getByPathString(path, def: '');
    };
    params['validator'] = (String path) {
      return getValidator().navigation<Object>(
        path: path,
        def: '',
      );
    };
    var events = {
      'route': route?.getPathRender() ?? '/',
      'routePath': route?.getFullPath() ?? '/',
      'routeKey': route?.key ?? '',
      'isKey': (String key) {
        return route?.key == key;
      },
      'hasKey': (List key) {
        return key.contains(route?.key);
      },
      'routeUrl': (
        String key, [
        Map<String, Object?> params = const {},
        Map<String, Object?> query = const {},
      ]) {
        var res = FinchRoute.getByKey(key)?.getUrl(params, query);
        if (res == null) {
          throw Exception("The route key '$key' not found!");
        }
        return res;
      },
      'uri': Uri.encodeComponent(_rq.requestedUri.toString()),
      'uriString': _rq.requestedUri.toString(),
      'path': Uri.encodeComponent(_rq.requestedUri.path),
      'pathString': _rq.requestedUri.path,
      'isPath': (String path) {
        return pathsEqual([_rq.requestedUri.path, path]);
      },
      'endpoint': endpoint,
      'url': (String path) {
        return url(path);
      },
      'urlToLanguage': (String language) {
        var res = '';
        if (_rq.requestedUri.pathSegments.isNotEmpty &&
            _rq.requestedUri.pathSegments[0] == language) {
          res = url(_rq.requestedUri.path);
        } else if (_rq.requestedUri.pathSegments.isNotEmpty &&
            _rq.requestedUri.pathSegments[0] == getLanguage()) {
          var paths = _rq.requestedUri.pathSegments.sublist(1);
          res = url('/$language/${paths.join('/')}');
        } else {
          res = url('/$language${_rq.requestedUri.path}');
        }

        res = Uri.decodeFull(uri.replace(path: res).toString());
        return res;
      },
      'urlParam': (String path, Map<String, String> params) {
        return url(path, params: params);
      },
      'getCookie': (String key, [String def = '']) {
        return getCookie(key, def: def);
      },
      'ln': getLanguage(),
      'dir': 'language.${getLanguage()}_dir'.tr.write(),
      'langs': () {
        var langs = FinchApp.appLanguages.keys;
        var result = [];

        for (var lang in langs) {
          result.add({
            'code': lang,
            'label': 'language.${lang}_label'.tr.write(),
            'contry': 'language.${lang}_contry'.tr.write(),
          });
        }

        return result;
      },
      'pageTitle': route != null && route!.title.isNotEmpty
          ? route!.title
          : 'pages.title'.tr.write(),
      'setting': _setting,
      'formChecker': ([String? name]) => formChecker(name: name),
      'widgetPath': (String path) {
        return "$path.${FinchApp.config.widgetsType}";
      },
      'randomString': ([int? length]) {
        return generateRandomString(length ?? 4);
      },
      'toString': (dynamic value) {
        return value.toString();
      },
    };
    params['dump'] = (dynamic object) => InlineDumpWidget()
        .generateHtml!({
          'var': object,
          'rq': this,
        })
        .toHtml();
    params['\$e'] = LMap(events, def: null);
    params['\$rq'] = this;
    params['\$n'] = (String path, [Object? def = '']) {
      var res = getParams().navigation<Object>(path: path, def: def ?? '');
      if (res is String) {
        return res.escape(HtmlEscapeMode.unknown);
      }
      return res;
    };
    params['\$l'] = LMap(localEvents, def: null);
    params['\$t'] = (String text, [Object? params]) {
      var language = getLanguage();
      if (params == null) {
        return text.tr.write();
      } else {
        if (params is Map) {
          return text.tr.writeByLang(language, params);
        } else if (params is List) {
          return text.tr.writeByLangArr(language, params);
        }
      }
      return text.tr.writeByLang(language);
    };
    addParam('timestamp_end', DateTime.now().millisecondsSinceEpoch);
    var duration = (getParam('timestamp_end', def: 0) as int) -
        (getParam('timestamp_start', def: 0) as int);
    addParam('duration', duration);
    var lmap = LMap(params, def: null);

    params['\$'] = lmap;
    return params;
  }

  /// Retrieves all session-related data.
  ///
  /// Constructs a map containing session and cookies data.
  ///
  /// Returns an [Object] with session and cookies data.
  Object getAllSession() {
    var res = {
      'session': session,
      'cookies': cookies,
    };

    return res;
  }

  /// Gets the current endpoint, normalized for slashes.
  ///
  /// Returns a [String] representing the normalized path of the current request URI.
  String get endpoint => pathNorm(_rq.requestedUri.path, normSlashs: true);

  /// Checks if the current endpoint starts with 'api/'.
  ///
  /// Returns a [bool] indicating whether the endpoint is an API endpoint.
  bool get isApiEndpoint => endpoint.startsWith('api/');

  /// Retrieves a cookie value from the request.
  ///
  /// Optionally decrypts the cookie value if `safe` is true.
  ///
  /// [key] - The name of the cookie.
  /// [def] - The default value to return if the cookie is not found. Default is an empty string.
  /// [safe] - A flag indicating whether to decrypt the cookie value. Default is true.
  ///
  /// Returns a [String] containing the cookie value.
  String getCookie(
    String key, {
    String def = '',
    bool safe = true,
  }) {
    key = fixCookieName(key);
    for (var cookie in _rq.cookies) {
      if (cookie.name == key) {
        if (!safe) {
          return cookie.value;
        } else {
          return cookie.value.fromSafe(FinchApp.config.cookiePassword);
        }
      }
    }

    return def;
  }

  String fixCookieName(String key) {
    key = key.trim();
    final validChars = RegExp(r"[!#$%&'*+\-.^_`|~0-9a-zA-Z]");

    final buffer = StringBuffer();

    for (int i = 0; i < key.length; i++) {
      final char = key[i];
      if (validChars.hasMatch(char)) {
        buffer.write(char);
      } else {
        buffer.write('_');
      }
    }

    return buffer.toString();
  }

  /// Retrieves a session value.
  ///
  /// [key] - The key of the session value.
  /// [def] - The default value to return if the session key is not found. Default is an empty string.
  ///
  /// Returns an [Object] containing the session value or the default value.
  Object getSession(String key, {Object? def = ''}) {
    return session[key] ?? def;
  }

  /// Adds a value to the session.
  ///
  /// [key] - The key for the session value.
  /// [value] - The value to be added to the session.
  void addSession(String key, Object value) {
    session[key] = value;
  }

  /// Adds or updates a cookie in the response.
  ///
  /// Optionally encrypts the cookie value if `safe` is true.
  ///
  /// [key] - The name of the cookie.
  /// [value] - The value of the cookie.
  /// [duration] - The duration for which the cookie should be valid. Default is null.
  /// [safe] - A flag indicating whether to encrypt the cookie value. Default is true.
  void addCookie(
    String key,
    String value, {
    Duration? duration,
    bool safe = true,
  }) {
    key = fixCookieName(key);
    removeCookie(key);
    value = safe ? value.toSafe(FinchApp.config.cookiePassword) : value;
    var cookie = Cookie(key, value);
    cookie.maxAge = duration?.inSeconds;
    cookie.path = '/';
    cookie.secure = false;
    cookie.httpOnly = false;
    _rq.response.cookies.add(cookie);
    _rq.cookies.add(cookie);
  }

  /// Removes a cookie by setting its value to an empty string and expiration to a past date.
  ///
  /// [key] - The name of the cookie to be removed.
  void removeCookie(String key) {
    key = fixCookieName(key);
    _rq.cookies.removeWhere((element) => element.name == key);
    _rq.response.cookies.removeWhere((element) => element.name == key);
  }

  /// Constructs a full URL by combining a base URL with a subpath and optional query parameters.
  ///
  /// [subPath] - The path to be appended to the base URL.
  /// [params] - Optional query parameters to be included in the URL.
  ///
  /// Returns a [String] containing the full URL.
  String url(String subPath, {Map<String, String>? params}) {
    var pathRequest = _rq.requestedUri.origin;
    var uri = Uri.parse(pathRequest);
    uri = uri.resolve(subPath);
    if (params != null && params.isNotEmpty) {
      uri = uri.replace(queryParameters: params);
    }

    /// When the request is HTTPS, the URL should be HTTPS as well.
    var port = _rq.uri.port;
    uri = uri.replace(scheme: uri.scheme);
    if (![80, 443, 0].contains(port)) {
      uri = uri.replace(port: port);
    }
    var url = uri.toString();
    return url;
  }

  /// Retrieves the current hostname from the request URI.
  String get host => httpRequest.requestedUri.host;

  int get port => httpRequest.requestedUri.port;

  /// Adds a single asset to the asset manager.
  ///
  /// [asset] - The asset to be added.
  ///
  /// Returns the [AssetManager] instance after adding the asset.
  AssetManager addAsset(Asset asset) => assetManager.addAsset(asset);

  /// Adds a list of assets to the asset manager.
  ///
  /// [assets] - The list of assets to be added.
  ///
  /// Returns the [AssetManager] instance after adding the assets.
  AssetManager addAssets(List<Asset> assets) => assetManager.addAssets(assets);

  /// Retrieves the list of assets currently managed by the asset manager.
  ///
  /// Returns a [List<Asset>] containing all managed assets.
  List<Asset> getAssets() => assetManager.includes;

  /// Generates a random alphanumeric string of a specified length.
  ///
  /// [length] - The length of the random string. Defaults to 8.
  ///
  /// Returns a [String] containing the randomly generated string.
  String generateRandomString([int length = 8]) {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final charList =
        List.generate(length, (index) => chars[random.nextInt(chars.length)]);
    return charList.join('');
  }

  /// Generates a form checker hidden input field or a random key for form validation.
  ///
  /// [name] - The name attribute for the hidden input field. Defaults to 'formChecker'.
  /// [inputHtml] - A flag indicating whether to return the HTML input element. Defaults to true.
  ///
  /// Returns a [String] containing either the HTML input field or the random key.
  String formChecker({String? name, bool inputHtml = true}) {
    name = name ?? 'formChecker';
    final key = generateRandomString();
    var res = '<input type="hidden" name="$name" value="$key" />';
    addSession(
      name,
      {
        'key': key,
        'time': DateTime.now().millisecondsSinceEpoch,
      },
    );

    return inputHtml ? res : key;
  }

  /// Validates a form submission by checking the hidden form key and timestamp.
  ///
  /// [name] - The name attribute for the hidden input field. Defaults to 'formChecker'.
  ///
  /// Returns a [bool] indicating whether the form submission is valid.
  bool checkForm([String? name]) {
    name = name ?? 'formChecker';
    final dataField = data(name, def: 'unknown');
    if (dataField != 'unknown') {
      Map dataSession = getSession(name, def: 'unknown2') as Map;
      if (dataField == dataSession['key']) {
        int duration = DateTime.now().millisecondsSinceEpoch -
            (dataSession['time'] as int);
        if (duration / 1000 < 600) {
          return true;
        }
      }
    }
    return false;
  }

  /// Validates a form submission by checking the provided value against the session key and timestamp.
  /// CSRF protection.
  /// [name] - The name attribute for the hidden input field. Defaults to 'formChecker'.
  /// [value] - The value to be validated against the session key.
  /// [diffDuration] - The maximum allowed duration (in seconds) between the form generation
  /// and submission. Defaults to 600 seconds (10 minutes).
  /// Returns a [bool] indicating whether the form submission is valid.
  bool checkFormByValue({
    String name = 'formChecker',
    required String? value,
    int diffDuration = 600,
  }) {
    if (value != null && value != '') {
      Map dataSession = getSession(name, def: {}) as Map;
      if (value == dataSession['key']) {
        int time = (dataSession['time'] ?? 0) as int;
        int duration = DateTime.now().millisecondsSinceEpoch - time;
        if (duration / 1000 < diffDuration) {
          return true;
        }
      }
    }
    return false;
  }

  /// Retrieves the client's IP address from the request headers or connection information.
  ///
  /// This method checks the `X-Real-IP` and `X-Forwarded-For` headers, which are set by Nginx.
  /// If these headers are not present, it falls back to the remote address of the connection.
  ///
  /// Returns a [String] containing the client's IP address.
  String getIP() {
    String? ip = headers.value('X-Real-IP');

    if (ip != null) {
      return ip;
    }

    ip = headers.value('X-Forwarded-For');

    if (ip != null) {
      return ip;
    }

    return response.connectionInfo?.remoteAddress.address ?? '127.0.0.1';
  }
}
