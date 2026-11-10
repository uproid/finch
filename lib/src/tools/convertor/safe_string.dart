import 'dart:convert';
import 'dart:typed_data';
import 'package:html_unescape/html_unescape.dart';
import 'package:pointycastle/export.dart';

/// Extension on [String] to provide additional security and sanitization methods.
extension SafeString on String {
  /// Removes HTML tags from the string, optionally replacing them with a specified string.
  ///
  /// This method uses a regular expression to identify HTML tags and remove them from the input string.
  /// If [replace] is provided, the HTML tags are replaced with the specified string instead of being removed.
  ///
  /// Example:
  /// ```dart
  /// var htmlString = '<p>Hello <b>World</b></p>';
  /// var cleaned = htmlString.removeHtmlTags();
  /// print(cleaned); // Outputs: Hello World
  /// ```
  ///
  /// [replace] The string to replace HTML tags with. Defaults to an empty string.
  ///
  /// Returns a string with HTML tags removed or replaced.
  String removeHtmlTags({String replace = ''}) {
    return replaceAll(RegExp(r'<[^>]*>'), replace);
  }

  /// Escapes HTML special characters in the string to their corresponding HTML entities.
  String escape([HtmlEscapeMode mode = HtmlEscapeMode.unknown]) =>
      HtmlEscape(mode).convert(this);

  /// Unescapes HTML entities in the string back to their corresponding characters.
  String unescape() => HtmlUnescape().convert(this);

  /// Removes `<script>` tags and JavaScript event handlers from the string.
  ///
  /// This method uses regular expressions to remove script tags and attributes that may contain
  /// JavaScript event handlers (e.g., `onclick`, `onload`).
  ///
  /// Example:
  /// ```dart
  /// var htmlString = '<div onclick="alert(\'Hi\')">Content</div><script>alert("Hi");</script>';
  /// var cleaned = htmlString.removeScripts();
  /// print(cleaned); // Outputs: <div>Content</div>
  /// ```
  ///
  /// Returns a string with script tags and JavaScript event handlers removed.
  String removeScripts() {
    final RegExp scriptTagRegExp =
        RegExp(r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>');
    final RegExp scriptAttrRegExp =
        RegExp(r'''\s+on\w+\s*=\s*["'][^"']*["']|\s+on\w+\s*=\s*[^\s>]+''');

    // Remove any script tags from the input
    var input = replaceAll(scriptTagRegExp, '');

    // Remove any event handler attributes (e.g. onmousedown, onclick) from all elements
    input = input.replaceAll(scriptAttrRegExp, '');

    return input;
  }

  /// Encrypts the string using AES encryption with a provided password.
  ///
  /// This method uses AES encryption in CBC mode. The password is adjusted to be exactly 32 bytes long,
  /// with the first 16 bytes used as the initialization vector (IV).
  ///
  /// Example:
  /// ```dart
  /// var originalText = 'Hello World';
  /// var encrypted = originalText.toSafe('your-password-here');
  /// print(encrypted); // Outputs encrypted base64 string
  /// ```
  ///
  /// [password] The password used for encryption. It is truncated or padded to 32 bytes.
  ///
  /// Returns the encrypted string encoded in base64.
  String toSafe(String password) {
    try {
      final keyBytes = _normalizePassword(password);

      final ivBytes = keyBytes.sublist(0, 16);

      final cipher = CBCBlockCipher(AESEngine())
        ..init(
          true,
          ParametersWithIV(
            KeyParameter(keyBytes),
            ivBytes,
          ),
        );

      final input = utf8.encode(this);

      final paddedInput = _pkcs7Pad(
        Uint8List.fromList(input),
        16,
      );

      final output = Uint8List(paddedInput.length);

      for (int offset = 0; offset < paddedInput.length; offset += 16) {
        cipher.processBlock(
          paddedInput,
          offset,
          output,
          offset,
        );
      }

      return base64.encode(output);
    } catch (_) {
      return '';
    }
  }

  Uint8List _normalizePassword(String password) {
    if (password.length > 32) {
      password = password.substring(0, 32);
    } else if (password.length < 32) {
      while (password.length != 32) {
        password += '-';
      }
    }

    return Uint8List.fromList(utf8.encode(password));
  }

  /// Decrypts a base64-encoded AES-encrypted string using a provided password.
  ///
  /// This method uses AES decryption in CBC mode. The password is adjusted to be exactly 32 bytes long,
  /// with the first 16 bytes used as the initialization vector (IV).
  ///
  /// Example:
  /// ```dart
  /// var decrypted = encryptedText.fromSafe('your-password-here');
  /// print(decrypted); // Outputs original decrypted string
  /// ```
  ///
  /// [password] The password used for decryption. It is truncated or padded to 32 bytes.
  ///
  /// Returns the decrypted string, or an error message if decryption fails.
  String fromSafe(String password) {
    try {
      final keyBytes = _normalizePassword(password);

      final ivBytes = keyBytes.sublist(0, 16);

      final cipher = CBCBlockCipher(AESEngine())
        ..init(
          false,
          ParametersWithIV(
            KeyParameter(keyBytes),
            ivBytes,
          ),
        );

      final input = base64.decode(this);

      final output = Uint8List(input.length);

      for (int offset = 0; offset < input.length; offset += 16) {
        cipher.processBlock(
          input,
          offset,
          output,
          offset,
        );
      }

      return utf8.decode(
        _pkcs7Unpad(output),
      );
    } catch (e) {
      return e.toString();
    }
  }

  Uint8List _pkcs7Pad(Uint8List data, int blockSize) {
    final padLength = blockSize - (data.length % blockSize);

    return Uint8List.fromList([...data, ...List.filled(padLength, padLength)]);
  }

  Uint8List _pkcs7Unpad(Uint8List data) {
    if (data.isEmpty) {
      throw const FormatException('Invalid padding');
    }
    final last = data.last;
    if (last < 1 || last > data.length) {
      throw const FormatException('Invalid padding');
    }
    return data.sublist(
      0,
      data.length - last,
    );
  }
}
