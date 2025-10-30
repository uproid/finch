// ignore_for_file: constant_identifier_names, non_constant_identifier_names

/// A utility class that provides constants and predefined lists for various HTTP request methods.
/// This class includes constants for common HTTP methods and provides convenience lists for
/// frequently used method combinations. It is useful for standardizing and managing HTTP method
/// strings throughout an application.
class Methods {
  /// The HTTP GET method.
  static const String GET = "GET";

  /// The HTTP PUT method.
  static const String PUT = "PUT";

  /// The HTTP POST method.
  static const String POST = "POST";

  /// The HTTP HEAD method.
  static const String HEAD = "HEAD";

  /// The HTTP DELETE method.
  static const String DELETE = "DELETE";

  /// The HTTP INSERT method (non-standard, generally used for custom purposes).
  static const String INSERT = "INSERT";

  /// The HTTP CONNECT method.
  static const String CONNECT = "CONNECT";

  /// The HTTP OPTIONS method.
  static const String OPTIONS = "OPTIONS";

  /// The HTTP TRACE method.
  static const String TRACE = "TRACE";

  /// The HTTP PATCH method.
  static const String PATCH = "PATCH";

  /// A list of all HTTP methods supported by this class.
  ///
  /// Includes: GET, POST, PUT, HEAD, DELETE, INSERT, CONNECT, OPTIONS, TRACE, PATCH.
  static const List<String> ALL = [
    GET,
    POST,
    PUT,
    HEAD,
    DELETE,
    INSERT,
    CONNECT,
    OPTIONS,
    TRACE,
    PATCH,
  ];

  /// A list of commonly used HTTP methods for request submissions.
  ///
  /// Includes: POST, GET.
  static const List<String> GET_POST = [POST, GET];

  /// A list containing only the HTTP GET method.
  static const List<String> ONLY_GET = [GET];

  /// A list containing only the HTTP POST method.
  static const List<String> ONLY_POST = [POST];

  /// A list containing only the HTTP DELETE method.
  static const List<String> ONLY_DELETE = [DELETE];

  /// A list containing only the HTTP PUT method.
  static const List<String> ONLY_PUT = [PUT];

  /// A list containing only the HTTP INSERT method.
  static const List<String> ONLY_INSERT = [INSERT];

  static const List<String> GET_ONLY = ONLY_GET;
  static const List<String> POST_ONLY = ONLY_POST;
  static const List<String> DELETE_ONLY = ONLY_DELETE;
  static const List<String> PUT_ONLY = ONLY_PUT;
  static const List<String> INSERT_ONLY = ONLY_INSERT;
}
