/// Extension on [String] to provide additional validation and conversion methods.
extension StringValidator on String {
  /// Checks if the string is a valid email address.
  ///
  /// This method uses a regular expression to validate the format of an email address.
  /// It checks that the string contains characters, an '@' symbol, a domain name, and a top-level domain.
  ///
  /// Example:
  /// ```dart
  /// var email = 'example@example.com';
  /// print(email.isEmail); // Outputs: true
  /// ```
  ///
  /// Returns `true` if the string is a valid email address, otherwise `false`.
  bool get isEmail {
    const regex =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    return RegExp(regex).hasMatch(this);
  }

  /// Checks if the string is a valid password.
  ///
  /// A valid password must:
  /// - Be at least 8 characters long.
  /// - Contain at least one alphabetic character.
  /// - Contain at least one digit.
  /// - Contain at least one special character from the set `!@#\$%^&*=` (excluding spaces).
  ///
  /// Example:
  /// ```dart
  /// var password = 'P@ssw0rd';
  /// print(password.isPassword); // Outputs: true
  /// ```
  ///
  /// Returns `true` if the string meets all password criteria, otherwise `false`.
  bool get isPassword {
    if (length < 8) {
      return false;
    }

    RegExp alphaExp = RegExp(r'[a-zA-Z]');
    RegExp digitExp = RegExp(r'\d');
    RegExp specialExp = RegExp(r'[!@#\$%\^&\*=]');
    if (!alphaExp.hasMatch(this) ||
        !digitExp.hasMatch(this) ||
        !specialExp.hasMatch(this)) {
      return false;
    }

    return true;
  }

  /// Converts the string to a boolean value.
  ///
  /// The string is trimmed and converted to lowercase. It returns `true` if the string is
  /// '1' or 'true', and `false` for any other value.
  ///
  /// Example:
  /// ```dart
  /// var strTrue = 'true';
  /// var strOne = '1';
  /// var strFalse = 'false';
  /// print(strTrue.toBool); // Outputs: true
  /// print(strOne.toBool); // Outputs: true
  /// print(strFalse.toBool); // Outputs: false
  /// ```
  ///
  /// Returns `true` if the string is '1' or 'true', otherwise `false`.
  bool get toBool {
    String value = trim().toLowerCase();
    if (value == "1") {
      return true;
    }

    if (value == 'true') {
      return true;
    }

    return false;
  }

  /// Converts the string to an integer.
  ///
  /// If the string cannot be parsed into an integer, the method returns the default value provided.
  /// The default value is `-1` if not specified.
  ///
  /// Example:
  /// ```dart
  /// var numStr = '123';
  /// var invalidStr = 'abc';
  /// print(numStr.toInt()); // Outputs: 123
  /// print(invalidStr.toInt()); // Outputs: -1
  /// ```
  ///
  /// [def] The default value to return if the string cannot be parsed. Defaults to `-1`.
  ///
  /// Returns the integer value of the string or the default value if parsing fails.
  int toInt({int def = -1}) {
    return int.tryParse(this) ?? def;
  }

  /// Checks if the string represents a valid integer.
  ///
  /// This method attempts to convert the string to an integer and checks if the conversion is successful.
  ///
  /// Example:
  /// ```dart
  /// var numStr = '123';
  /// var invalidStr = 'abc';
  /// print(numStr.isInt); // Outputs: true
  /// print(invalidStr.isInt); // Outputs: false
  /// ```
  ///
  /// Returns `true` if the string can be parsed as an integer, otherwise `false`.
  bool get isInt {
    return toInt(def: -99999999) != -99999999;
  }

  /// Checks if the string represents a valid double (floating-point number).
  ///
  /// This method attempts to convert the string to a double and checks if the conversion is successful.
  /// It can handle integers, decimal numbers, and scientific notation.
  ///
  /// Example:
  /// ```dart
  /// var intStr = '123';
  /// var doubleStr = '123.45';
  /// var scientificStr = '1.23e4';
  /// var invalidStr = 'abc';
  /// print(intStr.isDouble); // Outputs: true
  /// print(doubleStr.isDouble); // Outputs: true
  /// print(scientificStr.isDouble); // Outputs: true
  /// print(invalidStr.isDouble); // Outputs: false
  /// ```
  ///
  /// Returns `true` if the string can be parsed as a double, otherwise `false`.
  bool get isDouble {
    return double.tryParse(this) != null;
  }
}
