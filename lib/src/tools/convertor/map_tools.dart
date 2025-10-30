/// Provides utility methods for manipulating [Map] instances.
/// This extension adds additional functionality to the [Map] class, allowing you to easily remove
/// multiple entries, select a subset of entries, and add new entries.
/// Example usage:
/// ```dart
/// var map = {'a': 1, 'b': 2, 'c': 3};
/// // Remove keys 'a' and 'c'
/// map.removeAll(['a', 'c']);
/// print(map); // Outputs: {'b': 2}
/// // Select only the key 'b'
/// var selected = map.select(['b']);
/// print(selected); // Outputs: {'b': 2}
/// // Add a new entry
/// map.add(MapEntry('d', 4));
/// print(map); // Outputs: {'b': 2, 'd': 4}
/// ```
extension MapTools<K, V> on Map<K, V> {
  /// Removes all entries with keys that are in the provided [keys] list.
  ///
  /// This method iterates over the [keys] list and removes each key from the map.
  /// The method returns the modified map.
  ///
  /// [keys] The list of keys to be removed from the map.
  ///
  /// Returns the map with specified keys removed.
  Map<K, V> removeAll(List<K> keys) {
    for (var key in keys) {
      remove(key);
    }
    return this;
  }

  /// Selects all entries from the map whose keys are in the provided [selectKeys] list.
  ///
  /// This method creates a new map containing only the entries with keys present in the [selectKeys] list.
  /// The method returns the new map with the selected entries.
  ///
  /// [selectKeys] The list of keys to be selected from the map.
  ///
  /// Returns a map containing only the entries with keys in [selectKeys].
  Map<K, V> select(List<K> selectKeys) {
    Map<K, V> res = {};
    for (var entry in entries) {
      if (selectKeys.contains(entry.key)) res.add(entry);
    }
    return res;
  }

  /// Adds a single entry to the map.
  ///
  /// This method adds the [entry] to the map. If the key already exists in the map, its value will be updated.
  ///
  /// [entry] The [MapEntry] to be added to the map.
  void add(MapEntry<K, V> entry) {
    this[entry.key] = entry.value;
  }
}
