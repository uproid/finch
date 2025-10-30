import 'package:mysql_client/mysql_client.dart';
import 'package:finch/src/forms/form_validator.dart';
import 'package:finch/finch_mysql.dart';

/// Extension for [MTable] that provides MySQL-specific database operations.
/// This extension adds functionality for table management, data manipulation,
/// and form validation specifically for MySQL databases. It includes methods
/// for creating, dropping, and querying tables, as well as handling foreign
/// key constraints and form validation.
extension MySqlTable on MTable {
  /// Gets table fields as select fields with optional table prefixes and aliases.
  /// This method transforms table fields into [QSelectField] objects suitable
  /// for SQL SELECT queries. It handles table prefixes and field aliases.
  /// Parameters:
  /// * [from] - The table prefix to use (e.g., 't1', 'users'). If empty,
  ///   no prefix is added.
  /// * [as] - The alias prefix for the selected fields. If empty,
  ///   original field names are used.
  /// Returns a list of [QSelectField] objects configured with the specified
  /// prefixes and aliases.
  /// Example:
  /// ```dart
  /// var fields = table.getFieldsAs('users', 'u');
  /// // Generates: users.name AS u.name, users.email AS u.email
  /// ```
  List<QSelectField> getFieldsAs(String from, String as) {
    return fields.map((field) {
      return QSelectCustom(
          QMath(from.isEmpty ? field.name : "$from.${field.name}"),
          as: as.isEmpty ? field.name : '$as.${field.name}');
    }).toList();
  }

  /// Executes a SQL query against the MySQL database connection.
  /// This is a low-level method that executes raw SQL queries. It handles
  /// exceptions and wraps results in a [MySqlResult] object for consistent
  /// error handling across the application.
  /// Parameters:
  /// * [conn] - The active MySQL database connection
  /// * [sql] - The SQL query string to execute
  /// Returns a [MySqlResult] containing either the query results or error
  /// information if the query failed.
  /// Example:
  /// ```dart
  /// var result = await table.execute(conn, 'SELECT * FROM users');
  /// if (result.success) {
  ///   print('Query executed successfully');
  /// }
  /// ```
  Future<SqlDatabaseResult> execute(
    DatabaseDriver conn,
    Sqler sqler,
  ) async {
    return conn.execute(sqler);
  }

  /// Checks if the table exists in the MySQL database.
  /// This method queries the MySQL information schema to determine if a table
  /// with the current name exists in the database.
  /// Parameters:
  /// * [conn] - The active MySQL database connection
  /// Returns `true` if the table exists, `false` otherwise.
  /// Example:
  /// ```dart
  /// if (await table.existsTable(conn)) {
  ///   print('Table already exists');
  /// } else {
  ///   await table.createTable(conn);
  /// }
  /// ```
  Future<bool> existsTable(DatabaseDriver conn) async {
    return conn.existTable(name);
  }

  /// Creates the table in the MySQL database.
  /// Generates and executes a CREATE TABLE SQL statement based on the table
  /// definition. The SQL is generated using the table's `toSQL()` method.
  /// Parameters:
  /// * [conn] - The active MySQL database connection
  /// Returns a [MySqlResult] indicating the success or failure of the
  /// table creation operation.
  /// Example:
  /// ```dart
  /// var result = await table.createTable(conn);
  /// if (result.success) {
  ///   print('Table created successfully');
  /// }
  /// ```
  Future<SqlDatabaseResult> createTable(DatabaseDriver conn) async {
    return conn.createTable(this);
  }

  /// Drops the table from the MySQL database.
  /// Executes a DROP TABLE IF EXISTS statement to safely remove the table
  /// from the database. The IF EXISTS clause prevents errors if the table
  /// doesn't exist.
  /// Parameters:
  /// * [conn] - The active MySQL database connection
  /// Returns a [MySqlResult] indicating the success or failure of the
  /// drop operation.
  /// Example:
  /// ```dart
  /// var result = await table.dropTable(conn);
  /// if (result.success) {
  ///   print('Table dropped successfully');
  /// }
  /// ```
  Future<SqlDatabaseResult> dropTable(DatabaseDriver conn) async {
    String sql = 'DROP TABLE IF EXISTS `$name`;';
    return conn.executeString(sql);
  }

