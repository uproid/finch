import 'package:capp/capp.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:finch/src/db/mongo/error_codes.dart';
import 'package:finch/src/forms/db_form_free.dart';
import 'package:finch/finch_console.dart';
import 'package:finch/finch_model.dart';
import 'package:finch/finch_route.dart';
import 'package:finch/finch_tools.dart';
import 'package:finch/finch_ui.dart';

/// An abstract class representing a MongoDB collection with utility methods.
/// The [DBCollectionFree] class provides an abstraction over a MongoDB collection,
/// offering various methods to interact with the database, such as checking for
/// the existence of a document by its ID, updating fields, form validation,
/// and generating REST API routes. This class is meant to be extended by other
/// classes for more specific collection implementations.
/// Features include:
/// - Document CRUD operations (Create, Read, Update, Delete)
/// - Form validation using [DBFormFree]
/// - Index management
/// - Event handling for database operations
/// - Automatic REST API route generation
/// - Search and filter capabilities
/// - Pagination support
abstract class DBCollectionFree {
  /// List of all registered collection instances for design printing.
  static final List<DBCollectionFree> _allCollectionFree = [];

  /// Prints the design and structure of all registered collections.
  /// This static method provides a comprehensive overview of all collection
  /// instances, including their fields, counts, events, and indexes.
  /// The output is displayed as JSON format using [Console.json].
  /// This is useful for debugging and understanding the database schema
  /// during development.
  static void printDesign() async {
    CappConsole.clear();
    var json = <String, Object?>{};
    for (var collection in _allCollectionFree) {
      var jsonCollection = <String, Object?>{};
      var fieldsJson = <String, Object?>{};
      for (var field in collection.form.fields.entries) {
        var fieldModel = field.value;
        fieldsJson.addAll({
          field.key: {
            'type': fieldModel.type,
            'default': fieldModel.defaultValue?.call(),
            'readonly': fieldModel.readonly,
            'searchable': fieldModel.searchable,
            'filterable': fieldModel.filterable,
            'validators': fieldModel.validators.length,
            'isHiddenJson': fieldModel.hideJson,
          },
        });
      }

      jsonCollection.addAll({
        'name': collection.name,
        'db': collection.db.databaseName,
        'count': await collection.collection.count(),
        'fields': fieldsJson,
        'events': {
          'onInsert': collection.collectionEvent.onInsert._listeners.length,
          'onUpdate': collection.collectionEvent.onUpdate._listeners.length,
          'onDelete': collection.collectionEvent.onDelete._listeners.length,
        },
        'indexes': await collection.collection.getIndexes(),
      });
      json[collection.name] = jsonCollection;
    }
  }

  /// The form definition containing field validators and structure.
  DBFormFree form;

  /// Event handlers for collection operations (insert, update, delete).
  CollectionEvent collectionEvent = CollectionEvent();

  /// Map of database indexes to be created for this collection.
  var indexes = <String, DBIndex>{};

  /// The name of the MongoDB collection.
  String name;

  /// The MongoDB database instance.
  Db db;

  /// Provides direct access to the underlying MongoDB collection.
  /// The collection is retrieved using the `db.collection(name)` method.
  DbCollection get collection => db.collection(name);

  /// Constructor to initialize the collection with required parameters.
  /// Creates a new database collection instance and automatically handles:
  /// - Collection registration in the global list
  /// - Collection creation if it doesn't exist in the database
  /// - Index renewal and management
  /// Parameters:
  /// * [name] - The name of the MongoDB collection
  /// * [db] - The MongoDB database instance
  /// * [form] - The form definition with field validators
  /// * [indexes] - Optional map of database indexes to create
  /// Example:
  /// ```dart
  /// final userCollection = UserCollection(
  ///   name: 'users',
  ///   db: mongoDb,
  ///   form: userForm,
  ///   indexes: {'email': DBIndex(key: 'email', unique: true)},
  /// );
  /// ```
  DBCollectionFree({
    required this.name,
    required this.db,
    required this.form,
    this.indexes = const {},
  }) {
    _allCollectionFree.add(this);

    db.getCollectionNames().then((coll) async {
      if (!coll.contains(name)) {
        await db.createCollection(name);
      }
      _renewIndexes();
    });
  }

  /// Renews and recreates all indexes defined for this collection.
  /// This private method:
  /// 1. Drops all existing indexes
  /// 2. Creates new indexes based on the [indexes] map
  /// 3. Assigns default names if not provided
  /// This is automatically called during collection initialization.
  void _renewIndexes() async {
    if (indexes.isNotEmpty) {
      collection.getIndexes().then((res) async {
        for (var oldIndex in res) {
          await collection.dropIndexes(oldIndex['name']);
        }
        for (var key in indexes.keys) {
          var index = indexes[key]!;
          index.name ??= "_${key}_";

          await createIndex(
            background: index.background,
            dropDups: index.dropDups,
            keys: index.keys,
            name: index.name,
            partialFilterExpression: index.partialFilterExpression,
            sparse: index.sparse,
            unique: index.unique,
            modernReply: index.modernReply,
            key: index.key,
            collation: index.collation,
          );
        }
      });
    }
  }

  /// Creates a database index on the collection.
  /// This method creates a new index on the MongoDB collection with the
  /// specified options. Indexes improve query performance and can enforce
  /// uniqueness constraints.
  /// Parameters:
  /// * [key] - Single field name to index (alternative to [keys])
  /// * [keys] - Map of field names and index direction (1 for ascending, -1 for descending)
  /// * [unique] - Whether the index should enforce uniqueness
  /// * [sparse] - Whether to create a sparse index (ignores null values)
  /// * [background] - Whether to build the index in the background
  /// * [dropDups] - Whether to drop duplicate documents during index creation
  /// * [partialFilterExpression] - Filter expression for partial indexes
  /// * [name] - Custom name for the index
  /// * [modernReply] - Whether to use modern reply format
  /// * [collation] - Collation options for the index
  /// Returns a map containing the result of the index creation operation.
  /// Throws [MongoDartError] if the MongoDB server doesn't support OpMsg.
  /// Throws [ArgumentError] if both [key] and [keys] are provided, or if neither is provided.
  /// Example:
  /// ```dart
  /// await collection.createIndex(
  ///   key: 'email',
  ///   unique: true,
  ///   sparse: true,
  /// );
  /// ```
  Future<Map<String, dynamic>> createIndex({
    String? key,
    Map<String, dynamic>? keys,
    bool? unique,
    bool? sparse,
    bool? background,
    bool? dropDups,
    Map<String, dynamic>? partialFilterExpression,
    String? name,
    bool? modernReply,
    Map<dynamic, dynamic>? collation,
  }) async {
    if (!db.masterConnection.serverCapabilities.supportsOpMsg) {
      throw MongoDartError('Use createIndex() method on db (before 3.6)');
    }

    modernReply ??= true;
    var indexOptions = CreateIndexOptions(
      collection,
      uniqueIndex: unique == true,
      sparseIndex: sparse == true,
      background: background == true,
      dropDuplicatedEntries: dropDups == true,
      partialFilterExpression: partialFilterExpression,
      indexName: name,
      collation: collation,
    );

    var indexOperation =
        CreateIndexOperation(db, collection, _setKeys(key, keys), indexOptions);

    var res = await indexOperation.execute();
    if (res[keyOk] == 0.0) {
      // It should be better to create a MongoDartError,
      // but, for compatibility reasons, we throw the received map.
      throw res;
    }
    if (modernReply) {
      return res;
    }
    return db.getLastError();
  }

