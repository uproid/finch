import 'package:finch/finch_tools.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// A utility class for building MongoDB queries.
/// The [DQ] class provides a set of static methods to construct MongoDB-compatible queries
/// in a more readable and structured way. It allows for easy creation of complex queries
/// with operations such as equality checks, logical operations (`\$or`, `\$and`), pattern matching,
/// and aggregation commands like grouping and sorting.
/// Example Usage:
/// ```dart
/// var query = DQ.and([
///   DQ.field('name', DQ.like('John')),
///   DQ.field('age', DQ.eq(25)),
/// ]);
/// var result = await collection.find(query).toList();
/// ```
class DQ {
  /// Returns a value for equality comparison.
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.eq('value'); // { 'field': 'value' }
  /// ```
  static Object? eq(Object? value) {
    return value;
  }

  /// Constructs a logical OR query.
  ///
  /// Takes a list of conditions and joins them using the `\$or` operator.
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.or([DQ.eq('value1'), DQ.eq('value2')]); // { '\$or': [ 'value1', 'value2' ] }
  /// ```
  static Map<String, Object?> or(List<Object?> list) {
    return {
      '\$or': list,
    };
  }

  /// Matches a document based on its ObjectId.
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.oid(ObjectId.parse('507f191e810c19729de860ea')); // { '_id': ObjectId(...) }
  /// ```
  static Map<String, Object?> oid(ObjectId id) {
    return {
      '_id': id,
    };
  }

  /// Matches a document based on a string ID.
  ///
  /// Converts the string to an ObjectId using the `oID` extension.
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.id('507f191e810c19729de860ea'); // { '_id': ObjectId(...) }
  /// ```
  static Map<String, Object?> id(String id) {
    return {
      '_id': id.oID,
    };
  }

  /// Constructs a logical AND query.
  ///
  /// Takes a list of conditions and joins them using the `\$and` operator.
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.and([DQ.eq('value1'), DQ.eq('value2')]); // { '\$and': [ 'value1', 'value2' ] }
  /// ```
  static Map<String, Object?> and(List<Object?> list) {
    return {
      '\$and': list,
    };
  }

  /// Matches documents where the field's value is in the provided list.
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.hasIn(['value1', 'value2']); // { '\$in': [ 'value1', 'value2' ] }
  /// ```
  static Map<String, Object?> hasIn(Object? value) {
    return {
      '\$in': value,
    };
  }

  /// Matches documents where the field's value is not in the provided list.
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.hasNin(['value1', 'value2']); // { '\$nin': [ 'value1', 'value2' ] }
  /// ```
  static Map<String, Object?> hasNin(Object? value) {
    return {
      '\$nin': value,
    };
  }

  /// Matches documents where the field's value matches a regular expression.
  ///
  /// The [options] parameter can be used to set regex options (e.g., `'i'` for case-insensitive).
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.like('pattern', options: 'i'); // { '\$regex': 'pattern', '\$options': 'i' }
  /// ```
  static Map<String, Object?> like(String value, {String options = 'i'}) {
    value = _escapeRegex(value);

    return {
      '\$regex': value,
      '\$options': options,
    };
  }

  /// Matches documents where the field's value is case-insensitive.
  ///
  /// This is a specialized version of the `like` method that uses a regex pattern to match the entire string.

  /// Example:
  /// ```dart
  /// var query = DQ.uncase('pattern'); // { '\$regex': '^pattern\$', '\$options': 'i' }
  /// ```
  /// This method is useful for case-insensitive exact matches.
  static Map<String, Object?> uncase(String value) {
    value = _escapeRegex(value);

    return {
      '\$regex': '^$value\$',
      '\$options': 'i',
    };
  }

  // Escape all special regex characters
  static String _escapeRegex(String input) {
    return input.replaceAllMapped(
      RegExp(r'[.*+?^${}()|[\]\\]'),
      (match) {
        return match.group(0) != null ? "\\${match.group(0)}" : '';
      },
    );
  }

  /// Constructs a query for a specific field.
  ///
  /// The [query] parameter defines the condition for the field.
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.field('name', DQ.like('John')); // { 'name': { '\$regex': 'John', '\$options': 'i' } }
  /// ```
  static Map<String, Object?> field(String name, Object? query) {
    return {
      name: query,
    };
  }

