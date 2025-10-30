import 'package:finch/src/router/controller.dart';

/// The `AuthController` is an abstract class that defines authentication and
/// authorization methods for a web application.
/// This controller handles common tasks like login, registration, authentication
/// checks, and user session management. It extends the [Controller] and provides
/// methods that can be overridden to customize authentication logic.
/// The type parameter `T` represents the user model or object being used in the
/// authentication process.
abstract class AuthController<T> extends Controller {
  /// Constructs a `AuthController`.
  ///
  /// No parameters are needed as we use RequestContext to access the current request.
  AuthController();

  /// Displays the main page after authentication.
  ///
  /// This method should be implemented to define what is displayed on the main page.
  @override
  Future<String> index();

  /// Handles the logic for user login with a POST request.
  ///
  /// This method should be implemented to handle login form submission and
  /// authentication.
  Future<String> loginPost();

  /// Handles the logic for user registration.
  ///
  /// This method should be implemented to manage the registration process.
  Future<String> register();

  /// Creates a new user account.
  ///
  /// This method should be implemented to define how a new user is added
  /// to the system.
  Future<String> newUser();

  /// Checks if a user is authenticated.
  ///
  /// This method should be implemented to return `true` if the user is
  /// authenticated, and `false` otherwise.
  Future<bool> auth();

  /// Checks if the current user has permission to access specific resources.
  ///
  /// This method should be implemented to validate user permissions and
  /// return `true` if the user has the necessary permissions, or `false` otherwise.
  Future<bool> checkPermission();

  /// Checks if the current API request is authenticated.
  ///
  /// This method should be implemented to handle API authentication
  /// and return `true` if the request is authenticated.
  Future<bool> authApi();

  /// Checks the login status and returns a tuple containing the success status,
  /// a message, and the authenticated user object `T`.
  ///
  /// This method should be implemented to return the login check result in
  /// the form:
  /// ```dart
  /// (success: true/false, message: 'Login successful/failed', user: T? user)
  /// ```
  Future<({bool success, String message, T? user})> checkLogin();

  /// Logs out the current user and clears the session.
  ///
  /// This method should be implemented to handle user logout and session termination.
  Future<String> logout();

  /// Updates the authentication session with the provided email, password,
  /// and user object `T`.
  ///
  /// This method should be implemented to manage session updates when
  /// the user's credentials or details change.
  void updateAuth(String email, String password, T user);

  /// Removes the authentication session, effectively logging out the user.
  ///
  /// This method should be implemented to clear the user's session and
  /// authentication tokens.
  void removeAuth();
}

/// The `Permissions` class provides a set of predefined constants representing
/// user permission levels.
/// These constants can be used to check and assign different permission levels
/// within the authentication logic.
/// You can define custom permission levels by extending this class.
class Permissions {
  /// Represents no permissions.
  static final String none = 'none';

  /// Represents the highest level of administrative permissions.
  static final String superAdmin = 'super-admin';
}