  /// Creates foreign key constraints for the table.
  /// Generates and executes ALTER TABLE statements to add foreign key
  /// constraints defined in the table's foreign keys collection. Each
  /// constraint is given a unique name using the current timestamp.
  /// Parameters:
  /// * [conn] - The active MySQL database connection
  /// Returns a [MySqlResult] if foreign keys exist and are created,
  /// or `null` if no foreign keys are defined.
  /// Example:
  /// ```dart
  /// var result = await table.createForeignKeys(conn);
  /// if (result?.success == true) {
  ///   print('Foreign keys created successfully');
  /// }
  /// ```
  Future<SqlDatabaseResult?> createForeignKeys(DatabaseDriver conn) async {
    if (foreignKeys.isEmpty) {
      return null;
    }
    String sql = 'ALTER TABLE `$name`\n';
    for (var i = 1; i <= foreignKeys.length; i++) {
      var fk = foreignKeys[i - 1];
      sql +=
          'ADD CONSTRAINT fk_${name}_${fk.name}_${DateTime.now().microsecondsSinceEpoch} ${fk.toSQL()}${i == foreignKeys.length ? ';\n' : ',\n'}';
    }
    return conn.executeString(sql);
  }

  /// Inserts multiple records into the table.
  /// Executes a bulk INSERT statement to add multiple rows to the table
  /// in a single database operation, which is more efficient than individual
  /// inserts.
  /// Parameters:
  /// * [conn] - The active MySQL database connection
  /// * [data] - A list of maps where each map represents a row to insert.
  ///   Keys should match field names, values should be [QVar] objects.
  /// Returns a [MySqlResult] containing information about the insert
  /// operation, including the number of affected rows.
  /// Example:
  /// ```dart
  /// var result = await table.insertMany(conn, [
  ///   {'name': QVar('John'), 'email': QVar('john@example.com')},
  ///   {'name': QVar('Jane'), 'email': QVar('jane@example.com')},
  /// ]);
  /// ```
  Future<SqlDatabaseResult> insertMany(
    DatabaseDriver conn,
    List<Map<String, QVar>> data,
  ) async {
    String sql = Sqler().insert(QField(name), data).toSQL();
    return conn.executeString(sql);
  }

  /// Inserts a single record into the table.
  /// Convenience method that wraps [insertMany] for single record insertion.
  /// This is useful when you only need to insert one row.
  /// Parameters:
  /// * [conn] - The active MySQL database connection
  /// * [data] - A map representing the row to insert. Keys should match
  ///   field names, values should be [QVar] objects.
  /// Returns a [MySqlResult] containing information about the insert
  /// operation, including the generated ID if applicable.
  /// Example:
  /// ```dart
  /// var result = await table.insert(conn, {
  ///   'name': QVar('John Doe'),
  ///   'email': QVar('john@example.com'),
  /// });
  /// ```
  Future<SqlDatabaseResult> insert(
    DatabaseDriver conn,
    Map<String, QVar> data,
  ) async {
    return insertMany(conn, [data]);
  }

  /// Executes a SELECT query on the table.
  /// Executes the provided query to retrieve data from the table. The query
  /// should be constructed using the Sqler query builder.
  /// Parameters:
  /// * [conn] - The active MySQL database connection
  /// * [query] - A [Sqler] object representing the SELECT query to execute
  /// Returns a [MySqlResult] containing the query results and metadata.
  /// Example:
  /// ```dart
  /// var query = Sqler()
  ///   ..from(QField('users'))
  ///   ..selects([QSelect('*')])
  ///   ..where(WhereOne(QField('active'), QO.EQ, QVar(true)));
  /// var result = await table.select(conn, query);
  /// ```
  Future<SqlDatabaseResult> select(DatabaseDriver conn, Sqler query) async {
    return conn.execute(query);
  }

  /// Executes a DELETE query on the table.
  /// Executes the provided query to delete records from the table. The method
  /// includes a safety check to ensure the query contains a DELETE statement.
  /// Parameters:
  /// * [conn] - The active MySQL database connection
  /// * [query] - A [Sqler] object representing the DELETE query to execute
  /// Returns a [MySqlResult] containing information about the delete
  /// operation, including the number of affected rows.
  /// Throws an [Exception] if the query doesn't contain a DELETE statement.
  /// Example:
  /// ```dart
  /// var query = Sqler()
  ///   ..delete(QField('users'))
  ///   ..where(WhereOne(QField('active'), QO.EQ, QVar(false)));
  /// var result = await table.delete(conn, query);
  /// ```
  Future<SqlDatabaseResult> delete(DatabaseDriver conn, Sqler query) async {
    String sql = query.toSQL();

    if (!sql.contains('DELETE')) {
      throw Exception(
          'Use delete method instead of select for deleting records.');
    }

    return execute(conn, query);
  }