  Map<String, dynamic> _setKeys(String? key, Map<String, dynamic>? keys) {
    if (key != null && keys != null) {
      throw ArgumentError('Only one parameter must be set: key or keys');
    }

    if (key != null) {
      keys = {};
      keys[key] = 1;
    }

    if (keys == null) {
      throw ArgumentError('key or keys parameter must be set');
    }

    return keys;
  }

  /// Validates data against the form definition.
  /// Performs comprehensive validation of input data based on the validators
  /// defined in the collection's form. This method can validate all fields
  /// or only specific fields if specified.
  /// Parameters:
  /// * [data] - The data to validate as a map of field names to values
  /// * [onlyCheckKeys] - Optional list of specific field names to validate.
  ///   If empty, all fields in the data will be validated.
  /// Returns a [FormResultFree] containing validation results and processed data.
  /// Example:
  /// ```dart
  /// var result = await collection.validate({
  ///   'name': 'John Doe',
  ///   'email': 'john@example.com',
  /// });
  /// if (result.success) {
  ///   print('Data is valid');
  /// } else {
  ///   print('Validation errors: ${result.errors}');
  /// }
  /// ```
  Future<FormResultFree> validate(
    Map<String, Object?> data, {
    List<String> onlyCheckKeys = const [],
  }) async {
    return form.validate(
      data,
      onlyCheckKeys: onlyCheckKeys,
    );
  }

  /// Inserts a new document into the collection.
  /// This method validates the data before insertion and triggers the
  /// [CollectionEvent.onInsert] event if the insertion is successful.
  /// Parameters:
  /// * [data] - The document data to insert as a map of field names to values
  /// Returns a [FormResultFree] containing:
  /// - Validation results
  /// - The inserted document with generated ID (if successful)
  /// - Error information (if validation or insertion fails)
  /// Example:
  /// ```dart
  /// var result = await collection.insert({
  ///   'name': 'Jane Doe',
  ///   'email': 'jane@example.com',
  ///   'age': 30,
  /// });
  /// if (result.success) {
  ///   print('Inserted with ID: ${result.formValues()['_id']}');
  /// }
  /// ```
  Future<FormResultFree> insert(Map<String, Object?> data) async {
    var validationResult = await validate(data);
    if (validationResult.success) {
      var result = await collection.insertOne(validationResult.formValues());

      if (!result.isFailure && result.document != null) {
        validationResult.updateValues(result.document!);
        await collectionEvent.onInsert.emit(result.document);
      } else {
        validationResult.updateFromMongoResponse(result.serverResponses);
      }
    }
    return validationResult;
  }

  /// Replaces an entire document by its ID.
  /// This method completely replaces the existing document with new data,
  /// after validating the new data. The document must exist for the operation
  /// to succeed. Triggers [CollectionEvent.onUpdate] if successful.
  /// Parameters:
  /// * [id] - The string representation of the document's ObjectId
  /// * [data] - The new document data to replace the existing document
  /// Returns:
  /// - [FormResultFree] containing the updated document if successful
  /// - `null` if the document ID is invalid or doesn't exist
  /// Example:
  /// ```dart
  /// var result = await collection.replaceOne('507f1f77bcf86cd799439011', {
  ///   'name': 'John Smith',
  ///   'email': 'john.smith@example.com',
  ///   'age': 35,
  /// });
  /// if (result?.success == true) {
  ///   print('Document replaced successfully');
  /// }
  /// ```
  Future<FormResultFree?> replaceOne(
    String id,
    Map<String, Object?> data,
  ) async {
    var oid = ObjectId.tryParse(id);
    if (oid == null || !await existId(id)) {
      return null;
    }

    FormResultFree validationResult = await validate(data);
    if (validationResult.success) {
      var newData = validationResult.formValues();
      newData['_id'] = oid;
      var result = await collection.replaceOne(
        where.id(oid),
        newData,
      );
      var newUpdate = await getById(id);
      if (result.isSuccess && newUpdate != null) {
        validationResult.updateValues(newUpdate);
        await collectionEvent.onUpdate.emit(newUpdate);
      }
    }

    return validationResult;
  }

  /// Merges new data with an existing document by its ID.
  /// This method performs a partial update by merging the provided data
  /// with the existing document. Only the specified fields are validated
  /// and updated, while other fields remain unchanged. Triggers
  /// [CollectionEvent.onUpdate] if successful.
  /// Parameters:
  /// * [id] - The string representation of the document's ObjectId
  /// * [data] - The partial data to merge with the existing document
  /// Returns:
  /// - [FormResultFree] containing the merged document if successful
  /// - `null` if the document doesn't exist
  /// Example:
  /// ```dart
  /// var result = await collection.mergeOne('507f1f77bcf86cd799439011', {
  ///   'email': 'newemail@example.com',  // Only update email
  ///   'lastLogin': DateTime.now(),      // Add new field
  /// });
  /// if (result?.success == true) {
  ///   print('Document merged successfully');
  /// }
  /// ```
  Future<FormResultFree?> mergeOne(
    String id,
    Map<String, Object?> data,
  ) async {
    var oldData = await getById(id);

    if (oldData == null) {
      return null;
    }

    FormResultFree validationResult = await validate(
      data,
      onlyCheckKeys: data.keys.toList(),
    );
    var newData = validationResult.formValues();
    var mergedData = {
      ...oldData,
      ...newData,
    };
    if (validationResult.success) {
      var result = await collection.replaceOne(
        where.id(id.oID!),
        mergedData,
        upsert: false,
      );

      var newUpdate = await getById(id);
      if (result.isSuccess && newUpdate != null) {
        validationResult.updateValues(newUpdate);
        await collectionEvent.onUpdate.emit(newUpdate);
      }
      return validationResult;
    } else {
      return await validate(mergedData);
    }
  }

