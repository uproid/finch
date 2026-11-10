import 'package:finch/mysql.dart';

class M3fixDatabase extends DartMigration {
  @override
  MigrationTarget get target => MigrationTarget.sqlite;

  M3fixDatabase() : super('m3');

  @override
  void up() {
    addSql('''
    INSERT INTO books (title, author, published_date)
    VALUES ('XXXXXXX', 'YYYYYYY', '1925-04-10');
    ''');

    addSql('''
    ALTER TABLE books
    ADD COLUMN category_id INTEGER DEFAULT NULL;
    ''');
  }

  @override
  void down() {
    addSql('''
    ALTER TABLE books DROP COLUMN category_id;
    ''');
  }
}
