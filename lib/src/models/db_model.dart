import 'package:mongo_dart/mongo_dart.dart';

/// An abstract class that represents a database model with serialization capabilities.
/// The [DBModel] class provides a blueprint for creating database models that can be converted into a map
/// of parameters for MongoDB operations. It also provides a utility method to convert a list of such models
/// into a list of maps, which can be useful for batch operations.
abstract class DBModel {
  /// Converts the model instance to a map of parameters for MongoDB operations.
  ///
  /// The [toParams] method should be implemented by subclasses to define how the model is serialized
  /// into a map of key-value pairs suitable for database storage or updates.
  ///
  /// The optional [db] parameter can be passed to provide the database context if needed for serialization.
  ///
  /// Returns a [Future] containing a [Map] of key-value pairs representing the model.
  Future<Map<String, Object?>> toParams({Db? db});

  /// Converts a list of [DBModel] instances to a list of maps for MongoDB operations.
  ///
  /// The [toListParams] method takes a list of [DBModel] instances and asynchronously converts each model
  /// to a map using the [toParams] method. The resulting list of maps can be used for batch database operations.
  ///
  /// The optional [db] parameter can be passed to provide the database context if needed during serialization.
  ///
  /// Example:
  /// ```dart
  /// List<DBModel> models = [model1, model2, model3];
  /// List<Map<String, Object?>> serializedModels = await DBModel.toListParams(models);
  /// ```
  ///
  /// Returns a [Future] containing a [List] of maps representing the serialized models.
  static Future<List<Map<String, Object?>>> toListParams(List<DBModel> list,
      {Db? db}) async {
    var res = <Map<String, Object?>>[];
    for (var element in list) {
      res.add(await element.toParams(db: db));
    }
    return res;
  }
}
