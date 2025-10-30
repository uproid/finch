import 'package:mongo_dart/mongo_dart.dart';

/// An abstract class representing a MongoDB collection with utility methods.
/// The `DBCollection` class provides an abstraction over a MongoDB collection,
/// offering various methods to interact with the database, such as checking for
/// the existence of a document by its ID, updating fields, and more. This class
/// is meant to be extended by other classes for more specific collection implementations.
abstract class DBCollection {
  /// The name of the MongoDB collection.
  String name;

  /// The MongoDB database instance.
  Db db;

  /// Provides direct access to the underlying MongoDB collection.
  /// The collection is retrieved using the `db.collection(name)` method.
  DbCollection get collection => db.collection(name);

  /// Constructor to initialize the [name] of the collection and the [db] instance.
  /// When initialized, the constructor checks if the collection exists in the database,
  /// and creates it if it does not already exist.
  DBCollection({required this.name, required this.db}) {
    db.getCollectionNames().then((coll) async {
      if (!coll.contains(name)) {
        await db.createCollection(name);
      }
    });
  }

  /// Checks if a document with the given ID exists in the collection.
  /// The [idField] should be a valid MongoDB ObjectId string.
  /// Returns `true` if the document exists, otherwise `false`.
  Future<bool> existId(String idField) async {
    var id = ObjectId.tryParse(idField);
    if (id == null) return false;
    var count = await collection.count(where.id(id));
    return count > 0;
  }

  /// Checks if a document with the specified [field] and [value] exists in the collection.
  /// Returns `true` if the document exists, otherwise `false`.
  Future<bool> exist(String field, Object value) async {
    return await getCount(field: field, value: value) > 0;
  }

  /// Retrieves the count of documents in the collection based on the specified filters.
  /// You can filter documents by providing a [field] and [value], or by specifying a
  /// more complex [filter] using a map. If no filter is provided, the total count of
  /// documents in the collection is returned.
  /// Returns the count of matching documents.
  Future<int> getCount({
    String? field,
    Object? value,
    Map<String, Object?>? filter,
  }) async {
    if (field != null && value != null) {
      var count = await collection.modernCount(
          selector: where.eq(field, value), filter: filter);
      return count.count;
    }
    return (await collection.modernCount(filter: filter)).count;
  }

  /// Checks if the collection is empty.
  /// Returns `true` if the collection has no documents, otherwise `false`.
  Future<bool> get isEmpty async => (await getCount()) == 0;

  /// Checks if the collection is not empty.
  /// Returns `true` if the collection contains documents, otherwise `false`.
  Future<bool> get isNotEmpty async => !(await isEmpty);

  /// Deletes a document from the collection by its ID.
  /// The [id] should be a valid MongoDB ObjectId string.
  /// Returns `true` if the deletion was successful, otherwise `false`.
  Future<bool> delete(String id) async {
    var oid = ObjectId.tryParse(id);
    if (oid != null) {
      var res = await collection.deleteOne(where.id(oid));
      return res.success;
    }

    return false;
  }

  /// Creates a copy of a document by its ID and inserts it as a new document.
  /// The [id] should be a valid MongoDB ObjectId string. The copied document
  /// will have a new ObjectId assigned.
  Future<void> copy(String id) async {
    var oid = ObjectId.tryParse(id);
    if (oid != null) {
      var data = await collection.findOne(where.id(oid));
      if (data != null) {
        data.remove('_id');
        await collection.insertOne(data);
      }
    }
  }

  /// Updates a specific field of a document by its ID.
  /// The [id] should be a valid MongoDB ObjectId string. The [field] specifies
  /// the field to be updated, and [value] is the new value to be assigned.
  Future<void> updateField(String id, String field, Object? value) async {
    var oid = ObjectId.tryParse(id);
    if (oid != null && await existId(id)) {
      await collection.updateOne(where.id(oid), modify.set(field, value));
    }
  }

  /// Updates multiple fields of a document by its ID.
  /// The [id] should be a valid MongoDB ObjectId string. The [fields] map contains
  /// the fields to be updated and their new values.
  Future<void> updateFields(String id, Map<String, dynamic> fields) async {
    var oid = ObjectId.tryParse(id);
    if (oid != null) {
      var row = await collection.findOne(where.id(oid));
      if (row != null) {
        row.addAll(fields);
        await collection.modernUpdate(where.id(oid), row);
      }
    }
  }

  /// Updates a specific field for all documents that match the given [filter].
  /// The [field] specifies the field to be updated, and [value] is the new value
  /// to be assigned. The [filter] map is used to specify the matching condition.
  Future<void> updateAllForField({
    required String field,
    required Object? value,
    required Map<String, Object?>? filter,
  }) async {
    await collection.updateMany(
      filter,
      modify.set(field, value),
    );
  }

  /// Deletes all documents from the collection.
  /// Returns `true` if the deletion was successful, otherwise `false`.
  /// You have to be careful when using this method, as it will delete all documents in the collection.
  Future<bool> deleteAll() async {
    var res = await collection.deleteMany({});
    return res.isSuccess;
  }
}