  /// Gets the count of documents in the collection.
  /// This method returns the total number of documents matching the specified
  /// criteria. If no criteria are provided, it returns the total count of
  /// all documents in the collection.
  /// Parameters:
  /// * [field] - Optional field name to filter by
  /// * [value] - Optional value to match for the specified field
  /// * [filter] - Optional additional filter criteria
  /// Returns the number of matching documents.
  /// Example:
  /// ```dart
  /// // Get total count
  /// int total = await collection.getCount();
  /// // Get count of active users
  /// int activeUsers = await collection.getCount(
  ///   field: 'status',
  ///   value: 'active'
  /// );
  /// ```
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

  /// Retrieves multiple documents from the collection with flexible options.
  /// This method provides comprehensive querying capabilities including
  /// filtering, sorting, pagination, and field projection. The results
  /// are automatically processed through the form validation system.
  /// Parameters:
  /// * [selector] - Query selector for filtering documents
  /// * [filter] - Additional filter criteria
  /// * [findOptions] - MongoDB find operation options
  /// * [hint] - Index hint for query optimization
  /// * [skip] - Number of documents to skip (for pagination)
  /// * [sort] - Sort order specification
  /// * [limit] - Maximum number of documents to return
  /// * [hintDocument] - Document-based index hint
  /// * [projection] - Fields to include/exclude in results
  /// * [rawOptions] - Raw MongoDB query options
  /// Returns a list of documents as maps, processed through form validation.
  /// Example:
  /// ```dart
  /// var users = await collection.getAll(
  ///   filter: {'status': 'active'},
  ///   sort: {'createdAt': -1},
  ///   limit: 10,
  ///   skip: 20,
  /// );
  /// ```
  Future<List<Map<String, Object?>>> getAll({
    SelectorBuilder? selector,
    Map<String, Object?>? filter,
    FindOptions? findOptions,
    String? hint,
    int? skip,
    Map<String, Object>? sort,
    int? limit,
    Map<String, Object>? hintDocument,
    Map<String, Object>? projection,
    Map<String, Object>? rawOptions,
  }) async {
    skip ??= 0;
    skip = skip < 1 ? null : skip;

    var results = <Map<String, Object?>>[];
    var result = collection.modernFind(
      selector: selector,
      filter: filter,
      findOptions: findOptions,
      hint: hint,
      skip: skip,
      sort: sort,
      limit: limit,
      hintDocument: hintDocument,
      projection: projection,
      rawOptions: rawOptions,
    );

    List<String>? selectedFields;
    if (selector != null && selector.paramFields.isNotEmpty) {
      selectedFields = selector.paramFields.keys.toList();
    }

    for (var element in await result.toList()) {
      results.add(await toModel(element, selectedFields: selectedFields));
    }

    return results;
  }

  /// Checks if a document with the given ID exists in the collection.
  /// This method validates the ID format and checks for document existence.
  /// The [idField] should be a valid MongoDB ObjectId string representation.
  /// Parameters:
  /// * [idField] - String representation of the MongoDB ObjectId
  /// Returns `true` if the document exists, `false` if it doesn't exist
  /// or if the ID format is invalid.
  /// Example:
  /// ```dart
  /// bool exists = await collection.existId('507f1f77bcf86cd799439011');
  /// if (exists) {
  ///   print('Document found');
  /// }
  /// ```
  Future<bool> existId(String idField) async {
    var id = ObjectId.tryParse(idField);
    return existOid(id);
  }

  /// Checks if a document with the given ObjectId exists in the collection.
  /// This method performs the actual existence check using the MongoDB
  /// ObjectId directly, providing better performance than string-based checks.
  /// Parameters:
  /// * [id] - The MongoDB ObjectId to check
  /// Returns `true` if the document exists, `false` if it doesn't exist
  /// or if the ID is null.
  /// Example:
  /// ```dart
  /// var objectId = ObjectId.fromHexString('507f1f77bcf86cd799439011');
  /// bool exists = await collection.existOid(objectId);
  /// ```
  Future<bool> existOid(ObjectId? id) async {
    if (id == null) return false;
    var count = await collection.modernCount(selector: where.id(id));
    return count.count > 0;
  }

  /// Deletes a document from the collection by its ID.
  /// This method validates the ID format and attempts to delete the
  /// corresponding document. Triggers [CollectionEvent.onDelete] if successful.
  /// Parameters:
  /// * [id] - String representation of the MongoDB ObjectId to delete
  /// Returns `true` if the deletion was successful, `false` if the ID
  /// is invalid or the document doesn't exist.
  /// Example:
  /// ```dart
  /// bool deleted = await collection.delete('507f1f77bcf86cd799439011');
  /// if (deleted) {
  ///   print('Document deleted successfully');
  /// }
  /// ```
  Future<bool> delete(String id) async {
    var oid = ObjectId.tryParse(id);
    if (oid != null) {
      return deleteOid(oid);
    }

    return false;
  }

  /// Deletes a document from the collection by its ObjectId.
  /// This method performs the actual deletion using the MongoDB ObjectId
  /// directly. It retrieves the document before deletion to trigger the
  /// [CollectionEvent.onDelete] event with the deleted document data.
  /// Parameters:
  /// * `oid` - The MongoDB ObjectId of the document to delete
  /// Returns `true` if the deletion was successful, `false` otherwise.
  /// Example:
  /// ```dart
  /// var objectId = ObjectId.fromHexString('507f1f77bcf86cd799439011');
  /// bool deleted = await collection.deleteOid(objectId);
  /// ```
  Future<bool> deleteOid(ObjectId oid) async {
    var oldData = await getByOid(oid);
    var res = await collection.deleteOne(where.id(oid));
    var result = res.success && res.nRemoved == 1;
    if (result && oldData != null) {
      await collectionEvent.onDelete.emit(oldData);
    }
    return result;
  }

  /// Creates a copy of a document by its ID and inserts it as a new document.
  /// This method retrieves an existing document, removes its `_id` field,
  /// and inserts it as a new document with a newly generated ObjectId.
  /// Triggers [CollectionEvent.onInsert] if the copy operation is successful.
  /// Parameters:
  /// * [id] - String representation of the source document's ObjectId
  /// The method silently fails if the ID is invalid or the document doesn't exist.
  /// Example:
  /// ```dart
  /// await collection.copy('507f1f77bcf86cd799439011');
  /// // Creates a new document with the same data but different _id
  /// ```
  Future<void> copy(String id) async {
    var oid = ObjectId.tryParse(id);
    if (oid != null) {
      var data = await collection.findOne(where.id(oid));
      if (data != null) {
        data.remove('_id');
        var result = await collection.insertOne(data);
        if (result.isSuccess) {
          await collectionEvent.onInsert.emit(result.document);
        }
      }
    }
  }

