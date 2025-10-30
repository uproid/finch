import 'package:finch/finch_model_less.dart';
import 'package:finch/finch_ui.dart';
import 'package:finch/finch_mysql.dart';

class MysqlCategories {
  DatabaseDriver db;

  final table = MTable(
    name: 'categories',
    fields: [
      MFieldInt(
        name: 'id',
        isPrimaryKey: true,
        isAutoIncrement: true,
        isNullable: false,
      ),
      MFieldVarchar(
        name: 'title',
        isNullable: false,
        comment: 'Title of the category',
        validators: [
          FieldValidator.requiredField().toSimple(),
          FieldValidator.fieldLength(min: 3, max: 255).toSimple(),
        ],
      ),
    ],
  );

  MysqlCategories(this.db);

  Future<({int count, SqlDatabaseResult rows})> getAllCategories(
    String sort,
    String order, {
    Map<String, dynamic> filters = const {},
    int? limit,
    int? offset,
  }) async {
    var sortableFileds = [
      'title',
      'id',
    ];

    var query = Sqler()
      ..from(QField(table.name, as: 'c'))
      ..selects([
        QSelect('c.title', as: 'title'),
        QSelect('c.id', as: 'id'),
        SQL.count(QField('books.id', as: 'count_books')),
      ])
      ..join(
        LeftJoin(
          'books',
          On([
            Condition(
              QField('c.id'),
              QO.EQ,
              QField('books.category_id'),
            ),
          ]),
        ),
      ).groupBy([
        'c.id',
      ]);

    if (sortableFileds.contains(sort)) {
      query.orderBy(QOrder(sort, desc: order == 'desc'));
    } else {
      query.orderBy(QOrder('id', desc: false));
    }

    query = updateFilters(query, filters);
    if (limit != null) {
      query.limit(limit, offset);
    }

    var countQuery = query.copyWith(
      selects: [
        SQL.count(QField('id', as: 'count_records')),
      ],
    )
      ..clearGroupBy()
      ..clearOrderBy()
      ..clearLimit();

    var categories = await table.select(db, query);
    if (categories.error) {
      throw (categories.errorMsg);
    }

    var countResult = await table.select(db, countQuery);
    var count = countResult.countRecords;

    return (count: count, rows: categories);
  }

  Sqler updateFilters(Sqler query, Map<String, dynamic> filter) {
    var where = <Condition>[];

    if (filter.containsKey('filter_title') &&
        filter['filter_title'].toString().isNotEmpty) {
      where.add(
        Condition(
          QField('title'),
          QO.LIKE,
          QVarLike(filter['filter_title']),
        ),
      );
    }

    if (filter.containsKey('filter_id')) {
      where.add(
        Condition(
          QField('id'),
          QO.EQ,
          QVar(filter['filter_id'].toString().asInt(def: 0)),
        ),
      );
    }

    if (where.isNotEmpty) {
      query.where(AndWhere(where));
    }
    return query;
  }

  Future<Map<String, dynamic>?> getCategoryById(String id) async {
    var query = Sqler()
      ..from(QField(table.name))
      ..selects([QSelectAll()])
      ..where(
        WhereOne(QField.id(), QO.EQ, QVar(id)),
      );

    var result = await table.select(db, query);
    return result.assocFirst;
  }

  Future<void> deleteCategory(String id) async {
    var query = Sqler()
      ..delete()
      ..from(QField(table.name))
      ..where(WhereOne(QField.id(), QO.EQ, QParam('id')))
      ..addParam('id', QVar(id));

    table.delete(db, query);
  }

  Future<void> deleteAllCategories(List<String> ids) async {
    var query = Sqler()
      ..delete()
      ..from(QField(table.name))
      ..where(WhereOne(QField.id(), QO.IN, QVar(ids)));
    await table.delete(db, query);
  }

  Future<SqlDatabaseResult> addNewCategory({
    required String title,
  }) async {
    Sqler q = Sqler()
      ..insert(
        QField(table.name),
        [
          {
            'title': QVar(title),
          }
        ],
      );

    return await table.execute(db, q);
  }

  Future<SqlDatabaseResult> updateCategory({
    required String id,
    required String title,
  }) async {
    Sqler query = Sqler()
      ..update(QField(table.name))
      ..updateSet('title', QVar(title))
      ..where(WhereOne(QField.id(), QO.EQ, QParam('id')))
      ..addParam('id', QVar(id));
    var result = await table.select(db, query);
    return result;
  }
}