  /// Validates form data against the table's field definitions.
  /// This method performs comprehensive validation of input data based on
  /// the validators defined for each table field. It creates a form
  /// validator instance and processes all field validations.
  /// Parameters:
  /// * [data] - A map of field names to values that need to be validated
  /// Returns a [FormResult] containing both the validation results and
  /// the processed form data.
  /// Example:
  /// ```dart
  /// var formResult = await table.formValidateUI({
  ///   'name': 'John Doe',
  ///   'email': 'john@example.com',
  ///   'age': '25',
  /// });
  /// if (formResult.result.success) {
  ///   // Process valid form data
  ///   print('Form is valid');
  /// } else {
  ///   // Handle validation errors
  ///   print('Validation errors: ${formResult.result.errors}');
  /// }
  /// ```
  Future<FormResult> formValidateUI(
    Map<String, Object?> data,
  ) async {
    Map<String, List<Future<FieldValidateResult> Function(dynamic)>> fields =
        {};

    var extraData = <String, Object?>{};
    for (final field in this.fields) {
      fields[field.name] = field.validators.map((validator) {
        return (value) async {
          var result = await validator(value);
          return FieldValidateResult(
            error: result,
            success: result.isEmpty,
          );
        };
      }).toList();
      extraData[field.name] = data[field.name];
    }

    FormValidator formValidator = FormValidator(
      fields: fields,
      name: '${name}_form',
      extraData: extraData,
    );

    var res = await formValidator.validateAndForm();

    return FormResult(
      form: res.form,
      result: res.result,
    );
  }
}

/// Wrapper class for MySQL query results with convenient access methods.
/// This class encapsulates MySQL query results and provides a consistent
/// interface for accessing result data, metadata, and handling errors.
/// It wraps the native MySQL client's [IResultSet] with additional
/// convenience methods and error handling.
/// The class provides both low-level access to result set data and
/// high-level convenience methods for common operations like getting
/// associative arrays and checking success status.
/// Example:
/// ```dart
/// var result = await table.select(conn, query);
/// if (result.success) {
///   for (var row in result.assoc) {
///     print('User: ${row['name']} - ${row['email']}');
///   }
/// } else {
///   print('Query failed: ${result.errorMsg}');
/// }
/// ```
class MySqlResult
    implements SqlDatabaseResult<MySQLConnection, IResultSet, ResultSetRow> {
  /// The underlying MySQL result set from the database driver.
  @override
  final IResultSet resultSet;

  /// Error message if the query failed, empty string if successful.
  @override
  String errorMsg;

  /// Creates a new MySqlResult instance.
  /// Parameters:
  /// * [resultSet] - The MySQL result set from the database operation
  /// * [errorMsg] - Optional error message, defaults to empty string
  MySqlResult({
    required this.database,
    required this.resultSet,
    this.errorMsg = '',
  });

  /// Returns `true` if the query executed successfully (no error message).
  @override
  bool get success => errorMsg.isEmpty;

  /// Returns `true` if the query failed (has an error message).
  @override
  bool get error => !success;

  /// Returns an iterable of result set rows.
  /// Use this for direct access to the MySQL client's row objects.
  @override
  List<ResultSetRow> get rows => resultSet.rows.toList();

  /// Returns the number of rows affected by the last INSERT, UPDATE, or DELETE.
  /// This is useful for determining how many records were modified by
  /// data manipulation operations.
  @override
  int get affectedRows => resultSet.affectedRows.toInt();

  /// Returns the auto-generated ID from the last INSERT operation.
  /// This is particularly useful when inserting records into tables
  /// with auto-increment primary keys.
  @override
  int get insertId => resultSet.lastInsertID.toInt();

  /// Returns the number of columns in the result set.
  @override
  int get numFields => resultSet.numOfColumns;

  /// Returns the number of rows in the result set.
  @override
  int get numRows => resultSet.numOfRows;

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
  List<Map<String, String?>> get assoc =>
      rows.map((row) => row.assoc()).toList();

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
    return rows.first.assoc();
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
    return int.tryParse((assocFirst?[SqlDatabaseResult.countRecordsField] ?? 0)
            .toString()) ??
        0;
  }

  @override
  Future<List<Map<String, Object?>>> assocBy(DataAssoc dataAssoc) async {
    var list = <Map<String, Object?>>[];

    for (var row in rows) {
      list.add(await dataAssoc.toAssoc(row.assoc()));
    }

    return list;
  }

  @override
  MySQLConnection database;
}

abstract class DataAssoc {
  Future<Map<String, Object?>> toAssoc(Map<String, Object?> row);
}

/// Abstract base class for MySQL table operations.
abstract class MysqlTable {
  DatabaseDriver get db;

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
    var res = await table.select(db, query);
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
