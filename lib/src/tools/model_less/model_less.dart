import 'dart:convert';
import 'package:finch/src/tools/console.dart';
import 'package:finch/src/tools/convertor/string_validator.dart';
import 'mode_less_array.dart';

/// The ModelLess class is a dynamic, flexible data structure designed to handle
/// nested data structures and perform common operations such as accessing,
/// setting, and manipulating data within the structure. This class is
/// particularly useful in scenarios where you need to work with JSON-like data
/// structures that may contain nested maps or lists. Below is a detailed
/// breakdown of the key features and methods in the ModelLess class.
class ModelLess {
  Map<String, dynamic> fields = {};
  dynamic Function(dynamic value)? onGet;
  ModelLess({Map<String, dynamic>? fields, this.onGet}) {
    if (fields != null) {
      this.fields.addAll(fields);
    }
  }

  /// Removes a key-value pair from the model based on the provided key.
  /// If the key does not exist, the method does nothing.
  /// [key] The key of the key-value pair to be removed.
  void remove(String key) {
    fields.remove(key);
  }

  /// Retrieves the value associated with the specified key.
  /// If the key does not exist, returns an empty string.
  /// If an [onGet] callback is defined, it is invoked with the retrieved value
  /// before returning it.
  /// [key] The key whose associated value is to be retrieved.
  /// Returns the value associated with the key, or an empty string if the key does not exist.
  Object? operator [](String key) {
    if (!fields.keys.contains(key)) {
      return '';
    }
    var value = fields[key];
    if (onGet != null) {
      value = onGet!(value);
    }
    return value;
  }

  /// Sets the value for the specified key in the model.
  /// If the key already exists, its value is updated.
  /// If the key does not exist, a new key-value pair is added to the model.
  /// [key] The key for which the value is to be set.
  /// [value] The value to be associated with the key.
  void operator []=(String key, dynamic value) {
    set(key, value);
  }

  /// Retrieves a value of type [T] associated with the specified key.
  /// If the key contains '/', it treats the key as a path and navigates through
  /// the nested structure to retrieve the value.
  /// If the key does not exist, returns the provided default value [def].
  /// Supports basic types such as int, String, bool, List, and DateTime.
  /// [key] The key or path whose associated value is to be retrieved.
  /// [def] A default value of type [T] that is returned if the key does not exist.
  /// Returns the value associated with the key, or the default value if the key does not exist.
  T get<T>(String key, {T? def}) {
    if (key.contains('/')) {
      return getByPathString<T>(key);
    } else {
      if (this[key] == null) {
        return def as T;
      }
      if (T == String) {
        if (this[key].toString().isEmpty) return (def ?? '') as T;
        return this[key].toString() as T;
      }
      if (T == int) {
        var res = int.tryParse(this[key].toString());
        if (res != null) {
          return res as T;
        }
        return def as T;
      }

      if (T == List) {
        if (this[key] is T) {
          return this[key] as T;
        } else {
          return def as T;
        }
      }

      if (T == DateTime) {
        if (this[key] is T) {
          return this[key] as T;
        } else {
          return def as T;
        }
      }

      if (T == bool) {
        if (this[key] is String) {
          return this[key].toString().toBool as T;
        } else if (this[key] is T) {
          return this[key] as T;
        } else if (this[key] == null && def == null) {
          return false as T;
        } else {
          return def as T;
        }
      }

      return this[key] as T;
    }
  }

  /// Retrieves a value of type [T] from the model using a specified path.
  /// The path is a list of keys and/or indices that navigate through nested ModelLess or
  /// ModelLessArray structures.
  /// If the path cannot be fully resolved, the method returns the provided default value.
  /// [path] A list of keys and/or indices representing the navigation path.
  /// [def] A default value of type [T] that is returned if the path cannot be resolved.
  /// Returns the value of type [T] at the specified path, or the default value if the path cannot be resolved.
  T getByPath<T>(List<dynamic> path, {dynamic def}) {
    try {
      var key = path.removeAt(0);
      if (path.isEmpty) {
        return get<T>(key, def: def);
      } else {
        if (path[0] is int) {
          var index = path.removeAt(0) as int;
          var valueKey = get<dynamic>(key);
          var valueIndex = valueKey.get<dynamic>(index);

          if ((valueIndex is ModelLess || valueIndex is ModelLessArray) &&
              path.isNotEmpty) {
            return valueIndex.getByPath<dynamic>(path, def: def);
          }
          return valueIndex as T;
        }
        return get<ModelLess>(key).getByPath<T>(path, def: def);
      }
    } catch (e) {
      Console.e(e);
      if (T == String && def == null) {
        return "" as T;
      }
      return def as T;
    }
  }

  /// if the path cannot be fully resolved, the method returns the provided default value.
  /// [path] A '/'-separated string representing the navigation path.
  /// [def] A default value of type [T] that is returned if the path cannot be resolved.
  /// Returns the value of type [T] at the specified path, or the default value if the path cannot be resolved.
  /// For example, the path is a String path for access to a node. for example "posts/news/1/title"
  T getByPathString<T>(String path, {dynamic def}) {
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

    return getByPath<T>(arr, def: def);
  }

  /// add or set a new node to the model
  void set(String key, dynamic value) {
    fields[key] = value;
  }

  /// making a new model from a json string
  factory ModelLess.fromJson(String jsonString) {
    return ModelLess.fromMap(json.decode(jsonString));
  }

  factory ModelLess.fromDynamic(dynamic val) {
    return ModelLess.fromMap(Map<String, dynamic>.from(val));
  }

  /// making a new model from a map
  factory ModelLess.fromMap(Map map) {
    ModelLess apiModels = ModelLess();
    map.forEach((key, value) {
      if (value is List) {
        apiModels.set(key, ModelLessArray.fromList(value));
      } else if (value is Map) {
        apiModels.set(key, ModelLess.fromMap(value));
      } else {
        apiModels.set(key, value);
      }
    });

    return apiModels;
  }

  @override
  String toString() => fields.toString();

  /// Converts the ModelLess instance to a Map&lt;String, dynamic&gt;.
  /// Each key-value pair in the fields map is added to the resulting map.
  /// If a value is of type DateTime, it is converted to a string representation.
  /// Returns a map representation of the ModelLess instance.
  Map<String, dynamic> toMap() {
    Map<String, dynamic> f = {};
    fields.forEach((key, value) {
      if (value is DateTime) {
        f[key] = value.toString();
      } else {
        f[key] = value;
      }
    });

    return f;
  }

  /// Converts a list of ModelLess instances to a list of maps.
  /// Each ModelLess instance in the input list is converted to a map using the
  /// `toMap` method, and the resulting maps are collected into a new list.
  /// [list] The list of ModelLess instances to be converted.
  /// Returns a list of maps, where each map corresponds to a ModelLess instance.
  static List<Map<String, dynamic>> toListMap(List<ModelLess> list) {
    List<Map<String, dynamic>> res = [];
    for (var l in list) {
      res.add(l.toMap());
    }
    return res;
  }
}