  /// Updates a specific field of a document by its ID.
  /// This method validates the new field value using the form definition
  /// before updating the document. Only the specified field is validated
  /// and updated. Triggers [CollectionEvent.onUpdate] if successful.
  /// Parameters:
  /// * [id] - String representation of the document's ObjectId
  /// * [field] - Name of the field to update
  /// * [value] - New value for the field
  /// Returns:
  /// - [FormResultFree] containing the updated document if successful
  /// - `null` if the document ID is invalid, doesn't exist, or the field
  ///   is not defined in the form
  /// Example:
  /// ```dart
  /// var result = await collection.updateField(
  ///   '507f1f77bcf86cd799439011',
  ///   'status',
  ///   'inactive'
  /// );
  /// if (result?.success == true) {
  ///   print('Field updated successfully');
  /// }
  /// ```
  Future<FormResultFree?> updateField(
    String id,
    String field,
    Object? value,
  ) async {
    var oid = ObjectId.tryParse(id);
    if (oid == null || !await existId(id)) {
      return null;
    }

    var fieldModel = form.fields[field];
    if (fieldModel == null) {
      return null;
    }

    DBFormFree newForm = DBFormFree(fields: {field: fieldModel});
    FormResultFree formResult = await newForm.validate({field: value});

    if (formResult.success) {
      await collection.updateOne(where.id(oid), modify.set(field, value));
      var newData = await getById(id);
      if (newData != null) {
        await collectionEvent.onUpdate.emit(newData);
        return toFormResult(newData);
      }
    }

    return formResult;
  }

  /// Retrieves a single document by its ID.
  /// This method converts the string ID to an ObjectId and delegates
  /// to [getByOid] for the actual retrieval. The returned document
  /// is processed through form validation.
  /// Parameters:
  /// * [id] - String representation of the document's ObjectId
  /// Returns the document as a map if found, `null` if not found or
  /// if the ID format is invalid.
  /// Example:
  /// ```dart
  /// var user = await collection.getById('507f1f77bcf86cd799439011');
  /// if (user != null) {
  ///   print('User name: ${user['name']}');
  /// }
  /// ```
  Future<Map<String, Object?>?> getById(String id) async {
    var oid = ObjectId.tryParse(id);
    return getByOid(oid);
  }

  /// Retrieves a single document by its ObjectId.
  /// This method performs the actual document retrieval using the MongoDB
  /// ObjectId directly. The returned document is processed through the
  /// form validation system to ensure proper data formatting.
  /// Parameters:
  /// * `oid` - The MongoDB ObjectId of the document to retrieve
  /// Returns the document as a map if found, `null` if not found or
  /// if the ObjectId is null.
  /// Example:
  /// ```dart
  /// var objectId = ObjectId.fromHexString('507f1f77bcf86cd799439011');
  /// var document = await collection.getByOid(objectId);
  /// ```
  Future<Map<String, Object?>?> getByOid(ObjectId? oid) async {
    if (oid == null || !await existOid(oid)) {
      return null;
    }

    var res = await collection.findOne(where.id(oid));
    if (res != null) {
      return await toModel(res);
    }
    return null;
  }

  /// Converts a raw MongoDB document to a validated model.
  /// This method processes a document through the form validation system
  /// to ensure proper data types and formatting. Optionally filters the
  /// result to include only selected fields.
  /// Parameters:
  /// * [document] - The raw MongoDB document to process
  /// * [selectedFields] - Optional list of field names to include in the result
  /// Returns a map containing the validated and formatted document data.
  /// Example:
  /// ```dart
  /// var rawDoc = await collection.collection.findOne({'_id': objectId});
  /// var processedDoc = await collection.toModel(
  ///   rawDoc,
  ///   selectedFields: ['name', 'email']
  /// );
  /// ```
  Future<Map<String, Object?>> toModel(
    Map<String, Object?> document, {
    List<String>? selectedFields,
  }) async {
    FormResultFree formResult = await validate(document);
    var res = formResult.formValues(selectedFields: selectedFields);
    return res;
  }

  /// Converts a raw MongoDB document to a FormResultFree object.
  /// This method processes a document through the form validation system
  /// and returns the complete validation result, which includes both the
  /// processed data and any validation information.
  /// Parameters:
  /// * [document] - The raw MongoDB document to process
  /// Returns a [FormResultFree] containing validation results and processed data.
  /// Example:
  /// ```dart
  /// var rawDoc = await collection.collection.findOne({'_id': objectId});
  /// var formResult = await collection.toFormResult(rawDoc);
  /// if (formResult.success) {
  ///   print('Document is valid');
  /// }
  /// ```
  Future<FormResultFree> toFormResult(Map<String, Object?> document) async {
    return await validate(document);
  }

  /// Generates search and filter criteria based on form field definitions.
  /// This method creates MongoDB query filters based on:
  /// - Searchable fields: Creates text-based search using regex patterns
  /// - Filterable fields: Creates exact-match filters for specific values
  /// Parameters:
  /// * [inputs] - Input data containing search terms and filter values
  /// * [searchFiled] - Name of the field containing the search term (default: 'search')
  /// Returns a MongoDB query filter object that can be used in find operations.
  /// The method automatically:
  /// - Builds OR conditions for searchable fields using regex patterns
  /// - Builds AND conditions for filterable fields using exact matches
  /// - Combines search and filter conditions appropriately
  /// Example:
  /// ```dart
  /// var filter = collection.getSearchableFilter(
  ///   inputs: {
  ///     'search': 'john',
  ///     'status': 'active',
  ///     'role': 'admin'
  ///   }
  /// );
  /// // Results in: {$and: [{$or: [name: /john/i, email: /john/i]}, {status: 'active', role: 'admin'}]}
  /// ```
  Map<String, Object?> getSearchableFilter({
    required Map<String, Object?> inputs,
    String searchFiled = 'search',
  }) {
    var resSearch = <String, Object?>{};
    if (inputs[searchFiled] != null &&
        inputs[searchFiled].toString().trim().isNotEmpty) {
      var searchOr = [];
      for (var key in form.fields.keys) {
        if (form.fields[key]!.searchable) {
          searchOr.add(
            DQ.field(key, DQ.like(inputs[searchFiled].toString().trim())),
          );
        }
      }

      if (searchOr.isNotEmpty) {
        resSearch = DQ.or(searchOr);
      }
    }

    var resFilter = <String, Object?>{};
    var filterAnd = [];
    for (var key in form.fields.keys) {
      if (form.fields[key]!.filterable) {
        if (inputs[key] != null) {
          filterAnd.add(
            DQ.field(
              key,
              ObjectDescovery.descovr(
                inputs[key],
                form.fields[key]!.type,
                def: form.fields[key]!.defaultValue?.call(),
              ),
            ),
          );
        }
      }
    }
    if (filterAnd.isNotEmpty) {
      resFilter = DQ.and(filterAnd);
    }

    var res = <String, Object?>{};
    if (resSearch.isNotEmpty && resFilter.isNotEmpty) {
      res = DQ.and([resSearch, resFilter]);
    }
    res = {...resSearch, ...resFilter};
    return res;
  }

