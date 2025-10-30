import 'package:json_annotation/json_annotation.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// A custom [JsonConverter] for converting between [ObjectId] and [String].
/// This converter facilitates the serialization and deserialization of MongoDB's [ObjectId]
/// objects to and from JSON strings. It provides a conversion between the `ObjectId` type
/// used in MongoDB and the `String` type commonly used in JSON data.
/// This converter is useful when working with MongoDB in Dart applications, particularly
/// when using the `json_annotation` package for JSON serialization and deserialization.
class IDConverter implements JsonConverter<String, ObjectId?> {
  /// Creates a new instance of [IDConverter].
  const IDConverter();

  /// Converts a JSON value to a [String] representation of [ObjectId].
  ///
  /// If the [json] value is null, an empty string is returned. Otherwise, the `oid` property
  /// of the [ObjectId] is returned as a [String].
  ///
  /// [json] is the JSON value to be converted to a [String] representation of [ObjectId].
  ///
  /// Returns a [String] representing the [ObjectId].
  @override
  String fromJson(ObjectId? json) {
    return json == null ? '' : json.oid;
  }

  /// Converts a [String] representation of [ObjectId] to an [ObjectId].
  ///
  /// If the [object] string is empty, null is returned. Otherwise, attempts to parse the string
  /// into an [ObjectId] using [ObjectId.tryParse]. If parsing fails, null is returned.
  ///
  /// [object] is the [String] representation of the [ObjectId] to be converted.
  ///
  /// Returns an [ObjectId] or null if the string is empty or parsing fails.
  @override
  ObjectId? toJson(String object) {
    return object.isEmpty ? null : ObjectId.tryParse(object);
  }
}
