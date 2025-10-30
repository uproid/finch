import 'package:mongo_dart/mongo_dart.dart';
import 'package:finch/src/tools/console.dart';
import 'package:finch/src/tools/convertor/convert_strings.dart';
import 'package:finch/src/tools/convertor/string_validator.dart';

/// A set of extension methods for dynamic types to facilitate type conversion
/// and provide default values when conversion is not possible.
/// These methods help in safely converting dynamic values to specific types
/// such as int, double, String, bool, List, ObjectId, and DateTime.
/// Each method allows specifying a default value to return if the conversion fails.
/// Example usage:
/// ```dart
/// dynamic value = "123";
/// int intValue = value.asInt(def: 0); // Converts to int, returns 123
/// String strValue = value.asString(def: "default"); // Converts to String, returns "123"
/// bool boolValue = value.asBool(def: false); // Converts to bool, returns false
/// List listValue = value.asList(def: []); // Converts to List, returns []
/// ObjectId oidValue = value.asObjectId(def: ObjectId()); // Converts to ObjectId, returns a new ObjectId
/// DateTime dateTimeValue = value.asDateTime(def: DateTime.now()); // Converts to DateTime, returns current date and time
/// ```
extension FormatHelper on dynamic {
  /// Converts the dynamic value to an integer.
  /// If conversion fails, returns the provided default value or 0.
  /// [def] The default value to return if conversion fails.
  /// Returns the integer representation of the dynamic value or the default value.
  int asInt({int? def}) {
    return int.tryParse(toString()) ?? def ?? 0;
  }

  /// Converts the dynamic value to a double.
  /// If conversion fails, returns the provided default value or 0.0.
  /// [def] The default value to return if conversion fails.
  /// Returns the double representation of the dynamic value or the default value.
  double asDouble({double? def}) {
    return double.tryParse(toString()) ?? def ?? 0.0;
  }

  /// Converts the dynamic value to a num (either int or double).
  /// If conversion fails, returns the provided default value or 0.
  /// [def] The default value to return if conversion fails.
  /// Returns the num representation of the dynamic value or the default value.
  num asNum({num? def}) {
    return num.tryParse(toString()) ?? def ?? 0;
  }

  /// Converts the dynamic value to a String.
  /// If the value is null or empty after trimming, returns the provided default value or an empty string.
  /// [def] The default value to return if the dynamic value is null or empty.
  /// [trim] Whether to trim whitespace from the string (default is true).
  /// Returns the String representation of the dynamic value or the default value.
  String asString({String? def, bool trim = true}) {
    def ??= '';
    var res = (this ?? def).toString();
    if (trim) {
      res = res.trim();
    }
    return res.isEmpty ? def : res;
  }

  /// Converts the dynamic value to a boolean.
  /// If the value is null, returns the provided default value or false.
  /// The conversion considers '1' and 'true' (case insensitive) as true,
  /// and any other value as false.
  /// [def] The default value to return if the dynamic value is null.
  /// Returns the boolean representation of the dynamic value or the default value.
  bool asBool({bool? def}) {
    var value = this ?? def;
    return value.toString().toBool;
  }

  List<T> asList<T>({List<T>? def}) {
    try {
      if (T == ObjectId) {
        final res = <ObjectId>[];

        for (var e in this) {
          if (e is ObjectId) {
            res.add(e);
          } else if (e is String) {
            ObjectId? oid = e.toString().oID;
            if (oid != null) {
              res.add(oid);
            }
          }
        }

        return res as List<T>;
      }
      if (this is List) {
        return List<T>.from(map((x) => x));
      }

      if (this is String) {
        var res = (toString()).split(',').map((e) {
          if (T == String) {
            return e.toString().trim() as T;
          }
          return e as T;
        }).toList();
        res.removeWhere((element) => element == null || element == '');
        return res;
      }

      if (this is T) {
        return [this as T];
      }
      return def ?? [];
    } catch (e) {
      Console.e(e);
      return def ?? [];
    }
  }

  /// Converts the dynamic value to a MongoDB ObjectId.
  /// If the value is already an ObjectId, it is returned as is.
  /// If the value is a String, it attempts to parse it into an ObjectId.
  /// If parsing fails or the value is null, returns the provided default ObjectId or a new ObjectId.
  /// [def] The default ObjectId to return if conversion fails.
  /// Returns the ObjectId representation of the dynamic value or the default ObjectId.
  ObjectId asObjectId({ObjectId? def}) {
    if (this is ObjectId) {
      return this;
    }

    var res = toString().trim();
    res = res.replaceAll('ObjectId("', '').replaceAll('")', 'replace');
    return res.oID ?? def ?? ObjectId();
  }

  /// Converts the dynamic value to a DateTime object.
  /// If the value is null, returns the provided default DateTime or a DateTime set to UTC 1977.
  /// If the value is a String, it attempts to parse it into a DateTime.
  /// If parsing fails, returns null.
  /// [def] The default DateTime to return if the value is null.
  /// Returns the DateTime representation of the dynamic value or the default DateTime.
  DateTime? asDateTime({DateTime? def}) {
    var value = this ?? def;
    if (value == null) {
      return DateTime.utc(1977);
    }
    var res = DateTime.tryParse(value.toString().trim());
    return res;
  }

  /// Attempts to cast the dynamic value to a specified type [T].
  /// If the value is null or cannot be cast to [T], returns the provided default value or null.
  /// Supports basic types such as int, double, num, String, bool, List, ObjectId, and DateTime.
  /// [def] The default value to return if casting fails.
  /// Returns the value cast to type [T] or the default value.
  T? asCast<T>({T? def}) {
    var value = this as Object?;
    if (value == null) {
      return def;
    }

    switch (T.toString()) {
      case 'int':
        return value.asInt(def: def as int) as T;
      case 'double':
        return value.asDouble(def: def as double) as T;
      case 'num':
        return value.asNum(def: def as num) as T;
      case 'String':
        return value.asString(def: def as String) as T;
      case 'bool':
        return value.asBool(def: def as bool) as T;
      case 'List':
        return value.asList(def: def as List) as T;
      case 'ObjectId':
        return value.asObjectId(def: def as ObjectId) as T;
      case 'DateTime':
        return value.asDateTime(def: def as DateTime) as T;
      case 'int?':
        int? defVal = (def) as int?;
        return value.asInt(def: defVal) as T?;
      case 'double?':
        var defVal = (def) as double?;
        return value.asDouble(def: defVal) as T?;
      case 'num?':
        var defVal = (def) as num?;
        return value.asNum(def: defVal) as T?;
      case 'String?':
        var defVal = (def) as String?;
        return value.asString(def: defVal) as T?;
      case 'bool?':
        var defVal = (def) as bool?;
        return value.asBool(def: defVal) as T?;
      case 'List?':
        var defVal = (def) as List?;
        return value.asList(def: defVal) as T?;
      case 'ObjectId?':
        var defVal = (def) as ObjectId?;
        return value.asObjectId(def: defVal) as T?;
      case 'DateTime?':
        var defVal = (def) as DateTime?;
        return value.asDateTime(def: defVal) as T?;
      default:
        return def;
    }
  }
}
