import '../render/request.dart';
import '../core/context.dart';

/// Base controller class for handling HTTP requests in the web application.
/// [Controller] serves as the foundation for all request handlers in the framework.
/// It provides access to the current request context and implements the [RouteRepos]
/// interface for standardized request handling. Controllers are typically used to
/// organize related request handling logic and can be associated with routes to
/// process incoming HTTP requests.
/// the [rq] getter, is RequestContext.rq to access the current WebRequest.
/// This design leverages the Zone-based [Context] system for thread-safe
/// request handling.
/// - Thread-safe request handling through Zone isolation
/// - Standardized interface for index route handling
/// - Built-in string representation for debugging and introspection
/// Example usage:
///   @override
///   Future&lt;String&gt; index() async {
///     final users = await userService.getAllUsers();
///     return rq.renderJson(users);
///   }
///   Future&lt;String&gt; show() async {
///   }
/// }
/// WebRoute(
///   path: '/users',
class Controller implements RouteRepos {
  /// Gets the current WebRequest from the request context
  Request get rq => Context.rq;

  /// Provides an asynchronous method for rendering the index page of the controller.
  ///
  /// This method returns an empty string by default. Subclasses should override this method
  /// to provide specific functionality for rendering the index view.
  ///
  /// Returns a [Future<String>] that resolves to an empty string.
  @override
  Future<String> index() async => "";

  /// Returns a string representation of the controller.
  ///
  /// If [short] is true, the method returns a short representation by extracting and
  /// returning the last part of the class name from the superclass’s `toString` method,
  /// removing any single quotes.
  ///
  /// If [short] is false, the method returns the full string representation of the class.
  ///
  /// Returns a [String] representing the controller.
  @override
  String toString({bool short = false}) {
    if (short) {
      return super.toString().split(' ').last.replaceAll("'", '');
    }
    return super.toString();
  }
}

/// Interface defining the contract for route request handlers.
/// [RouteRepos] establishes a standardized interface that all route handlers
/// must implement. It serves as a contract ensuring that request handling
/// components provide consistent entry points for processing HTTP requests.
/// The interface is designed to support the routing system's n
/// implementation details. This abstraction enables the framew
/// Implementations should:
/// - Return appropriate response content as a string
/// - Manage any necessary asynchronous operations
/// This interface is primarily implemented by [Controller] and its subcl
abstract class RouteRepos {
  /// Handles the primary request processing for this route handler.
  /// This method serves as the main entry point for processing HTTP requests
  /// when no specific action is specified. It should contain the core logic
  /// for handling the request and generating an appropriate respons
  /// The method is called by the routing system when a request matches the
  /// associated route pattern. Implementations should:
  /// - Process the request according to business logic
  /// - Generate and return response content
  /// - Handle any errors appropriately
  ///
  /// Returns a [Future<String>] containing the response content. This could be:
  /// - HTML content for web pages
  /// - JSON data for API endpoints
  /// - Redirect responses
  /// - Error messages
  /// - Empty string for no-content responses
  ///
  /// Example implementation:
  /// ```dart
  /// @override
  /// Future<String> index() async {
  ///   final data = await service.getData();
  ///   return RequestContext.rq.renderJson(data);
  /// }
  /// ```
  Future<String> index();
}
