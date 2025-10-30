import '../db/sqlite/sqlite_categories.dart';
import '../app.dart';
import '../db/mysql/mysql_categories.dart';
import 'package:finch/finch_tools.dart';
import 'package:finch/finch_ui.dart';

class BookForm extends AdvancedForm {
  @override
  String get widget =>
      'example/${isSqlite ? 'sqlite' : 'mysql'}/_form_edit.j2.html';

  @override
  String get name => 'form_book';
  BookForm({super.initData = const {}, required this.isSqlite});

  final bool isSqlite;

  @override
  List<Field> fields() {
    return [
      csrf(),
      Field(
        'title',
        validators: [
          FieldValidator.requiredField(),
          FieldValidator.fieldLength(min: 3, max: 255),
        ],
      ),
      Field(
        'author',
        validators: [
          FieldValidator.requiredField(),
          FieldValidator.fieldLength(min: 3, max: 255),
        ],
      ),
      Field(
        'published_date',
        validators: [
          FieldValidator.requiredField(),
          FieldValidator.isDateField(isRequired: true),
        ],
        initValue: DateTime.now().format('yyyy-MM-dd'),
      ),
      Field(
        'category_id',
        validators: [
          if (isSqlite)
            FieldValidator.hasSqlRelation(
              isRequired: false,
              db: app.sqliteDriver,
              table: 'categories',
              field: 'id',
            )
          else
            FieldValidator.hasSqlRelation(
              isRequired: false,
              db: app.mysqlDriver,
              table: 'categories',
              field: 'id',
            )
        ],
        initValue: '',
        initOptions: (field) async {
          if (isSqlite) {
            var categories =
                await SqliteCategories(app.sqliteDriver).getAllCategories(
              'title',
              'desc',
            );
            return categories.rows.assoc;
          } else {
            var categories =
                await MysqlCategories(app.mysqlDriver).getAllCategories(
              'title',
              'desc',
            );
            return categories.rows.assoc;
          }
        },
      ),
    ];
  }
}