  /// Generates a complete set of REST API routes for this collection.
  /// This method creates standard CRUD (Create, Read, Update, Delete) routes
  /// for the collection, providing a full REST API interface. Each route type
  /// can be individually enabled or disabled.
  /// Generated routes:
  /// - `GET /path` - List all documents (with optional pagination)
  /// - `GET /path/{id}` - Get single document by ID
  /// - `POST /path` - Create new document
  /// - `POST /path/{id}` - Update existing document
  /// - `GET /path/delete/{id}` - Delete document by ID
  /// Parameters:
  /// * [path] - Base URL path for the API routes
  /// * [useRouteAll] - Enable/disable the get all documents route
  /// * [useRouteDelete] - Enable/disable the delete document route
  /// * [useRouteInsert] - Enable/disable the create document route
  /// * [useRouteUpdate] - Enable/disable the update document route
  /// * [useRouteGetOne] - Enable/disable the get single document route
  /// * [paging] - Enable/disable pagination for the get all route
  /// * [pageSize] - Default page size for pagination
  /// * [orderReverse] - Default sort order (true for descending)
  /// * [orderBy] - Default field to sort by
  /// * [docAll] - Optional API documentation generator for get all route
  /// * [docDelete] - Optional API documentation generator for delete route
  /// * [docInsert] - Optional API documentation generator for insert route
  /// * [docUpdate] - Optional API documentation generator for update route
  /// * [docOne] - Optional API documentation generator for get one route
  /// * [children] - Additional child routes to include
  /// Returns a list of [FinchRoute] objects ready to be registered with the router.
  /// Example:
  /// ```dart
  /// var apiRoutes = userCollection.routes('/api/users');
  /// router.addRoutes(apiRoutes);
  /// ```
  List<FinchRoute> routes(
    String path, {
    bool useRouteAll = true,
    bool useRouteDelete = true,
    bool useRouteInsert = true,
    bool useRouteUpdate = true,
    bool useRouteGetOne = true,
    bool paging = true,
    int pageSize = 20,
    bool orderReverse = true,
    String orderBy = '_id',
    Future<ApiDoc>? Function()? docAll,
    Future<ApiDoc>? Function()? docDelete,
    Future<ApiDoc>? Function()? docInsert,
    Future<ApiDoc>? Function()? docUpdate,
    Future<ApiDoc>? Function()? docOne,
    List<FinchRoute> children = const [],
  }) {
    return <FinchRoute>[
      if (children.isNotEmpty)
        FinchRoute(
          path: path,
          children: children,
        ),
      if (useRouteAll)
        routeGetAll(
          path,
          paging: paging,
          pageSize: pageSize,
          orderReverse: orderReverse,
          orderBy: orderBy,
          apiDoc: docAll,
        ),
      if (useRouteGetOne) routeGetOne('$path/{id}', apiDoc: docOne),
      if (useRouteDelete)
        routeDeleteOne(
          '$path/delete/{id}',
          apiDoc: docDelete,
        ),
      if (useRouteInsert) routeInsert(path, apiDoc: docInsert),
      if (useRouteUpdate) routeUpdate('$path/{id}', apiDoc: docUpdate),
    ];
  }

  /// Creates a route for retrieving all documents in the collection.
  /// This method generates a REST API endpoint that handles listing all
  /// documents in the collection with support for:
  /// - Search functionality across searchable fields
  /// - Filtering by filterable fields
  /// - Pagination with customizable page sizes
  /// - Sorting by any field
  /// The route automatically handles query parameters for pagination,
  /// search terms, and filters based on the form field definitions.
  /// Parameters:
  /// * [path] - URL path for this route
  /// * [methods] - HTTP methods to accept (default: GET)
  /// * [apiDoc] - Optional API documentation generator
  /// * [auth] - Optional authentication controller
  /// * [extraPath] - Additional path segments to match
  /// * [excludePaths] - Path segments to exclude from matching
  /// * [hosts] - Host names to match (default: all hosts)
  /// * [params] - Additional route parameters
  /// * [permissions] - Required permissions for access
  /// * [ports] - Specific ports to match
  /// * [children] - Child routes
  /// * [paging] - Enable pagination
  /// * [pageSize] - Default page size
  /// * [orderReverse] - Default sort order
  /// * [orderBy] - Default sort field
  /// Returns a [FinchRoute] configured for listing documents.
  /// Example response:
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": [...],
  ///   "paging": {
  ///     "page": 1,
  ///     "pageSize": 20,
  ///     "total": 100,
  ///     "totalPages": 5
  ///   }
  /// }
  /// ```
  FinchRoute routeGetAll(String path,
      {List<String> methods = const [Methods.GET],
      Future<ApiDoc>? Function()? apiDoc,
      AuthController? auth,
      List<String> extraPath = const [],
      List<String> excludePaths = const [],
      List<String> hosts = const ['*'],
      Map<String, Object?> params = const {},
      List<String> permissions = const [],
      List<int> ports = const [],
      List<FinchRoute> children = const [],
      bool paging = true,
      int pageSize = 20,
      bool orderReverse = true,
      String orderBy = '_id'}) {
    Future<String> index() async {
      final rq = Context.rq;
      if (paging == false) {
        var all = await getAll(
          filter: getSearchableFilter(inputs: rq.getAll()),
        );

        return rq.renderData(data: {
          'success': true,
          'data': all,
        });
      } else {
        final countAll = await getCount(
          filter: getSearchableFilter(inputs: rq.getAll()),
        );
        pageSize = rq.get<int>('pageSize', def: pageSize);
        orderBy = rq.get<String>('orderBy', def: orderBy);
        orderReverse = rq.get<bool>('orderReverse', def: orderReverse);

        UIPaging paging = UIPaging(
          total: countAll,
          pageSize: pageSize,
          widget: '',
          page: rq.get<int>('page', def: 1),
          orderReverse: orderReverse,
          orderBy: orderBy,
        );

        final res = await getAll(
          filter: getSearchableFilter(inputs: rq.getAll()),
          limit: paging.pageSize,
          skip: paging.start,
          sort: DQ.order(orderBy, orderReverse),
        );

        return rq.renderData(data: {
          'success': true,
          'data': res,
          'paging': await paging.renderData(),
        });
      }
    }

    return FinchRoute(
      path: path,
      methods: methods,
      apiDoc: apiDoc,
      auth: auth,
      excludePaths: excludePaths,
      extraPath: extraPath,
      hosts: hosts,
      params: params,
      permissions: permissions,
      ports: ports,
      index: index,
      children: children,
    );
  }

