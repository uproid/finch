import 'package:finch/finch_model_less.dart';
import 'package:finch/finch_ui.dart';
import 'package:finch/finch_mysql.dart';

class MysqlBooks {
  DatabaseDriver db;

  final table = MTable(
    name: 'books',
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
          comment: 'Title of the book',
          validators: [
            FieldValidator.requiredField().toSimple(),
            FieldValidator.fieldLength(min: 3, max: 255).toSimple(),
          ]),
      MFieldVarchar(
        name: 'author',
        isNullable: false,
        comment: 'Author of the book',
        validators: [
          FieldValidator.requiredField().toSimple(),
          FieldValidator.fieldLength(min: 3, max: 255).toSimple(),
        ],
      ),
      MFieldDate(
        name: 'published_date',
        isNullable: false,
        comment: 'Published date of the book',
        validators: [
          FieldValidator.isDateField(isRequired: true).toSimple(),
        ],
      ),
      MFieldInt(
        name: 'category_id',
        isNullable: true,
        comment: 'Category ID',
        validators: [
          FieldValidator.isNumberField(isRequired: false).toSimple(),
        ],
      ),
    ],
  );

  MysqlBooks(this.db);

  Future<({int count, SqlDatabaseResult rows})> getAllBooks(
    String sort,
    String order, {
    Map<String, dynamic> filters = const {},
    int? limit,
    int? offset,
  }) async {
    var sortableFileds = [
      'title',
      'author',
      'published_date',
      'b.id',
      'category_id',
    ];

    var query = Sqler()
      ..from(QField(table.name, as: 'b'))
      ..selects([
        QSelect('b.title', as: 'title'),
        QSelect('b.author', as: 'author'),
        QSelect('b.published_date', as: 'published_date'),
        QSelect('b.category_id', as: 'category_id'),
        QSelect('categories.title', as: 'category_title'),
        QSelect('b.id', as: 'id'),
      ])
      ..join(
        LeftJoin(
          'categories',
          On([
            Condition(
              QField('category_id'),
              QO.EQ,
              QField('categories.id'),
            ),
          ]),
        ),
      );

    if (sortableFileds.contains(sort)) {
      query.orderBy(QOrder(sort, desc: order == 'desc'));
    } else {
      query.orderBy(QOrder('b.id', desc: false));
    }

    query = updateFilters(query, filters);
    if (limit != null) {
      query.limit(limit, offset);
    }

    var countQuery = query.copyWith(
      selects: [
        SQL.count(QField('b.id', as: 'count_records')),
      ],
    )
      ..clearGroupBy()
      ..clearOrderBy()
      ..clearLimit();

    var books = await table.select(db, query);
    if (books.error) {
      throw (books.errorMsg);
    }

    var countResult = await table.select(db, countQuery);
    var count = countResult.countRecords;
    return (count: count, rows: books);
  }

  Sqler updateFilters(Sqler query, Map<String, dynamic> filter) {
    var where = <Condition>[];
    if (filter.containsKey('filter_author') &&
        filter['filter_author'].toString().isNotEmpty) {
      where.add(
        Condition(
          QField('author'),
          QO.LIKE,
          QVar('%${filter['filter_author']}%'),
        ),
      );
    }

    if (filter.containsKey('filter_title') &&
        filter['filter_title'].toString().isNotEmpty) {
      where.add(
        Condition(
          QField('b.title'),
          QO.LIKE,
          QVarLike(filter['filter_title']),
        ),
      );
    }

    if (filter.containsKey('filter_published_date') &&
        filter['filter_published_date'].toString().isNotEmpty) {
      where.add(
        Condition(
          QField('published_date'),
          QO.EQ,
          QVar(filter['filter_published_date']),
        ),
      );
    }

    if (filter.containsKey('filter_b.id') &&
        filter['filter_b.id'].toString().isNotEmpty) {
      where.add(
        Condition(
          QField('b.id'),
          QO.EQ,
          QVar(filter['filter_b.id'].toString().asInt(def: 0)),
        ),
      );
    }

    if (filter.containsKey('filter_category_id') &&
        filter['filter_category_id'].toString().isNotEmpty) {
      where.add(
        Condition(
          QField('category_id'),
          QO.EQ,
          QVar(filter['filter_category_id'].toString().asInt(def: 0)),
        ),
      );
    }

    if (where.isNotEmpty) {
      query.where(AndWhere(where));
    }
    return query;
  }

  Future<Map<String, dynamic>?> getBookById(String id) async {
    var query = Sqler()
      ..from(QField(table.name))
      ..selects([QSelectAll()])
      ..where(
        WhereOne(QField.id(), QO.EQ, QVar(id)),
      );

    var result = await table.select(db, query);
    return result.assocFirst;
  }

  Future<void> deleteBook(String id) async {
    var query = Sqler()
      ..delete()
      ..from(QField(table.name))
      ..where(WhereOne(QField.id(), QO.EQ, QParam('id')))
      ..addParam('id', QVar(id));

    table.delete(db, query);
  }

  Future<void> deleteAllBooks(List<String> ids) async {
    var query = Sqler()
      ..delete()
      ..from(QField(table.name))
      ..where(WhereOne(QField.id(), QO.IN, QVar(ids)));
    await table.delete(db, query);
  }

  Future<SqlDatabaseResult> addNewBook({
    required String title,
    required String author,
    required String publishedDate,
    String? categoryId,
  }) async {
    var data = {
      'title': QVar(title),
      'author': QVar(author),
      'published_date': QVar(publishedDate),
      'category_id': categoryId != null && categoryId.trim().isNotEmpty
          ? QVar(categoryId)
          : QNull(),
    };

    return await table.insert(db, data);
  }

  Future<SqlDatabaseResult> updateBook({
    required String id,
    required String title,
    required String author,
    required String publishedDate,
    String? categoryId,
  }) async {
    Sqler query = Sqler()
      ..update(QField(table.name))
      ..updateSet('title', QVar(title))
      ..updateSet('author', QVar(author))
      ..updateSet('published_date', QVar(publishedDate))
      ..updateSet(
          'category_id',
          categoryId != null && categoryId.trim().isNotEmpty
              ? QVar(categoryId)
              : QNull())
      ..where(WhereOne(QField.id(), QO.EQ, QParam('id')))
      ..addParam('id', QVar(id));
    var result = await table.select(db, query);
    return result;
  }
}
