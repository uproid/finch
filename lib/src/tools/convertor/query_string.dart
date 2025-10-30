import 'dart:convert';

/// A utility class for parsing query strings into a [Map].
/// This class provides a static method to convert a query string into a map,
/// handling URL decoding and array notation.
class QueryString {
  /// Parses a query string into a [Map].
  ///
  /// This method takes a query string and converts it into a map of key-value pairs.
  /// It supports URL decoding and handles array notation in keys (e.g., `key[]=value1&key[]=value2`).
  ///
  /// Example:
  /// ```dart
  /// var query = 'name=John&age=30&hobbies[]=reading&hobbies[]=writing';
  /// var result = QueryString.parse(query);
  /// print(result); // Outputs: {name: John, age: 30, hobbies: [reading, writing]}
  /// ```
  ///
  /// [query] The query string to be parsed. It should be in the format of `key=value&key2=value2`.
  ///
  /// [encoding] The encoding to be used for decoding the query components. Defaults to [utf8].
  ///
  /// Returns a [Map] where the keys are strings and the values are either strings or lists of strings,
  /// depending on whether the keys in the query string ended with `[]`.
  static Map<String, Object?> parse(String query, {Encoding encoding = utf8}) {
    var result = <String, Object?>{};
    result = query.split("&").fold(
      {},
      (map, element) {
        int index = element.indexOf("=");
        if (index == -1) {
          if (element != "") {
            map[Uri.decodeQueryComponent(element, encoding: encoding)] = "";
          }
        } else if (index != 0) {
          var key = element.substring(0, index);
          var value = element.substring(index + 1);
          var encodeKey = Uri.decodeQueryComponent(key, encoding: encoding);
          var encodeValue = Uri.decodeQueryComponent(value, encoding: encoding);
          var isArray = encodeKey.endsWith('[]');

          if (isArray) {
            encodeKey = encodeKey.substring(0, encodeKey.length - 2);
            if (map.keys.contains(encodeKey)) {
              if (map[encodeKey] is List) {
                (map[encodeKey] as List).add(encodeValue);
              } else {
                var list = [];
                list.add(map[encodeKey]);
                list.add(encodeValue);
                map[encodeKey] = list;
              }
            } else {
              map[encodeKey] = [encodeValue];
            }
          } else {
            map[encodeKey] = encodeValue;
          }
        }
        return map;
      },
    );
    return result;
  }
}
