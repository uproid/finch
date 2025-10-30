import 'package:json_annotation/json_annotation.dart';

/// A custom [JsonConverter] for serializing and deserializing [DateTime] objects.
/// This converter handles the conversion of [DateTime] objects to and from JSON.
/// It provides a default value of `DateTime.parse('2000-01-01 00:00')` when the
/// JSON input is null. This ensures that a non-null [DateTime] object is always returned
/// even if the input JSON is null.
/// This converter can be used with the `json_annotation` package to facilitate JSON
/// serialization and deserialization for Dart objects that include [DateTime] properties.
class DateTimeConverter implements JsonConverter<DateTime, DateTime?> {
  /// Creates a new instance of [DateTimeConverter].
  const DateTimeConverter();

  /// Converts the JSON value to a [DateTime] object.
  ///
  /// If the JSON value is null, it returns a default [DateTime] object representing
  /// `2000-01-01 00:00`.
  ///
  /// [json] is the JSON value to be converted to a [DateTime] object.
  ///
  /// Returns a [DateTime] object.
  @override
  DateTime fromJson(DateTime? json) =>
      json ?? DateTime.parse('2000-01-01 00:00');

  /// Converts the [DateTime] object to a JSON value.
  ///
  /// This method returns the [DateTime] object as is. The serialization format is
  /// dependent on the implementation of the [DateTime] class's `toString` method.
  ///
  /// [object] is the [DateTime] object to be converted to a JSON value.
  ///
  /// Returns the [DateTime] object as a JSON value.
  @override
  DateTime? toJson(DateTime object) => object;
}