  /// Constructs a MongoDB aggregation group stage.
  ///
  /// The [query] parameter should define the grouping operation.
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.group({
  ///   '_id': '\$field',
  ///   'total': DQ.sum('field')
  /// }); // { '\$group': { '_id': '\$field', 'total': { '\$sum': '\$field' } } }
  /// ```
  static Map<String, Object> group(Map<String, Object?> query) {
    return {'\$group': query};
  }

  /// Constructs an order/sorting query for MongoDB.
  ///
  /// The [orderBy] parameter specifies the field to order by.
  /// The [orderReverse] parameter controls the sorting direction: descending (`-1`) if `true` (default), ascending (`1`) if `false`.
  ///
  /// Returns `null` if [orderBy] is `null` or invalid (e.g., an email).
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.order('field', true); // { 'field': -1 }
  /// ```
  static Map<String, Object>? order(
    String? orderBy, [
    bool orderReverse = true,
  ]) {
    if (orderBy == null || orderBy.isEmail) {
      return null;
    }
    return {orderBy: orderReverse ? -1 : 1};
  }

  /// Constructs a sum aggregation operation.
  ///
  /// The [field] parameter specifies the field to sum.
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.sum('field'); // { '\$sum': '\$field' }
  /// ```
  static Map<String, Object?> sum(String field) {
    return {'\$sum': '\$$field'};
  }

  /// Constructs a MongoDB $lookup aggregation stage for joining collections.
  ///
  /// The $lookup stage performs a left outer join to an unsharded collection in
  /// the same database to filter in documents from the "joined" collection.
  ///
  /// [from] The target collection to join with
  /// [localField] The field from the input documents
  /// [foreignField] The field from the documents of the "from" collection (defaults to '_id')
  /// [as] The name of the output array field (defaults to '${from}_info')
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.lookup(
  ///   from: 'users',
  ///   localField: 'user_id',
  ///   foreignField: '_id',
  ///   as: 'user_data'
  /// );
  /// // { '$lookup': { 'from': 'users', 'localField': 'user_id', 'foreignField': '_id', 'as': 'user_data' } }
  /// ```
  static Map<String, Object> lookup({
    required String from,
    required String localField,
    String foreignField = '_id',
    String? as,
  }) {
    as ??= '${from}_info';

    return {
      '\$lookup': {
        'from': from,
        'localField': localField,
        'foreignField': foreignField,
        'as': as,
      }
    };
  }

  /// Constructs a MongoDB $unwind aggregation stage for deconstructing array fields.
  ///
  /// The $unwind stage deconstructs an array field from the input documents to output
  /// a document for each element. Each output document is the input document with the
  /// value of the array field replaced by the element.
  ///
  /// [path] The field path to an array field (will be prefixed with $)
  /// [as] Optional name for the index field (when preserving empty arrays)
  /// [preserveNullAndEmptyArrays] If true, includes documents with null, missing, or empty arrays
  ///
  /// Example:
  /// ```dart
  /// // Simple unwind
  /// var query = DQ.unwind(path: 'items');
  /// // { '$unwind': '$items' }
  ///
  /// // Unwind with preserve null arrays
  /// var query = DQ.unwind(path: 'tags', preserveNullAndEmptyArrays: true);
  /// // { '$unwind': { 'path': '$tags', 'preserveNullAndEmptyArrays': true } }
  /// ```
  static Map<String, Object> unwind({
    required String path,
    String? as,
    bool? preserveNullAndEmptyArrays,
  }) {
    if (as == null && preserveNullAndEmptyArrays == null) {
      return {'\$unwind': "\$$path"};
    }

    return {
      '\$unwind': {
        'path': "\$$path",
        if (preserveNullAndEmptyArrays != null)
          'preserveNullAndEmptyArrays': preserveNullAndEmptyArrays,
        if (as != null) 'as': as
      }
    };
  }

  /// Constructs a MongoDB $match aggregation stage for filtering documents.
  ///
  /// The $match stage filters the documents to pass only the documents that
  /// match the specified condition(s) to the next pipeline stage.
  ///
  /// [matches] A list of match conditions to combine
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.match([
  ///   DQ.field('status', 'active'),
  ///   DQ.field('age', DQ.gte(18))
  /// ]);
  /// // { '$match': { 'status': 'active', 'age': { '$gte': 18 } } }
  /// ```
  static Map<String, Object> match(List<Map<String, Object?>> matches) {
    return {
      '\$match': {for (var match in matches) ...match}
    };
  }

  /// Constructs a greater than ($gt) comparison operator.
  ///
  /// Matches values that are greater than the specified value.
  ///
  /// [value] The value to compare against
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.field('age', DQ.gt(18)); // { 'age': { '$gt': 18 } }
  /// ```
  static Map<String, Object?> gt(Object? value) {
    return {
      '\$gt': value,
    };
  }

  /// Constructs a greater than or equal ($gte) comparison operator.
  ///
  /// Matches values that are greater than or equal to the specified value.
  ///
  /// [value] The value to compare against
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.field('age', DQ.gte(18)); // { 'age': { '$gte': 18 } }
  /// ```
  static Map<String, Object?> gte(Object? value) {
    return {
      '\$gte': value,
    };
  }

  /// Constructs a less than ($lt) comparison operator.
  ///
  /// Matches values that are less than the specified value.
  ///
  /// [value] The value to compare against
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.field('age', DQ.lt(65)); // { 'age': { '$lt': 65 } }
  /// ```
  static Map<String, Object?> lt(Object? value) {
    return {
      '\$lt': value,
    };
  }

  /// Constructs a less than or equal ($lte) comparison operator.
  ///
  /// Matches values that are less than or equal to the specified value.
  ///
  /// [value] The value to compare against
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.field('age', DQ.lte(65)); // { 'age': { '$lte': 65 } }
  /// ```
  static Map<String, Object?> lte(Object? value) {
    return {
      '\$lte': value,
    };
  }

  /// Creates an aggregation pipeline array.
  ///
  /// This is a utility method for creating MongoDB aggregation pipelines.
  /// It simply returns a copy of the provided query stages.
  ///
  /// [query] List of aggregation stages
  ///
  /// Example:
  /// ```dart
  /// var pipeline = DQ.pipeline([
  ///   DQ.match([DQ.field('status', 'active')]),
  ///   DQ.group({'_id': null, 'count': DQ.sum('1')})
  /// ]);
  /// ```
  static List<Map<String, Object>> pipeline(
    List<Map<String, Object>> query,
  ) {
    return [...query];
  }

  /// Constructs a MongoDB $project aggregation stage.
  ///
  /// The $project stage passes along the documents with the requested fields
  /// to the next stage in the pipeline. The specified fields can be existing
  /// fields from the input documents or newly computed fields.
  ///
  /// [fields] Map of field specifications where values can be:
  /// - 1 or true: Include the field
  /// - 0 or false: Exclude the field
  /// - Expression: Computed field value
  ///
  /// Example:
  /// ```dart
  /// var query = DQ.project({
  ///   'name': 1,
  ///   'age': 1,
  ///   '_id': 0,
  ///   'fullName': {'\$concat': ['\$firstName', ' ', '\$lastName']}
  /// });
  /// ```
  static Map<String, Object> project(Map<String, Object> fields) {
    return {
      '\$project': {
        ...fields,
      }
    };
  }

  static Map<String, Object> sort(Map<String, int> fields) {
    return {
      '\$sort': {
        ...fields,
      }
    };
  }

  static Map<String, Object> sortList(List<Map<String, int>> fields) {
    return {
      '\$sort': {
        for (var field in fields) ...field,
      }
    };
  }

  static Map<String, Object> sortOne(String field, [bool desc = true]) {
    return sortList([
      sortField(field, desc),
    ]);
  }

  static Map<String, int> sortField(String field, [bool desc = true]) {
    return {
      field: desc ? -1 : 1,
    };
  }

  static Map<String, Object> limit(int limit) {
    return {
      '\$limit': limit,
    };
  }

  static Map<String, Object> skip(int skip) {
    if (skip < 0) {
      skip = 0;
    }
    return {
      '\$skip': skip,
    };
  }

  static Map<String, Object> count(String field) {
    return {
      '\$count': field,
    };
  }

  static Map<String, Object> dateToString({
    required Object field,
    String format = '%Y-%m-%d %H:%M:%S',
    Object? onNull,
    Object? onError,
    String? timezone,
  }) {
    return {
      '\$dateToString': {
        'format': format,
        'date': field,
        if (timezone != null) 'timezone': timezone,
        if (onNull != null) 'onNull': onNull,
        if (onError != null) 'onError': onError,
      }
    };
  }

  static Map<String, Object> toDate(
    String field,
  ) {
    return {'\$toDate': "\$$field"};
  }

  static Map<String, Object> sumQuery(
    Object query,
  ) {
    return {
      '\$sum': query,
    };
  }

  static Map<String, Object> cond({
    required Object ifCond,
    required Object thenCond,
    required Object elseCond,
  }) {
    return {
      '\$cond': {
        'if': ifCond,
        'then': thenCond,
        'else': elseCond,
      }
    };
  }

  /// Creates a field reference for use in MongoDB aggregation expressions.
  ///
  /// This method prefixes a field name with '$' to create a field path expression
  /// that can be used in aggregation pipelines to reference document fields.
  ///
  /// [field] The name of the field to reference
  ///
  /// Example:
  /// ```dart
  /// var fieldRef = DQ.$field('name'); // Returns: '$name'
  ///
  /// // Usage in aggregation:
  /// var projection = DQ.project({
  ///   'upperName': {'\$toUpper': DQ.$field('name')}
  /// });
  /// ```
  static String $field(String field) {
    return "\$$field";
  }
}
