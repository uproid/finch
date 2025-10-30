import 'package:finch/src/tools/convertor/convert_strings.dart';

/// Represents an authorization scheme used for authentication.
/// The [Authorization] class is designed to handle different types of authorization schemes.
/// It provides methods to parse authorization headers and extract credentials based on the
/// specified authentication type.
class Authorization {
  /// The type of authorization.
  ///
  /// Possible values include `AuthType.basic`, `AuthType.bearer`, etc.
  AuthType type;

  /// The authorization value, typically containing credentials or tokens.
  String value;

  /// Creates an instance of [Authorization] with the given [type] and [value].
  ///
  /// By default, the [type] is set to `AuthType.none` and the [value] is an empty string.
  Authorization({
    this.type = AuthType.none,
    this.value = '',
  });

  /// Parses an authorization header string into an [Authorization] object.
  ///
  /// The [auth] parameter should be in the format of 'type value', where 'type' specifies
  /// the type of authorization (e.g., 'Basic', 'Bearer') and 'value' is the credential or token.
  ///
  /// Example:
  /// ```dart
  /// var auth = Authorization.parse('Basic dXNlcjpwYXNzd29yZA==');
  /// ```
  factory Authorization.parse(String auth) {
    final splitedAuth = auth.split(' ');
    if (splitedAuth.length <= 1) {
      return Authorization(type: AuthType.none);
    }

    final typeString = splitedAuth[0].trim().toLowerCase();
    if (typeString == 'basic') {
      return Authorization(
        type: AuthType.basic,
        value: splitedAuth[1].fromBase64(),
      );
    }

    if (typeString == 'bearer') {
      return Authorization(
        type: AuthType.bearer,
        value: splitedAuth[1],
      );
    }

    return Authorization();
  }

  /// Extracts the username from a Basic authentication value.
  ///
  /// For Basic authentication, the value is typically in the format 'username:password'.
  /// This method returns the username part of the Basic authentication value.
  ///
  /// Returns an empty string if the value does not contain a username and password.
  String getBasicUsername() {
    var arr = value.split(':');
    if (arr.length >= 2) {
      return arr[0];
    }

    return '';
  }

  /// Extracts the password from a Basic authentication value.
  ///
  /// For Basic authentication, the value is typically in the format 'username:password'.
  /// This method returns the password part of the Basic authentication value.
  ///
  /// Returns an empty string if the value does not contain a username and password.
  String getBasicPassword() {
    var arr = value.split(':');
    if (arr.length >= 2) {
      return arr[1];
    }

    return '';
  }

  @override
  String toString() {
    return "Type: $type, Value:$value";
  }
}

/// Enumeration representing different types of authorization schemes.
/// - `none`: No authorization.
enum AuthType {
  none, // No authorization
  basic, // Basic authentication (username:password, base64 encoded)
  bearer, // Bearer token (e.g., OAuth tokens)
  digest, // Digest authentication (not yet implemented)
  hawk, // Hawk authentication (not yet implemented)
  aws, // AWS authentication (not yet implemented)
  akamai, // Akamai authentication (not yet implemented)
}
