/// Represents the documentation for an API endpoint in OpenAPI/Swagger format.
class ApiDoc {
  /// List of parameters for the API endpoint.
  List<ApiParameter> parameters;

  /// List of body fields for the API request.
  List<ApiBodyField> body;

  /// Map of responses for the API endpoint, categorized by HTTP status codes.
  Map<String, List<ApiResponse>> response;

  /// Optional description of the API endpoint.
  String? description;

  /// Documentation for the POST method.
  ApiDoc? post;

  /// Documentation for the GET method.
  ApiDoc? get;

  /// Documentation for the PUT method.
  ApiDoc? put;

  /// Documentation for the DELETE method.
  ApiDoc? delete;

  /// Creates an instance of [ApiDoc] with optional parameters for different HTTP methods.
  ///
  /// [parameters] - List of query parameters, path parameters, etc.
  /// [body] - List of body fields for the API request.
  /// [response] - Map of responses categorized by HTTP status codes.
  /// [description] - Optional description of the API endpoint.
  /// [delete] - Documentation for the DELETE method.
  /// [get] - Documentation for the GET method.
  /// [post] - Documentation for the POST method.
  /// [put] - Documentation for the PUT method.
  ApiDoc({
    //For all methods
    this.parameters = const [],
    this.body = const [],
    this.response = const {},
    this.description,
    //For special Method
    this.delete,
    this.get,
    this.post,
    this.put,
  });

  /// Converts Dart type to OpenAPI type.
  ///
  /// [type] - The Dart type as a string.
  ///
  /// Returns the corresponding OpenAPI type as a string.
  static String dartTypeToOpenApi(String type) {
    type = type.split('<')[0];
    switch (type) {
      case 'int':
        return 'integer';
      case 'double':
        return 'number';
      case 'num':
        return 'number';
      case 'bool':
        return 'boolean';
      case 'String':
        return 'string';
      case 'List':
        return 'array';
      case 'Map':
        return 'object';

      default:
        return type;
    }
  }
}

/// Represents a parameter used in an API request.
/// [T] - The Dart type of the parameter.
class ApiParameter<T> {
  /// The name of the parameter.
  String name;

  /// Default value for the parameter.
  Object? def;

  /// Optional description of the parameter.
  String? description;

  /// Indicates whether the parameter is required.
  bool isRequired;

  /// The type of the parameter as a string according to OpenAPI specification.
  String get typeString => ApiDoc.dartTypeToOpenApi(T.toString());

  /// The Dart type of the parameter.
  Type get type => T.runtimeType;

  /// The location where the parameter is expected in the request.
  ParamIn paramIn;

  ApiParameter(
    this.name, {
    this.def,
    this.description,
    this.isRequired = false,
    this.paramIn = ParamIn.query,
  });
}

/// Creates an instance of [ApiParameter].
/// [name] - The name of the parameter.
/// [def] - Optional default value for the parameter.
/// [description] - Optional description of the parameter.
/// [isRequired] - Indicates whether the parameter is required.
class ApiBodyField<T> {
  String name;
  Object? def;
  String? description;
  bool isRequired;
  String get typeString => ApiDoc.dartTypeToOpenApi(T.toString());
  Type get type => T.runtimeType;
  ApiBodyField(
    this.name, {
    this.def,
    this.description,
    this.isRequired = false,
  });
}

/// Represents a field in the body of an API request.
/// [T] - The Dart type of the body field.
class ApiResponse<T> {
  /// The name of the body field.
  String name;

  /// Default value for the body field.
  Object? def;

  /// Optional description of the body field.
  String? description;

  /// Indicates whether the body field is required.
  String get typeString => ApiDoc.dartTypeToOpenApi(T.toString());

  /// The Dart type of the body field.
  Type get type => T.runtimeType;

  /// Creates an instance of [ApiBodyField].
  ///
  /// [name] - The name of the body field.
  /// [def] - Optional default value for the body field.
  /// [description] - Optional description of the body field.
  ApiResponse(
    this.name, {
    this.def,
    this.description,
  });
}

/// Enumeration representing the possible locations for a parameter in an API request.
enum ParamIn {
  /// Query parameters in the URL.
  query,

  /// Parameters in the URL path.
  header,

  /// Parameters in cookies.
  path,

  /// Parameters in headers.
  cookie;

  @override
  String toString() {
    switch (this) {
      case ParamIn.query:
        return 'query';
      case ParamIn.path:
        return 'path';
      case ParamIn.cookie:
        return 'cookie';
      case ParamIn.header:
        return 'header';
    }
  }
}
