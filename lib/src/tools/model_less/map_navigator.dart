import '../console.dart';

/// Extension on [Map<String, dynamic>] that allows navigating nested structures using a path string.
extension MapPath on Map<String, dynamic> {
  /// Navigates through the map using the provided path and retrieves a value of type [T].
  ///
  /// [path]: A string representing the navigation path, using '/' to separate keys or indices (for lists).
  /// [def]: A default value of type [T] that is returned if the path does not resolve to a valid value.
  ///
  /// Example:
  /// ```dart
  /// var map = {
  ///   'user': {
  ///     'name': 'John',
  ///     'address': {
  ///       'city': 'New York',
  ///       'zip': '10001'
  ///     }
  ///   }
  /// };
  ///
  /// var city = map.navigation(path: 'user/address/city', def: 'Unknown'); // returns 'New York'
  /// var zip = map.navigation(path: 'user/address/zip', def: '00000'); // returns '10001'
  /// var country = map.navigation(path: 'user/address/country', def: 'USA'); // returns 'USA'
  /// ```
  T navigation<T>({
    required String path,
    required T def,
  }) {
    List<String> arrPath = path.split('/');
    return _navigationArray(
      map: this,
      pathArray: arrPath,
      def: def,
    );
  }

  /// Recursive helper function that navigates through the map or list based on the path array.
  ///
  /// [map]: The current level of the map or list being traversed.
  /// [pathArray]: A list of keys or indices representing the navigation path.
  /// [def]: The default value of type [T] to return if the path cannot be resolved.
  T _navigationArray<T>({
    required dynamic map,
    required List<String> pathArray,
    required T def,
  }) {
    if (pathArray.isEmpty) {
      return _valueCheck<T>(value: map, def: def);
    }

    var key = pathArray.removeAt(0);

    if (map is Map<String, dynamic> && map.containsKey(key)) {
      return map._navigationArray<T>(
        map: map[key],
        pathArray: pathArray,
        def: def,
      );
    }

    var index = int.tryParse(key);
    if (map is List && index != null && map.length > index) {
      if (pathArray.isNotEmpty) {
        return _navigationArray<T>(
          map: map[index],
          pathArray: pathArray,
          def: def,
        );
      }
      return _valueCheck<T>(value: map[index], def: def);
    }

    return def;
  }

  /// Checks the final value's type against [T] and attempts to convert it if necessary.
  ///
  /// [value]: The value retrieved from the map or list.
  /// [def]: The default value of type [T] to return if conversion fails or if the value is null.
  T _valueCheck<T>({
    required dynamic value,
    required T def,
  }) {
    try {
      if (value == null) {
        return def;
      }

      if (T == String) {
        return value.toString() as T;
      }

      if (T == int) {
        return num.tryParse(value.toString()) as T;
      }

      if (T == double) {
        return double.tryParse(value.toString()) as T;
      }

      if (T == Map) {
        return (values) as T;
      }

      if (T == List) {
        return value;
      }

      if (T == Object) {
        return value;
      }

      //Develop here your other types of variables.
    } catch (e) {
      Console.w(e);
      return def;
    }

    return def;
  }
}