  /// Creates a route for inserting new documents into the collection.
  /// This method generates a REST API endpoint that handles document creation
  /// with automatic form validation. The route processes POST requests containing
  /// document data, validates it against the form definition, and inserts it
  /// into the collection.
  /// Parameters:
  /// * [path] - URL path for this route
  /// * [methods] - HTTP methods to accept (default: POST)
  /// * [apiDoc] - Optional API documentation generator
  /// * [auth] - Optional authentication controller
  /// * [extraPath] - Additional path segments to match
  /// * [excludePaths] - Path segments to exclude from matching
  /// * [hosts] - Host names to match (default: all hosts)
  /// * [params] - Additional route parameters
  /// * [permissions] - Required permissions for access
  /// * [ports] - Specific ports to match
  /// Returns a [FinchRoute] configured for creating documents.
  /// Success response (201):
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "inserted",
  ///   "data": {"_id": "...", "name": "..."}
  /// }
  /// ```
  /// Error response (502):
  /// ```json
  /// {
  ///   "success": false,
  ///   "message": "error",
  ///   "form": {"field1": ["error message"]}
  /// }
  /// ```
  FinchRoute routeInsert(
    String path, {
    List<String> methods = const [Methods.POST],
    Future<ApiDoc>? Function()? apiDoc,
    AuthController<dynamic>? auth,
    List<String> extraPath = const [],
    List<String> excludePaths = const [],
    List<String> hosts = const ['*'],
    Map<String, Object?> params = const {},
    List<String> permissions = const [],
    List<int> ports = const [],
  }) {
    Future<String> index() async {
      final rq = Context.rq;
      var res = await insert(rq.getAll());

      if (!res.success) {
        return rq.renderData(
          data: {
            'form': res.toJson(),
            'success': false,
            'message': 'error',
          },
          status: 502,
        );
      }

      return rq.renderData(data: {
        'data': res.formValues(),
        'success': true,
        'message': 'inserted',
      });
    }

    return FinchRoute(
      path: path,
      methods: methods,
      apiDoc: apiDoc,
      auth: auth,
      excludePaths: excludePaths,
      extraPath: extraPath,
      hosts: hosts,
      params: params,
      permissions: permissions,
      ports: ports,
      index: index,
    );
  }

  /// Creates a route for updating existing documents in the collection.
  /// This method generates a REST API endpoint that handles document updates
  /// via complete replacement. The route expects a document ID in the URL path
  /// and processes POST requests containing the new document data.
  /// The update operation:
  /// - Validates the new data against the form definition
  /// - Replaces the entire document (not a partial update)
  /// - Triggers the onUpdate event if successful
  /// Parameters:
  /// * [path] - URL path for this route (should include {id} placeholder)
  /// * [methods] - HTTP methods to accept (default: POST)
  /// * [apiDoc] - Optional API documentation generator
  /// * [auth] - Optional authentication controller
  /// * [extraPath] - Additional path segments to match
  /// * [excludePaths] - Path segments to exclude from matching
  /// * [hosts] - Host names to match (default: all hosts)
  /// * [params] - Additional route parameters
  /// * [permissions] - Required permissions for access
  /// * [ports] - Specific ports to match
  /// Returns a [FinchRoute] configured for updating documents.
  /// Success response (200):
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "updated",
  ///   "data": {"_id": "...", "name": "..."}
  /// }
  /// ```
  /// Error responses:
  /// - 404: Document not found
  /// - 502: Validation errors or missing ID
  FinchRoute routeUpdate(
    String path, {
    List<String> methods = const [Methods.POST],
    Future<ApiDoc>? Function()? apiDoc,
    AuthController<dynamic>? auth,
    List<String> extraPath = const [],
    List<String> excludePaths = const [],
    List<String> hosts = const ['*'],
    Map<String, Object?> params = const {},
    List<String> permissions = const [],
    List<int> ports = const [],
  }) {
    Future<String> index() async {
      final rq = Context.rq;
      var id = rq.getParam('id', def: '').toString();

      if (id.isEmpty) {
        return rq.renderData(
          data: {
            'success': false,
            'message': 'id is required',
          },
          status: 502,
        );
      }

      var res = await replaceOne(id, rq.getAll());
      if (res == null) {
        return rq.renderData(
          data: {
            'success': false,
            'message': 'id not found',
          },
          status: 404,
        );
      }

      if (!res.success) {
        return rq.renderData(
          data: {
            'form': res.toJson(),
            'success': false,
            'message': 'error',
          },
          status: 502,
        );
      }

      return rq.renderData(data: {
        'data': res.formValues(),
        'success': true,
        'message': 'updated',
      });
    }

    return FinchRoute(
      path: path,
      methods: methods,
      apiDoc: apiDoc,
      auth: auth,
      excludePaths: excludePaths,
      extraPath: extraPath,
      hosts: hosts,
      params: params,
      permissions: permissions,
      ports: ports,
      index: index,
    );
  }

  /// Creates a route for deleting documents from the collection.
  /// This method generates a REST API endpoint that handles document deletion
  /// by ID. The route expects a document ID in the URL path and processes
  /// GET requests to delete the specified document.
  /// The delete operation:
  /// - Validates the document ID format
  /// - Checks if the document exists
  /// - Triggers the onDelete event if successful
  /// Parameters:
  /// * [path] - URL path for this route (should include {id} placeholder)
  /// * [methods] - HTTP methods to accept (default: GET)
  /// * [apiDoc] - Optional API documentation generator
  /// * [auth] - Optional authentication controller
  /// * [extraPath] - Additional path segments to match
  /// * [excludePaths] - Path segments to exclude from matching
  /// * [hosts] - Host names to match (default: all hosts)
  /// * [params] - Additional route parameters
  /// * [permissions] - Required permissions for access
  /// * [ports] - Specific ports to match
  /// Returns a [FinchRoute] configured for deleting documents.
  /// Success response (200):
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "deleted"
  /// }
  /// ```
  /// Error responses:
  /// - 404: Document not found
  /// - 502: Missing or invalid ID
  FinchRoute routeDeleteOne(
    String path, {
    List<String> methods = const [Methods.GET],
    Future<ApiDoc>? Function()? apiDoc,
    AuthController<dynamic>? auth,
    List<String> extraPath = const [],
    List<String> excludePaths = const [],
    List<String> hosts = const ['*'],
    Map<String, Object?> params = const {},
    List<String> permissions = const [],
    List<int> ports = const [],
  }) {
    Future<String> index() async {
      final rq = Context.rq;
      var id = rq.getParam('id', def: '').toString();

      if (id.isEmpty) {
        return rq.renderData(
          data: {
            'success': false,
            'message': 'id is required',
          },
          status: 502,
        );
      }

      var data = await delete(id);
      if (!data) {
        return rq.renderData(
          data: {
            'success': false,
            'message': 'id not found',
          },
          status: 404,
        );
      }

      return rq.renderData(data: {
        'success': true,
        'message': 'deleted',
      });
    }

    return FinchRoute(
      path: path,
      methods: methods,
      apiDoc: apiDoc,
      auth: auth,
      excludePaths: excludePaths,
      extraPath: extraPath,
      hosts: hosts,
      params: params,
      permissions: permissions,
      ports: ports,
      index: index,
    );
  }

