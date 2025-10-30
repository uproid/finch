import 'dart:convert';
import 'package:finch/src/tools/model_less/format_helper.dart';

import 'mode_less_array.dart';
import 'model_less.dart';

/// Extension on [Map] that provides utility methods for type conversion and data extraction.
/// This extension adds methods to safely extract and convert values from a map with default values if the key is not found or if the value cannot be converted.
extension MapFormatHelper on Map {
  /// Retrieves the integer value associated with the [key]. If the key does not exist or the value cannot be parsed as an integer, returns the [def] value.
  ///
  /// [key] The key in the map to retrieve the value from.
  /// [def] The default value to return if the key is not found or the value cannot be parsed. Defaults to `0`.
  ///
  /// Returns: The integer value associated with the [key] or [def] if not found or cannot be parsed.
  int asInt(String key, {int def = 0}) {
    if (keys.contains(key)) {
      return this[key].asInt(def: def);
    }

    return def;
  }

  /// Retrieves the value associated with the [key]. If the key does not exist, returns the [def] value.
  ///
  /// [key] The key in the map to retrieve the value from.
  /// [def] The default value to return if the key is not found. This must be specified.
  ///
  /// Returns: The value associated with the [key] or [def] if not found.
  dynamic asAny(String key, {required dynamic def}) {
    if (keys.contains(key)) {
      return this[key];
    }

    return def;
  }

  /// Retrieves the double value associated with the [key]. If the key does not exist or the value cannot be parsed as a double, returns the [def] value.
  ///
  /// [key] The key in the map to retrieve the value from.
  /// [def] The default value to return if the key is not found or the value cannot be parsed. Defaults to `0`.
  ///
  /// Returns: The double value associated with the [key] or [def] if not found or cannot be parsed.
  double asDouble(String key, {double def = 0}) {
    if (keys.contains(key)) {
      return this[key].asDouble(def: def);
    }

    return def;
  }

  /// Retrieves the numeric value associated with the [key]. If the key does not exist or the value cannot be parsed as a number, returns the [def] value.
  ///
  /// [key] The key in the map to retrieve the value from.
  /// [def] The default value to return if the key is not found or the value cannot be parsed. Defaults to `0`.
  ///
  /// Returns: The numeric value associated with the [key] or [def] if not found or cannot be parsed.
  num asNum(String key, {num def = 0}) {
    if (keys.contains(key)) {
      return this[key].toString().asNum(def: def);
    }

    return def;
  }

  /// Retrieves the string value associated with the [key]. If the key does not exist, returns the [def] value.
  ///
  /// [key] The key in the map to retrieve the value from.
  /// [def] The default value to return if the key is not found. Defaults to an empty string.
  ///
  /// Returns: The string value associated with the [key] or [def] if not found.
  String asString(String key, {String def = ''}) {
    if (keys.contains(key)) {
      return this[key] ?? def;
    }

    return def;
  }

  /// Retrieves the boolean value associated with the [key]. If the key does not exist or the value cannot be parsed as a boolean, returns the [def] value.
  ///
  /// [key] The key in the map to retrieve the value from.
  /// [def] The default value to return if the key is not found or the value cannot be parsed. Defaults to `false`.
  ///
  /// Returns: The boolean value associated with the [key] or [def] if not found or cannot be parsed.
  bool asBool(String key, {def = false}) {
    if (keys.contains(key)) {
      if (this[key] is bool) {
        return this[key];
      } else if (this[key] is String) {
        var val = this[key].toString().trim().toLowerCase();
        if (val == 'true' || val == '1' || val.isNotEmpty) {
          return true;
        } else {
          return false;
        }
      } else if (this[key] is int) {
        return (this[key] as int) > 0;
      }
    }

    return def;
  }

  /// Retrieves the list of type [T] associated with the [key]. If the key does not exist or the value cannot be parsed as a list, returns the [def] value.
  ///
  /// [key] The key in the map to retrieve the value from.
  /// [def] The default value to return if the key is not found or the value cannot be parsed. Defaults to an empty list if not provided.
  ///
  /// Returns: The list of type [T] associated with the [key] or [def] if not found or cannot be parsed.
  List<T> asList<T>(String key, {List<T>? def}) {
    if (keys.contains(key)) {
      return this[key].asList<T>(def: def);
    }

    return def ?? [];
  }

