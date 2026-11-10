import '../core/error_custom_view.dart';
import '../languages/language_dart.g.dart';
import '../widgets/widget_dart.g.dart';
import 'package:finch/finch_app.dart';
import 'package:finch/finch_model.dart';
import 'package:finch/finch_tools.dart';

FinchConfigs configs = FinchConfigs(
  pathCache: pathTo(env.get('PATH_CACHE', './cache_routes')),
  jinjaMapTemplate: mapTemplates,
  widgetsPath: pathTo(env.get('WIDGETS_PATH', "./lib/widgets")),
  widgetsType: env.get('WIDGETS_TYPE', 'j2.html'),
  languagePath: pathTo(env.get('LANGUAGE_PATH', "./lib/languages")),
  languageSource: LanguageSource.dart,
  dartLanguages: languageDart,
  publicDir: pathTo(env.get('PUBLIC_DIR', './public')),
  dbConfig: FinchDBConfig(
    enable: true, //env.get('ENABLE_DATABASE', 'true') == 'true',
    dbName: env.get('MONGODB_NAME', 'example'),
    auth: env.get('MONGODB_AUTH', 'admin'),
    pass: env.get('MONGODB_PASSWORD', 'PasswordMongoDB'),
    host: env.get('MONGODB_CONNECTION', 'localhost'),
    port: env.get('MONGODB_PORT', '27018'),
    user: env.get('MONGODB_USER', 'root'),
  ),
  port: (env.getInt('DOMAIN_PORT', 8085)),
  mysqlConfig: FinchMysqlConfig(
    enable: true,
    host: env.get('MYSQL_HOST', 'localhost'),
    port: (env.getInt('MYSQL_PORT', 3306)),
    user: env.get('MYSQL_USER', 'example_user'),
    pass: env.get('MYSQL_PASSWORD', 'example_password'),
    databaseName: env.get('MYSQL_DATABASE', 'example_db'),
  ),

  /// Enable local debugger
  enableLocalDebugger: (env.getBool('ENABLE_LOCAL_DEBUGGER', true)),

  /// SQLite configuration
  sqliteConfig: FinchSqliteConfig(
    enable: true,
    filePath: env.get('SQLITE_PATH', './example_database.sqlite'),
  ),
  errorWidget: ErrorCustomView(),
);