  /// Creates a route for retrieving a single document by its ID.
  /// This method generates a REST API endpoint that handles fetching individual
  /// documents from the collection. The route expects a document ID in the URL
  /// path and processes GET requests to return the specified document.
  /// The retrieval operation:
  /// - Validates the document ID format
  /// - Fetches the document if it exists
  /// - Processes the document through form validation for consistent formatting
  /// Parameters:
  /// * [path] - URL path for this route (should include {id} placeholder)
  /// * [methods] - HTTP methods to accept (default: GET)
  /// * [apiDoc] - Optional API documentation generator
  /// * [auth] - Optional authentication controller
  /// * [extraPath] - Additional path segments to match
  /// * [excludePaths] - Path segments to exclude from matching
  /// * [hosts] - Host names to match (default: all hosts)
  /// * [params] - Additional route parameters
  /// * [permissions] - Required permissions for access
  /// * [ports] - Specific ports to match
  /// Returns a [FinchRoute] configured for retrieving individual documents.
  /// Success response (200):
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "ok",
  ///   "data": {"_id": "...", "name": "...", "email": "..."}
  /// }
  /// ```
  /// Error responses:
  /// - 404: Document not found
  /// - 502: Missing or invalid ID
  FinchRoute routeGetOne(
    String path, {
    List<String> methods = const [Methods.GET],
    Future<ApiDoc>? Function()? apiDoc,
    AuthController<dynamic>? auth,
    List<String> extraPath = const [],
    List<String> excludePaths = const [],
    List<String> hosts = const ['*'],
    Map<String, Object?> params = const {},
    List<String> permissions = const [],
    List<int> ports = const [],
  }) {
    Future<String> index() async {
      final rq = Context.rq;
      var id = rq.getParam('id', def: '').toString();

      if (id.isEmpty) {
        return rq.renderData(
          data: {
            'success': false,
            'message': 'id is required',
          },
          status: 502,
        );
      }

      var data = await getById(id);
      if (data == null) {
        return rq.renderData(
          data: {
            'success': false,
            'message': 'id not found',
          },
          status: 404,
        );
      }

      return rq.renderData(data: {
        'success': true,
        'data': data,
        'message': 'ok',
      });
    }

    return FinchRoute(
      path: path,
      methods: methods,
      apiDoc: apiDoc,
      auth: auth,
      excludePaths: excludePaths,
      extraPath: extraPath,
      hosts: hosts,
      params: params,
      permissions: permissions,
      ports: ports,
      index: index,
    );
  }
}

/// Event management system for database collection operations.
/// This class provides event handling capabilities for database operations,
/// allowing you to register listeners that are called when documents are
/// inserted, updated, or deleted from a collection.
/// Each event type supports both synchronous and asynchronous listeners,
/// making it flexible for various use cases such as:
/// - Logging database operations
/// - Triggering side effects (like sending notifications)
/// - Maintaining data consistency across related collections
/// - Caching updates
/// Example:
/// ```dart
/// collection.collectionEvent.onInsert.addListener((document) {
///   print('New document inserted: ${document['_id']}');
/// });
/// collection.collectionEvent.onUpdate.addAsyncListener((document) async {
///   await updateSearchIndex(document);
/// });
/// ```
class CollectionEvent {
  /// Event triggered when a document is inserted into the collection.
  /// Listeners receive the complete inserted document as a parameter,
  /// including the generated `_id` field.
  final Event<Map<String, Object?>> onInsert = Event<Map<String, Object?>>();

  /// Event triggered when a document is updated in the collection.
  /// Listeners receive the complete updated document as a parameter,
  /// with all current field values.
  final Event<Map<String, Object?>> onUpdate = Event<Map<String, Object?>>();

  /// Event triggered when a document is deleted from the collection.
  /// Listeners receive the document that was deleted as a parameter,
  /// allowing access to the data before it was removed.
  final Event<Map<String, Object?>> onDelete = Event<Map<String, Object?>>();
}

/// Type definition for synchronous event listener functions.
/// These functions are called immediately when an event is emitted
/// and should complete quickly to avoid blocking the event emission process.
typedef EventFunction<R> = void Function(R data);

/// Type definition for asynchronous event listener functions.
/// These functions can perform async operations and are awaited during
/// event emission, which means they can delay the completion of the
/// database operation that triggered the event.
typedef EventAsyncFunction<R> = Future<void> Function(R data);

/// Generic event system for handling typed events with multiple listeners.
/// This class provides a flexible event system that supports both synchronous
/// and asynchronous listeners. Events can be emitted with typed data, and all
/// registered listeners will be called in the order they were added.
/// Features:
/// - Type-safe event data
/// - Support for both sync and async listeners
/// - Sequential execution of listeners
/// - Return count of executed listeners
/// Example:
/// ```dart
/// var userCreated = Event<User>();
/// userCreated.addListener((user) {
///   print('User created: ${user.name}');
/// });
/// userCreated.addAsyncListener((user) async {
///   await sendWelcomeEmail(user);
/// });
/// await userCreated.emit(newUser);
/// ```
class Event<T> {
  /// List of synchronous listeners for the event.
  final List<EventFunction<T>> _listeners = [];

  /// List of asynchronous listeners for the event.
  final List<EventAsyncFunction<T>> _asyncListeners = [];

  /// Adds a synchronous listener to the event.
  /// Synchronous listeners are called immediately and should complete quickly.
  /// They are executed before any asynchronous listeners.
  /// Parameters:
  /// * [listener] - The function to call when the event is emitted
  /// Returns this [Event] instance for method chaining.
  /// Example:
  /// ```dart
  /// event.addListener((data) => print('Event: $data'))
  ///      .addListener((data) => updateCounter());
  /// ```
  Event addListener(EventFunction listener) {
    _listeners.add(listener);
    return this;
  }

