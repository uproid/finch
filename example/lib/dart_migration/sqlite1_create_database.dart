import 'package:finch/mysql.dart';

class M1createDatabase extends DartMigration {
  @override
  MigrationTarget get target => MigrationTarget.sqlite;

  M1createDatabase() : super('m1');

  @override
  void up() {
    addSql('''
      CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          email TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
      ''');

    addSql('''
      CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          price REAL,
          stock INTEGER
      );
      ''');

    addSql('''
      CREATE TABLE orders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER,
          order_date TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(id)
      );
      ''');

    addSql('''
      CREATE TABLE order_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          order_id INTEGER,
          product_id INTEGER,
          quantity INTEGER,
          FOREIGN KEY (order_id) REFERENCES orders(id),
          FOREIGN KEY (product_id) REFERENCES products(id)
      );
      ''');

    addSql('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        published_date TEXT NOT NULL
      );
    ''');

    addSql('''
      CREATE TABLE IF NOT EXISTS categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL
      );
    ''');
  }

  @override
  void down() {
    addSql('DROP TABLE IF EXISTS users;');
    addSql('DROP TABLE IF EXISTS products;');
    addSql('DROP TABLE IF EXISTS orders;');
    addSql('DROP TABLE IF EXISTS order_items;');
    addSql('DROP TABLE IF EXISTS books;');
    addSql('DROP TABLE IF EXISTS categories;');
  }
}
