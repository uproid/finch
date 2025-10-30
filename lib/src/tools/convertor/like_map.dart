/// A class that provides a map with a default value for missing keys.
/// This class wraps a standard [Map] and provides an operator to access map values. If a key is not
/// found in the map, it returns a default value. If the default value is a [String], it can include
/// a placeholder `@key` that will be replaced with the missing key.
/// Example usage:
/// ```dart
/// var lmap = LMap({
///   'name': 'John Doe',
///   'age': 30
/// }, def: 'Unknown');
/// print(lmap['name']); // Outputs: John Doe
/// print(lmap['address']); // Outputs: Unknown
/// ```
/// In the example above, the default value `'Unknown'` is used for missing keys. If you provide a
/// [String] as the default value containing `@key`, it will be replaced with the missing key.
class LMap {
  Map<String, Object?> map;
  Object? def;
  LMap(this.map, {this.def});

  Object? operator [](String key) {
    if (map.keys.contains(key)) {
      return map[key];
    }

    if (def is String) {
      return def.toString().replaceAll('@key', key);
    }

    return def;
  }
}
