import 'dart:convert';

import '../console.dart';
import 'model_less.dart';

/// The ModelLessArray class is a generic class that provides a structure for
/// managing a collection of items, specifically designed to work with ModelLess
/// objects. This class offers features such as accessing items by index,
/// dynamically setting and getting values, parsing JSON into the array, and
/// retrieving nested data using paths. Below is an explanation and breakdown
/// of the key features:
class ModelLessArray<T> {
  List<T>? fields;

  ModelLessArray({this.fields});

  int get length {
    return fields == null ? 0 : fields!.length;
  }

  /// Iterates over each element in the array and applies the provided function.
  /// The function takes an element of type R as input and returns a value of type T.
  /// [function] A function that takes an element of type R and returns a value of type T.
  /// Example:
  /// ```dart
  /// ModelLessArray<int> array = ModelLessArray<int>();
  /// array.set(1);
  /// array.set(2);
  /// array.set(3);
  /// array.forEach<int>((val) {
  ///   print(val); // Outputs: 1, 2, 3
  ///   return val * 2; // Example of returning a value, though it's not used here
  /// });
  /// ```
  void forEach<R>(T Function(R val) function) {
    for (int i = 0; i < length; i++) {
      function(get<R>(i));
    }
  }

  bool get isNotEmpty => length > 0;

  bool get isEmpty => length == 0;

  dynamic operator [](int index) {
    if (fields == null) {
      return null;
    }

    if (fields!.length <= index) {
      return null;
    }

    return fields![index];
  }

  /// Sets the value at the specified index in the array.
  /// If the index is out of range, an exception is thrown.
  /// [index] The index at which to set the value.
  /// [value] The value to set at the specified index.
  /// Example:
  /// ```dart
  /// ModelLessArray<int> array = ModelLessArray<int>();
  /// array.set(1);
  /// array.set(2);
  /// array.set(3);
  /// array[1] = 5; // Sets the value at index 1 to 5
  /// print(array[1]); // Outputs: 5
  /// ```
  /// Throws an Exception if the index is out of range.
  void operator []=(int index, T value) {
    fields ??= <T>[];
    if (fields!.length <= index) {
      throw Exception('Index out of range: $index');
    } else {
      fields![index] = value;
    }
  }

  // ignore: avoid_shadowing_type_parameters
  T get<T>(int index, {dynamic def}) {
    var val = this[index];

    if (val == null) {
      return def as T;
    }

    return val as T;
  }

  /// Adds a value to the end of the array.
  /// If the fields list is null, it initializes it before adding the value.
  /// [value] The value to add to the array.
  void set(dynamic value) {
    fields ??= <T>[];
    fields!.add(value);
  }

  /// Adds all elements from another ModelLessArray to this array.
  /// If the fields list is null, it initializes it before adding the elements.
  /// [value] The ModelLessArray whose elements are to be added to this array.
  void addAll(ModelLessArray<T> value) {
    fields ??= <T>[];
    fields!.addAll(value.fields!);
  }

  /// Creates a ModelLessArray from a JSON string.
  /// The JSON string should represent a list of objects.
  /// Each object in the list is converted to a ModelLess instance and added to the array.
  /// If parsing fails, an error message is logged to the console.
  /// [jsonString] The JSON string to parse.
  /// Returns a ModelLessArray containing the parsed ModelLess instances.
  static ModelLessArray<T> fromJson<T>(String jsonString) {
    ModelLessArray<T> arrayApiModels = ModelLessArray();

    try {
      List<dynamic> jsonData = json.decode(jsonString);
      for (var element in jsonData) {
        ModelLess apiModel = ModelLess.fromMap(element);
        arrayApiModels.set(apiModel);
      }
    } on Exception catch (e) {
      Console.write("Error Parsing Data for init an ArrayApiModel: $e");
    }

    return arrayApiModels;
  }

  /// Attempts to create a ModelLessArray from a JSON string.
  /// The JSON string should represent a list of objects.
  /// Each object in the list is converted to a ModelLess instance and added to the array.
  /// If parsing fails, the method returns null.
  /// [jsonString] The JSON string to parse.
  /// Returns a ModelLessArray containing the parsed ModelLess instances, or null if parsing fails
  static ModelLessArray<T>? tryJson<T>(String jsonString) {
    try {
      List<dynamic> jsonData = json.decode(jsonString);
      ModelLessArray<T> arrayApiModels = ModelLessArray();
      for (var element in jsonData) {
        ModelLess apiModel = ModelLess.fromMap(element);
        arrayApiModels.set(apiModel);
      }
      return arrayApiModels;
    } catch (e) {
      return null;
    }
  }

  /// Retrieves a value of type [R] from the array using a specified path.
  /// The path is a list of keys and/or indices that navigate through nested ModelLess or
  /// ModelLessArray structures.
  /// If the path cannot be fully resolved, the method returns the provided default value.
  /// [path] A list of keys and/or indices representing the navigation path.
  /// [def] A default value of type [R] that is returned if the path
  R getByPath<R>(List<dynamic> path, {dynamic def}) {
    try {
      var key = path.removeAt(0);
      if (path.isEmpty) {
        return get<R>(key, def: def);
      } else {
        if (path[0] is int) {
          var index = path.removeAt(0) as int;
          var valueKey = get<dynamic>(key);
          var valueIndex = valueKey.get<dynamic>(index);

          if ((valueIndex is ModelLess || valueIndex is ModelLessArray) &&
              path.isNotEmpty) {
            return valueIndex.getByPath<dynamic>(path, def: def);
          }
          return valueIndex as R;
        }
        return get<ModelLess>(key).getByPath<R>(path, def: def);
      }
    } catch (e) {
      if (T == String && def == null) return "" as R;
      return def as R;
    }
  }

  /// Retrieves a value of type [R] from the array using a string path.
  /// The path is a '/'-separated string that navigates through nested ModelLess or
  /// ModelLessArray structures.
  /// If the path cannot be fully resolved, the method returns the provided default value.
  /// [path] A '/'-separated string representing the navigation path.
  /// [def] A default value of type [R] that is returned if the path
  R getByPathString<R>(String path, {dynamic def}) {
    if (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    if (path.startsWith('/')) {
      path = path.substring(1, path.length);
    }

    List<dynamic> arr = <dynamic>[];
    for (var element in Uri(path: path).pathSegments) {
      arr.add(int.tryParse(element) ?? element);
    }
    return getByPath<R>(arr, def: def);
  }

  @override
  String toString() {
    return fields == null ? "[]" : fields.toString();
  }

  /// Creates a ModelLessArray from a List.
  /// Each element in the list is added to the ModelLessArray.
  /// If an element is a Map, it is converted to a ModelLess instance before being added.
  /// [list] The List to convert into a ModelLessArray.
  /// Returns a ModelLessArray containing the elements from the list.
  static ModelLessArray fromList(List list) {
    ModelLessArray arrayApiModels = ModelLessArray();
    for (var element in list) {
      if (element is Map) {
        arrayApiModels.set(ModelLess.fromDynamic(element));
      } else {
        arrayApiModels.set(element);
      }
    }

    return arrayApiModels;
  }

  /// Clears all elements from the array.
  /// If the fields list is null, it initializes it before clearing.
  /// After calling this method, the array will be empty.
  void clear() {
    fields ??= <T>[];
    fields!.clear();
  }
}
