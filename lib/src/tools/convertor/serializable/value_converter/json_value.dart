import 'dart:convert';
import 'package:finch/finch_tools.dart';
import 'package:finch/src/render/request.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// Provides utility methods for encoding and decoding JSON data.
/// The [FinchJson] class includes static methods for converting data to JSON format and
/// parsing JSON strings into Dart objects. It handles custom encoding for specific types
/// such as `TString`, `ObjectId`, `DateTime`, and `Duration`.
class FinchJson {
  /// Converts an object to a JSON-encoded string.
  ///
  /// This method uses [jsonEncode] to serialize the [data] object into a JSON string.
  /// It provides custom encoding for specific types:
  /// - [TString]: Uses the `write` method with the optional [rq] parameter.
  /// - [ObjectId]: Converts to its string representation via the `oid` property.
  /// - [DateTime]: Converts to its ISO-8601 string representation.
  /// - [Duration]: Converts to its string representation.
  ///
  /// [data] is the object to be encoded.
  /// Returns a [String] containing the JSON-encoded representation of the [data] object.
  static String jsonEncoder(Object data) {
    return jsonEncode(data, toEncodable: (obj) {
      if (obj == null) {
        return null;
      }
      if (obj is TString) {
        return obj.write();
      }
      if (obj is ObjectId) {
        return obj.oid;
      }
      if (obj is DateTime) {
        return obj.toString();
      }
      if (obj is Duration) {
        return obj.toString();
      }

      if (obj is Map) {
        return encodeMaps(obj);
      }
      if (obj is Symbol) {
        return symbolToKey(obj);
      }
      if (obj is int) {
        return obj;
      }
      return obj.toString();
    });
  }

  /// Convert Symbol maps to String maps
  /// For example, {Symbol('name'): 'John'} becomes {'name': 'John'}
  /// [obj] is the map to be converted.
  /// Returns a new map with String keys.
  static Map encodeMaps(Map obj) {
    var res = {};
    for (Object o in obj.keys) {
      var key = "";
      if (o is Symbol) {
        key = symbolToKey(o);
      } else {
        key = o.toString();
      }
      res[key] = obj[o];
    }
    return res;
  }

  /// Converts a [Symbol] to a string key.
  /// The string key is derived from the symbol's name.
  /// If the symbol represents a private member (starts with '_'), it is prefixed with '#'.
  /// For example, Symbol('name') becomes 'name', and Symbol('_private') becomes '#_private'.
  /// [symbol] is the symbol to be converted.
  /// Returns the string representation of the symbol.
  static String symbolToKey(Symbol symbol) {
    var name = symbol.toString();
    var regExp = RegExp(r'\("(.+)"\)');
    var match = regExp.firstMatch(name)?.group(1);
    match = match != null ? "#$match" : null;
    return match ?? name;
  }

  static Object? _jsonEncodelEvent(
    Object? key,
    Object? value,
  ) {
    if (value is Map) {
      return _normalizeMapKeys(value);
    }
    return value;
  }

  /// Parses a JSON-encoded string into a Dart object.
  ///
  /// This method uses [jsonDecode] to convert the [data] string from JSON format into
  /// a Dart object. The structure of the returned object depends on the contents of
  /// the JSON string.
  ///
  /// [data] is the JSON string to be decoded.
  ///
  /// Returns a dynamic object representing the parsed JSON data.
  static dynamic jsonDecoder(String data) {
    final map = jsonDecode(
      data,
      reviver: _jsonEncodelEvent,
    );

    return _normalizeMapKeys(map);
  }

  /// Normalizes the keys of a map by converting keys that start with '#' to Symbol keys.
  ///
  /// For example, a key '#name' will be converted to Symbol('name').
  /// Other keys remain unchanged.
  /// [map] is the map to be normalized.
  /// Returns a new map with normalized keys.
  static Map _normalizeMapKeys(Map map) {
    var res = {};
    for (var key in map.keys) {
      final value = map[key];
      if (key is String && key.startsWith("#")) {
        key = key.substring(1);
        res[Symbol(key)] = value;
      } else {
        res[key] = value;
      }
    }

    return res;
  }

  /// Parses a JSON-encoded dynamic into a Dart object.
  /// If parsing fails, returns null.
  /// The [data] parameter can be any type of object to be parsed.
  /// The [rq] parameter is an optional [Request] object used for encoding [TString] instances.
  /// Returns a dynamic object representing the parsed JSON data, or null if
  static Map<T, V>? tryJson<T, V>(dynamic data) {
    try {
      var res = jsonEncoder(data);
      return jsonDecoder(res) as Map<T, V>;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Parses a JSON-encoded dynamic into a List.
  /// If parsing fails, returns the provided default list.
  /// The [data] parameter can be any type of object to be parsed.
  /// The [def] parameter is the default list to return if parsing fails (default is an empty list).
  /// The [rq] parameter is an optional [Request] object used for encoding [TString] instances.
  static List? tryJsonList(
    dynamic data, {
    List def = const [],
    Request? rq,
  }) {
    try {
      if (data is List) {
        return data;
      }
      var res = jsonDecoder('{"list": $data}');
      return res['list'] as List;
    } catch (e) {
      print(e);
      return def;
    }
  }
}
