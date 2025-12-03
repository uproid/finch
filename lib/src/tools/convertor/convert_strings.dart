import 'dart:convert';
import 'package:base32/base32.dart';
import 'package:crypto/crypto.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// Extension methods for [String] to provide various utilities for string manipulation,
/// encoding, decoding, and hashing.
/// This extension adds methods to the [String] class for tasks such as hashing the string
/// using MD5, converting between different encoding formats (Base64, Base32), converting
/// a string to an [ObjectId], and generating slugs.
extension ConvertString on String {
  /// Computes the MD5 hash of the string and returns it as a hexadecimal [String].
  /// This method converts the string to bytes using UTF-8 encoding, then computes the MD5 hash
  /// and returns the hash as a hexadecimal string.
  /// Returns a [String] representing the MD5 hash of the original string.
  String toMd5() {
    List<int> bytes = utf8.encode(this);
    Digest md5Result = md5.convert(bytes);
    String md5String = md5Result.toString();
    return md5String;
  }

  /// Decodes the string from Base64 encoding and returns the resulting string.
  /// If decoding fails, the method returns a default value.
  /// [def] is the default value returned in case of a decoding error.
  /// Returns the decoded string if successful; otherwise, returns [def].
  String fromBase64({String def = ''}) {
    try {
      List<int> bytes = base64.decode(this);
      return utf8.decode(bytes);
    } catch (e) {
      return def;
    }
  }

  /// Decodes the string from Base32 encoding and returns the resulting string.
  /// If decoding fails, the method returns a default value.
  /// [def] is the default value returned in case of a decoding error.
  /// Returns the decoded string if successful; otherwise, returns [def].
  String fromBase32({String def = ''}) {
    try {
      return base32.decodeAsString(this);
    } catch (e) {
      return def;
    }
  }

  /// Encodes the string to Base64 format.
  /// This method converts the string to bytes and then encodes those bytes to Base64.
  /// Returns a [String] representing the Base64 encoded version of the original string.
  String toBase64() {
    return base64.encode(utf8.encode(this));
  }

  /// Encodes the string to Base32 format.
  /// This method encodes the string directly to Base32.
  String toBase32() {
    return base32.encodeString(this);
  }

  /// Converts the string to an [ObjectId], or returns null if the string is not a valid ObjectId.
  /// This method trims the string and attempts to parse it into an [ObjectId]. If parsing fails,
  /// it returns null.
  /// Returns an [ObjectId] if the string is a valid ObjectId; otherwise, returns null.
  ObjectId? get oID => ObjectId.tryParse(trim());

  /// Converts the string to a slug by replacing spaces and non-alphanumeric characters.
  /// The resulting slug is lowercase and uses hyphens instead of spaces. Non-alphanumeric characters
  /// are removed.
  /// Returns the slugified version of the original string.
  String toSlug() {
    String slug = trim().toLowerCase();
    slug = slug.replaceAll(RegExp(r'\s+'), '-');
    slug = slug.replaceAll(RegExp(r'[^a-z0-9\-]'), '');
    return slug;
  }

  /// Checks if the string is a valid slug.
  /// This method compares the original string to its slugified version to determine if it is a valid slug.
  /// Returns `true` if the string is a valid slug; otherwise, returns `false`.
  bool isSlug() {
    return this == toSlug();
  }

  /// Unescapes HTML entities in the string.
  /// Returns the unescaped string.
  String unscapeHtml() {
    return HtmlUnescape().convert(this);
  }
}

/// Extension methods for [Map] to provide utilities for map manipulation.
/// This extension adds methods to the [Map] class for joining map entries into a single string
/// with a specified separator.
extension ConvertMap on Map {
  /// Joins the map entries into a single string with specified separators.
  /// This method iterates over the map's entries and joins them into a single string. Each key-value
  /// pair is joined using [separator], and each entry is separated by [separatorEntries].
  /// [separator] is used to separate keys and values in each entry.
  /// [separatorEntries] is used to separate each key-value pair.
  /// Returns a [String] representing the joined map entries.
  String joinMap(String separator, String separatorEntries) {
    var res = "";
    forEach((key, value) {
      res = "${res.isEmpty ? '' : "$res$separatorEntries"}$key$separator$value";
    });
    return res;
  }
}

extension DateTimeFormat on DateTime {
  String format(String format) {
    return DateFormat(format).format(this);
  }
}
