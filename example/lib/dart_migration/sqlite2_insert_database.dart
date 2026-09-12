import 'package:finch/mysql.dart';

class M2insertDatabase extends DartMigration {
  @override
  MigrationTarget get target => MigrationTarget.sqlite;

  M2insertDatabase() : super('m2');

  @override
  void up() {
    addSql('''
      INSERT INTO users (name, email) VALUES 
      ('Alice Johnson', 'alice@example.com'),
      ('Bob Smith', 'bob@example.com'),
      ('Charlie Brown', 'charlie@example.com');
    ''');

    addSql('''
      INSERT INTO products (name, price, stock) VALUES
      ('Laptop', 999.99, 10),
      ('Smartphone', 499.50, 20),
      ('Headphones', 89.99, 50),
      ('Keyboard', 45.00, 30);
    ''');

    addSql('''
      INSERT INTO orders (user_id) VALUES
      (1), -- Alice
      (2); -- Bob
    ''');

    addSql('''
      INSERT INTO order_items (order_id, product_id, quantity) VALUES
      (1, 1, 1), -- Alice bought 1 Laptop
      (1, 4, 2), -- Alice bought 2 Keyboards
      (2, 2, 1), -- Bob bought 1 Smartphone
      (2, 3, 1); -- Bob bought 1 Headphones
    ''');
  }

  @override
  void down() {
    addSql('DELETE FROM users;');
    addSql('DELETE FROM products;');
    addSql('DELETE FROM orders;');
    addSql('DELETE FROM order_items;');
  }
}