  /// Adds an asynchronous listener to the event.
  /// Asynchronous listeners can perform async operations and are awaited
  /// during event emission. They are executed after all synchronous listeners
  /// have completed.
  /// Parameters:
  /// * [listener] - The async function to call when the event is emitted
  /// Returns this [Event] instance for method chaining.
  /// Example:
  /// ```dart
  /// event.addAsyncListener((data) async => await saveToDatabase(data))
  ///      .addAsyncListener((data) async => await sendNotification(data));
  /// ```
  Event addAsyncListener(EventAsyncFunction listener) {
    _asyncListeners.add(listener);
    return this;
  }

  /// Emits the event, calling all registered listeners.
  /// This method executes all synchronous listeners first, then all
  /// asynchronous listeners. Asynchronous listeners are awaited, so this
  /// method will not complete until all listeners have finished executing.
  /// Parameters:
  /// * [data] - The data to pass to all listeners
  /// Returns the total number of listeners that were executed.
  /// Example:
  /// ```dart
  /// int listenerCount = await event.emit(userData);
  /// print('$listenerCount listeners were notified');
  /// ```
  Future<int> emit([dynamic data]) async {
    var i = 0;

    for (var listener in _listeners) {
      listener(data);
      i++;
    }

    for (var asyncListener in _asyncListeners) {
      await asyncListener(data);
      i++;
    }

    return i;
  }
}

/// Utility class for parsing and processing MongoDB error responses.
/// This class provides static methods to analyze MongoDB operation errors
/// and convert them into a more accessible format. It's particularly useful
/// for handling write errors that occur during insert, update, or delete
/// operations.
/// The class can extract field-specific errors from MongoDB's error response
/// format, making it easier to provide meaningful error messages to users
/// and identify which fields caused validation or constraint violations.
/// Example:
/// ```dart
/// // After a failed MongoDB operation
/// var errors = MongoErrorResponse.discoverError(result.serverResponses);
/// if (errors.containsKey('email')) {
///   print('Email errors: ${errors['email']}');
/// }
/// ```
class MongoErrorResponse {
  /// Analyzes MongoDB error responses and extracts field-specific errors.
  /// This method processes MongoDB write error responses and groups them by
  /// the fields that caused the errors. It's particularly useful for handling
  /// constraint violations, duplicate key errors, and validation failures.
  /// The method looks for:
  /// - Write errors in the response
  /// - Error codes and their corresponding messages
  /// - Key patterns to identify affected fields
  /// Parameters:
  /// * [response] - List of MongoDB server response objects
  /// Returns a map where keys are field names and values are lists of
  /// error messages for those fields.
  /// Example:
  /// ```dart
  /// var errors = MongoErrorResponse.discoverError(responses);
  /// // Result: {'email': ['duplicate key error'], 'name': ['required field']}
  /// ```
  static Map<String, List<String>> discoverError(
    List<Map<String, Object?>> response,
  ) {
    Map<String, List<String>> res = {};

    for (final resp in response) {
      if (resp.containsKey('writeErrors') && resp['writeErrors'] is List) {
        final writeErrors = resp['writeErrors'] as List;
        for (final writeError in writeErrors) {
          String error = mongoDBErrorCodes[writeError['code']]?[#name] ??
              'mongo.error.unknown';
          final Map<String, Object?> keyPattern =
              (writeError['keyPattern'] != null &&
                      writeError['keyPattern'] is Map)
                  ? writeError['keyPattern']
                  : {};
          List<String> fields = keyPattern.keys.toList();
          for (var field in fields) {
            if (!res.containsKey(field)) {
              res[field] = [];
            }
            res[field]!.add(error);
          }
        }
      }
    }

    return res;
  }
}

/// Configuration class for MongoDB database indexes.
/// This class encapsulates all the configuration options needed to create
/// a MongoDB index. It provides a convenient way to define index properties
/// that will be used when creating indexes on collection fields.
/// MongoDB indexes improve query performance and can enforce constraints
/// like uniqueness. This class supports all major index options including:
/// - Single field and compound indexes
/// - Unique constraints
/// - Sparse indexes (ignore null values)
/// - Partial indexes with filter expressions
/// - Background index creation
/// - Custom collation for text sorting
/// Example:
/// ```dart
/// var emailIndex = DBIndex(
///   key: 'email',
///   unique: true,
///   sparse: true,
/// );
/// var compoundIndex = DBIndex(
///   keys: {'category': 1, 'createdAt': -1},
///   name: 'category_date_idx',
/// );
/// ```
class DBIndex {
  /// Single field name to index (alternative to [keys]).
  /// Use this for simple single-field indexes. Cannot be used together
  /// with the [keys] parameter.
  String? key;

  /// Map defining compound index fields and their sort order.
  /// Keys are field names, values are:
  /// - 1 for ascending order
  /// - -1 for descending order
  /// Example: `{'name': 1, 'age': -1}` creates an index on name (ascending)
  /// and age (descending).
  Map<String, dynamic>? keys;

  /// Whether the index should enforce uniqueness constraint.
  /// When true, MongoDB will reject documents that would create duplicate
  /// values for the indexed field(s).
  bool? unique;

  /// Whether to create a sparse index.
  /// Sparse indexes only contain entries for documents that have the indexed
  /// field, ignoring documents where the field is null or missing.
  bool? sparse;

  /// Whether to build the index in the background.
  /// Background index builds don't block database operations but may take
  /// longer to complete.
  bool? background;

  /// Whether to drop duplicate documents during index creation.
  /// This option is deprecated in newer MongoDB versions.
  bool? dropDups;

  /// Filter expression for partial indexes.
  /// Partial indexes only index documents that meet the specified filter
  /// criteria, reducing index size and improving performance.
  Map<String, dynamic>? partialFilterExpression;

  /// Custom name for the index.
  /// If not provided, MongoDB generates a name based on the field names
  /// and sort order.
  String? name;

  /// Whether to use modern reply format for index creation.
  /// This affects the response format from the index creation operation.
  bool? modernReply;

  /// Collation specification for the index.
  /// Collation allows you to specify language-specific rules for string
  /// comparison, such as case sensitivity and accent sensitivity.
  Map<dynamic, dynamic>? collation;

  /// Creates a new database index configuration.
  /// Parameters:
  /// * [key] - Single field to index (cannot be used with [keys])
  /// * [keys] - Compound index field specification (cannot be used with [key])
  /// * [unique] - Enforce uniqueness constraint
  /// * [sparse] - Create sparse index
  /// * [background] - Build index in background
  /// * [dropDups] - Drop duplicate documents (deprecated)
  /// * [partialFilterExpression] - Filter for partial index
  /// * [name] - Custom index name
  /// * [modernReply] - Use modern reply format
  /// * [collation] - Collation specification
  DBIndex({
    this.key,
    this.keys,
    this.unique,
    this.sparse,
    this.background,
    this.dropDups,
    this.partialFilterExpression,
    this.name,
    this.modernReply,
    this.collation,
  });
}
