import 'package:finch/src/tools/model_less/format_helper.dart';
import 'package:finch/finch_mysql.dart';
import 'package:sqlite3/sqlite3.dart';

class SqliteResult
    implements SqlDatabaseResult<Database, ResultSet, List<Object?>> {
  /// Field name used for record count queries.
  @override
  Database database;

  /// The underlying SQLite result set from the database driver.
  @override
  final ResultSet resultSet;

  /// Error message if the query failed, empty string if successful.
  @override
  String errorMsg;

  /// Creates a new SqliteResult instance.
  /// Parameters:
  /// * [resultSet] - The SQLite result set from the database operation
  /// * [errorMsg] - Optional error message, defaults to empty string
  SqliteResult(this.database, this.resultSet, {this.errorMsg = ''});

  /// Returns `true` if the query executed successfully (no error message).
  @override
  bool get success => errorMsg.isEmpty;

  /// Returns `true` if the query failed (has an error message).
  @override
  bool get error => !success;

  /// Returns an iterable of result set rows.
  /// Use this for direct access to the SQLite client's row objects.
  @override
  List<List<Object?>> get rows => resultSet.rows;

  /// Returns the number of rows affected by the last INSERT, UPDATE, or DELETE.
  /// This is useful for determining how many records were modified by
  /// data manipulation operations.
  @override
  int get affectedRows => database.updatedRows;

  /// Returns the auto-generated ID from the last INSERT operation.
  /// This is particularly useful when inserting records into tables
  /// with auto-increment primary keys.
  @override
  int get insertId => database.lastInsertRowId;

  /// Returns the number of columns in the result set.
  @override
  int get numFields => resultSet.columnNames.length;

  /// Returns the number of rows in the result set.
  @override
  int get numRows => resultSet.rows.length;

  /// Returns all rows as a list of associative arrays.
  /// This is the most common way to access query results, providing
  /// column names as map keys for easy data access.
  /// Example:
  /// ```dart
  /// var rows = result.assoc;
  /// for (var row in rows) {
  ///   print('Name: ${row['name']}, Email: ${row['email']}');
  /// }
  /// ```
  @override
  List<Map<String, String?>> get assoc {
    var list = <Map<String, String?>>[];

    for (var row in rows) {
      var map = <String, String?>{};
      for (var i = 0; i < numFields; i++) {
        map[resultSet.columnNames[i]] = row[i]?.toString();
      }
      list.add(map);
    }

    return list;
  }

  /// Returns the first row as an associative array, or null if no rows exist.
  /// This is convenient for queries that are expected to return a single
  /// row, such as SELECT queries with LIMIT 1 or aggregate functions.
  /// Example:
  /// ```dart
  /// var firstRow = result.assocFirst;
  /// if (firstRow != null) {
  ///   print('User found: ${firstRow['name']}');
  /// } else {
  ///   print('No user found');
  /// }
  /// ```
  @override
  Map<String, String?>? get assocFirst {
    if (rows.isEmpty) {
      return null;
    }
    var row = <String, String?>{};
    for (var i = 0; i < numFields; i++) {
      row[resultSet.columnNames[i]] = rows.first[i]?.toString();
    }
    return row;
  }

  /// Returns the count of records from results with the field `count_records`.
  /// This method is specifically designed to work with COUNT queries where
  /// the result includes a field named 'count_records'. It extracts and
  /// converts this value to an integer.
  /// Returns 0 if the field doesn't exist, can't be parsed, or if there
  /// are no results.
  /// Example:
  /// ```dart
  /// // Query: SELECT COUNT(*) as count_records FROM users
  /// var result = await table.select(conn, countQuery);
  /// int totalUsers = result.countRecords;
  /// print('Total users: $totalUsers');
  /// ```
  @override
  int get countRecords {
    var count = assocFirst?[SqlDatabaseResult.countRecordsField] ?? '0';
    return count.asInt(def: 0);
  }

  @override
  Future<List<Map<String, Object?>>> assocBy(DataAssoc dataAssoc) async {
    var list = <Map<String, Object?>>[];

    for (var row in assoc) {
      list.add(await dataAssoc.toAssoc(row));
    }

    return list;
  }
}

/// Abstract base class for SQLite table operations.
abstract class SqliteTable {
  DatabaseDriver<Database> get db;

  String get tableName;

  QField get qName => QField(tableName);

  MTable get table => MTable(
        name: tableName,
        fields: [],
      );

  Future<SqlDatabaseResult> deleteBy(Where where) async {
    var query = Sqler()
      ..from(qName)
      ..delete()
      ..where(where);
    return table.execute(db, query);
  }

  Future<SqlDatabaseResult> deleteById(int id) async {
    return deleteBy(WhereOne(QField('id'), QO.EQ, QVar(id)));
  }

  Future<SqlDatabaseResult> findById(int id) async {
    var query = Sqler()
      ..from(qName)
      ..selects([
        ...table.allSelectFields(),
      ])
      ..where(WhereOne(QField('id'), QO.EQ, QVar(id)));
    var res = await table.execute(db, query);
    return res;
  }

  Future<int> countBy(Where where) async {
    var query = Sqler()
      ..from(qName)
      ..addSelect(SQL.count(QField('id', as: 'count_records')))
      ..where(where);
    var result = await table.execute(db, query);
    return result.countRecords;
  }

  /// All abstract methods
  Future<({int count, SqlDatabaseResult rows})> findAll({
    String orderBy = 'id',
    bool orderReverse = true,
    Map<String, dynamic> filters = const {},
    int? pageSize,
    int? offset,
  });

  Sqler updateFilters(Sqler query, Map<String, dynamic> filter);
}
