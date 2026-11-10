import 'package:finch/app.dart';

abstract class DartMigration {
  late FinchApp app;
  final String uniqueName;
  var target = MigrationTarget.mysql;

  DartMigration(this.uniqueName);

  final List<String> _sqls = [];

  List<String> get upSQLs {
    _sqls.clear();
    up();
    return List.unmodifiable(_sqls);
  }

  List<String> get downSQLs {
    _sqls.clear();
    down();
    return List.unmodifiable(_sqls);
  }

  DartMigration register(FinchApp app) {
    this.app = app;
    return this;
  }

  void up();
  void down();

  DartMigration addSql(String sql) {
    _sqls.add(sql);
    return this;
  }

  @override
  String toString() => runtimeType.toString();
}

enum MigrationTarget { mysql, sqlite }