  /// Retrieves the map of type [T] to [K] associated with the [key]. If the key does not exist or the value cannot be parsed as a map, returns the [def] value.
  ///
  /// [key] The key in the map to retrieve the value from.
  /// [def] The default value to return if the key is not found or the value cannot be parsed. Defaults to an empty map if not provided.
  ///
  /// Returns: The map of type [T] to [K] associated with the [key] or [def] if not found or cannot be parsed.
  Map<T, K> asMap<T, K>(String key, {Map<T, K>? def}) {
    try {
      return Map<T, K>.from(this[key]);
    } catch (e) {
      return def ?? {};
    }
  }

  /// Retrieves a list of models of type [T] from the map, using a provided delegate function to parse each item.
  ///
  /// [key] The key in the map to retrieve the value from.
  /// [delegate] A function that takes dynamic data and returns an instance of type [T].
  /// [def] The default value to return if the key is not found or the value cannot be parsed. Defaults to an empty list if not provided.
  ///
  /// Returns: A list of models of type [T] parsed from the map value, or [def] if not found or cannot be parsed.
  List<T> asListModel<T>(
    String key,
    T Function(dynamic data) delegate, {
    List<T>? def,
  }) {
    List<T> result = [];
    try {
      if (keys.contains(key)) {
        List<dynamic> map = this[key];
        for (var value in map) {
          result.add(delegate(value));
        }

        return result;
      }
    } catch (e) {
      return def ?? [];
    }
    return def ?? [];
  }

  /// Retrieves a list of models of type [T] from the map using `ModelLess` instances and a provided delegate function to parse each item.
  ///
  /// [key] The key in the map to retrieve the value from.
  /// [delegate] A function that takes a `ModelLess` instance and returns an instance of type [T].
  /// [def] The default value to return if the key is not found or the value cannot be parsed. Defaults to an empty list if not provided.
  ///
  /// Returns: A list of models of type [T] parsed from `ModelLess` instances in the map value, or [def] if not found or cannot be parsed.
  List<T> asListModelLess<T>(
    String key,
    T Function(ModelLess data) delegate, {
    List<T>? def,
  }) {
    List<T> result = [];
    try {
      if (keys.contains(key)) {
        ModelLessArray map = this[key];
        map.forEach<ModelLess>((val) {
          result.add(delegate(val));
        });

        return result;
      }
    } catch (e) {
      return def ?? [];
    }
    return def ?? [];
  }

  /// Retrieves an enum value of type [T] associated with the [key]. If the key does not exist or the value cannot be parsed as an enum, returns the [def] value.
  ///
  /// [key] The key in the map to retrieve the value from.
  /// [enumValues] A list of possible enum values.
  /// [def] The default value to return if the key is not found or the value cannot be parsed. This must be specified.
  /// [stringCleaner] An optional function to clean or modify the string representation of the value before comparison.
  ///
  /// Returns: The enum value associated with the [key] or [def] if not found or cannot be parsed.
  T asEnum<T>(
    String key,
    List<T> enumValues, {
    required T def,
    String Function(String data)? stringCleaner,
  }) {
    if (keys.contains(key) && this[key] != null) {
      T res = enumValues.firstWhere(
        (element) {
          String value = this[key];
          if (stringCleaner != null) {
            value = stringCleaner(value);
          }
          return element.toString() == '$T.$value';
        },
        orElse: () => def,
      );
      return res;
    }

    return def;
  }

  /// Retrieves a regular expression pattern from the map associated with the [key]. If the key does not exist or the value cannot be parsed as a regex, returns the [def] value.
  ///
  /// [key] The key in the map to retrieve the value from.
  /// [def] The default regex pattern to return if the key is not found or the value cannot be parsed. Defaults to `r'(\w+)'`.
  /// [isBase64] Whether the regex pattern is base64 encoded. Defaults to `true`.
  /// [multiline] Whether the regex pattern should be multiline. Defaults to `true`.
  ///
  /// Returns: A `RegExp` object created from the pattern found in the map or [def] if not found or cannot be parsed.
  RegExp asRegex(
    String key, {
    String def = r'(\w+)',
    bool isBase64 = true,
    bool multiline = true,
  }) {
    try {
      if (isBase64) {
        var regexBase64 = asString('regex');
        var regexString = utf8.decode(base64Decode(regexBase64));
        if (regexString.isNotEmpty) {
          return RegExp(
            regexString,
            multiLine: multiline,
          );
        }
      }
      return RegExp(asString(key, def: r'(\w+)'));
    } catch (e) {
      return RegExp(r'(\w+)');
    }
  }

  /// remove all null values from the map.
  void removeNulls() {
    removeWhere((key, value) => value == null);
  }
}
