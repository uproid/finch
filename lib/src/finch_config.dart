import 'package:dotenv/dotenv.dart';
import 'package:finch/finch_model.dart';
import 'package:finch/src/tools/convertor/string_validator.dart';
import 'package:finch/src/tools/path.dart';
import 'package:finch/finch_console.dart';

var env = DotEnv(includePlatformEnvironment: true)..load();

/// Configuration management system for the Finch framework.
/// [FinchConfigs] provides comprehensive configuration management for all aspects
/// of the web application including server settings, database connections,
/// file paths, security settings, and development tools. The configuration
/// system supports environment variables, default values, and runtime customization.
/// Key features:
/// - Environment variable integration with .env file support
/// - Database configuration for MongoDB and MySQL
/// - Server and domain configuration
/// - Path management for assets, templates, and uploads
/// - Mail server configuration
/// - Template engine configuration (Jinja-like syntax)
/// - Development and debugging tools
/// - Multi-language support
/// - Security settings (cookies, CORS, etc.)
/// Environment variables are automatically loaded from:
/// - System environment variables
/// - .env file in the project root
/// - Platform-specific environment settings
/// Example usage:
/// ```dart
/// final config = FinchConfigs(
///   port: 8080,
///   domain: 'example.com',
///   dbConfig: FinchDBConfig(
///     host: 'localhost',
///     dbName: 'myapp',
///     enable: true,
///   ),
///   enableLocalDebugger: true, // Only in development
/// );
/// final server = FinchApp(configs: config);
/// await server.start();
/// ```
class FinchConfigs {
  /// Creates an instance of [FinchConfigs].
  /// Initializes configuration properties with values from environment variables
  /// or defaults provided in the parameters.
  FinchConfigs({
    this.version = '1.0.0',
    String? appPath,
    String? dbPath,
    String? backupPath,
    String? widgetsPath,
    String? languagePath,
    this.pathMigrationMySQL = './migrations',
    this.pathMigrationSQLite = './migrations_sqlite',
    this.port = 8080,
    this.portSocket = 8083,
    this.portNginx = 80,
    this.ip = '0.0.0.0',
    this.dbName = "database_name",
    this.noStop = true,
    this.serverName = "webserver",
    this.pathFilemanager = '/upload/filemanager',
    this.languageSource = LanguageSource.json,
    this.dartLanguages = const {},
    String? publicDir,
    String? domain,
    String? domainScheme,
    int? domainPort,
    FinchDBConfig? dbConfig,
    this.widgetsType = 'html',
    this.jinjaMapTemplate,
    this.fakeDelay = 0,
    List<String>? languages,
    this.mailDefault = "example@uproid.com",
    this.mailHost = "smtp.zoho.eu",
    this.blockStart = '{%',
    this.blockEnd = "%}",
    this.variableStart = "{{",
    this.variableEnd = "}}",
    this.commentStart = '{#',
    this.commentEnd = '#}',
    this.cookiePassword = "password",
    FinchMysqlConfig? mysqlConfig,
    FinchSqliteConfig? sqliteConfig,
    this.poweredBy = "Dart Finch",
    this.enableLocalDebugger = false,
  }) {
    this.appPath = appPath ?? pathApp;
    this.dbPath = dbPath ?? pathTo("db");
    this.backupPath = backupPath ?? pathTo("backup");
    this.widgetsPath = widgetsPath ?? pathTo("bin/widgets");
    this.languagePath = languagePath ?? pathTo("languages");
    this.domain = domain ?? env['DOMAIN'] ?? 'localhost';
    this.domainScheme = domainScheme ?? env['DOMAIN_SCHEME'] ?? "http";
    this.domainPort = domainPort ?? int.parse(env['DOMAIN_PORT'] ?? "$port");
    this.publicDir = publicDir ?? (env['PUBLIC_DIR'] ?? "public");
    uri = Uri(
      scheme: this.domainScheme,
      host: this.domain,
      port: this.domainPort,
    );
    this.dbConfig = dbConfig ?? FinchDBConfig();
    this.mysqlConfig = mysqlConfig ?? FinchMysqlConfig();
    this.sqliteConfig = sqliteConfig ?? FinchSqliteConfig();
    this.languages = languages ?? FinchDBConfig.defaultLanguages.keys.toList();
  }

  final String version;
  late final List<String> languages;
  late final String appPath;
  late final String dbPath;
  late final String backupPath;
  late final String widgetsPath;
  late final String languagePath;
  final LanguageSource languageSource;
  Map<String, Map<String, String>> dartLanguages;
  final int port;
  final int portSocket;
  final int portNginx;
  final String ip;
  final String dbName;
  final bool noStop;
  final String serverName;
  late final String publicDir;
  final String pathFilemanager;
  final String pathMigrationMySQL;
  final String pathMigrationSQLite;
  late final int fakeDelay;
  final String poweredBy;

  /// DOMAIN CONFIG
  late final String domain;
  late final String domainScheme;
  late final int domainPort;

  late final Uri uri;

  late final String mailDefault;
  late final String mailHost;
  late final String widgetsType;
  Map<String, String>? jinjaMapTemplate;
  late final String blockStart;
  late final String blockEnd;
  late final String variableStart;
  late final String variableEnd;
  late final String commentStart;
  late final String commentEnd;
  late final String cookiePassword;
  late final FinchDBConfig dbConfig;
  late final FinchMysqlConfig mysqlConfig;
  late final FinchSqliteConfig sqliteConfig;

  /// Enable local debugger
  /// This is useful for debugging the application in a local environment.
  /// It allows you to inspect and modify the application state in real-time.
  /// You can enable it by setting the [enableLocalDebugger] property to true.
  /// the [enableLocalDebugger] property wills activate a debugger bar on frontend side.
  /// This is useful for debugging the application in a local environment.
  /// It allows you to inspect and modify the application state in real-time.
  /// You can enable it by setting the [enableLocalDebugger] property to true.
  /// Take attention that this will only work in a local environment.
  /// dont activate it in production.
  late bool enableLocalDebugger = false;

  bool get isLocalDebug {
    if (env['LOCAL_DEBUG'] != null) {
      return env['LOCAL_DEBUG'].toString().toBool;
    } else {
      return Console.isDebug;
    }
  }

  String url({String? path}) {
    if (uri.port == 80 && uri.scheme.toLowerCase() == "https") {
      return uri.replace(port: 443, path: path).toString();
    }

    /// When the path is a full url
    if (path != null && path.startsWith('http')) {
      return path;
    }

    return uri.replace(path: path).toString();
  }
}

/// MySQL database configuration for the Finch framework.
/// [FinchMysqlConfig] manages MySQL database connection settings and provides
/// environment variable integration for secure credential management.
/// This configuration is used for SQL-based data operations, migrations,
/// and relational database features.
/// Configuration priority:
/// 1. Constructor parameters (highest)
/// 2. Environment variables
/// 3. Default values (lowest)
/// Environment variables:
/// - MYSQL_HOST: Database server hostname
/// - MYSQL_PORT: Database server port (default: 3306)
/// - MYSQL_USER: Database username
/// - MYSQL_PASS: Database password
/// - MYSQL_DATABASE: Database name
/// - MYSQL_SECURE: Enable SSL connection (true/false)
/// - MYSQL_COLLATION: Character set collation
/// Example:
/// ```dart
/// final mysqlConfig = FinchMysqlConfig(
///   host: 'localhost',
///   port: 3306,
///   user: 'finch_user',
///   pass: 'secure_password',
///   databaseName: 'finch_db',
///   enable: true,
/// );
/// ```
class FinchMysqlConfig {
  bool enable = false;
  String host = 'localhost';
  int port = 3306;
  String user = 'database_username';
  String pass = 'database_password';
  bool secure = true;
  String databaseName = "database_name";
  String collation = 'utf8mb4_general_ci';

  FinchMysqlConfig({
    String? host,
    int? port,
    String? user,
    String? pass,
    bool? secure = true,
    String? databaseName,
    String? collation,
    bool? enable,
  }) {
    this.user = user ?? env['MYSQL_USER'] ?? 'database_username';
    this.pass = pass ?? env['MYSQL_PASS'] ?? 'database_password';
    this.secure = secure ?? env['MYSQL_SECURE']?.toBool ?? true;
    this.host = host ?? env['MYSQL_HOST'] ?? 'localhost';
    this.port = port ?? env['MYSQL_PORT']?.toInt() ?? 3306;
    this.databaseName =
        databaseName ?? env['MYSQL_DATABASE'] ?? 'database_name';
    this.collation =
        collation ?? env['MYSQL_COLLATION'] ?? 'utf8mb4_general_ci';
    this.enable = enable ?? false;
  }
}

class FinchSqliteConfig {
  bool enable = false;
  String filePath = 'database.sqlite';

  FinchSqliteConfig({
    bool? enable,
    String? filePath,
  }) {
    this.enable = enable ?? false;
    this.filePath = filePath ?? 'database.sqlite';
  }
}

/// MongoDB database configuration for the Finch framework.
/// [FinchDBConfig] manages MongoDB connection settings with built-in support
/// for authentication, replica sets, and connection string generation.
/// This is the primary database configuration for document-based operations.
/// Configuration priority:
/// 1. Constructor parameters (highest)
/// 2. Environment variables
/// 3. Default values (lowest)
/// Environment variables:
/// - MONGO_INITDB_ROOT_USERNAME: MongoDB root username
/// - MONGO_INITDB_ROOT_PASSWORD: MongoDB root password
/// - MONGO_INITDB_ROOT_AUTH: Authentication database (default: admin)
/// - MONGO_CONNECTION: MongoDB host (default: localhost)
/// - MONGO_PORT: MongoDB port (default: 27017)
/// - MONGO_INITDB_DATABASE: Database name
/// The [link] property automatically generates a MongoDB connection string
/// in the format: `mongodb://user:pass@host:port/dbName/?authSource=auth`
/// Example:
/// ```dart
/// final dbConfig = FinchDBConfig(
///   host: 'localhost',
///   port: '27017',
///   user: 'finch_user',
///   pass: 'secure_password',
///   dbName: 'finch_db',
///   enable: true,
/// );
/// // Auto-generated connection string:
/// // mongodb://finch_user:secure_password@localhost:27017/finch_db/?authSource=admin
/// ```
class FinchDBConfig {
  late final bool enable;
  late final String user;
  late final String pass;
  late final String host;
  late final String port;
  late final String auth;
  late final String dbName;

  String get link =>
      'mongodb://$user:$pass@$host:$port/$dbName/?authSource=$auth';

  FinchDBConfig({
    String? user,
    String? pass,
    String? host,
    String? port,
    String? dbName,
    String? auth,
    bool? enable,
  }) {
    this.user =
        user ?? env['MONGO_INITDB_ROOT_USERNAME'] ?? 'database_username';
    this.pass =
        pass ?? env['MONGO_INITDB_ROOT_PASSWORD'] ?? 'database_password';
    this.auth = auth ?? env['MONGO_INITDB_ROOT_AUTH'] ?? 'admin';
    this.host = host ?? env['MONGO_CONNECTION'] ?? 'localhost';
    this.port = port ?? env['MONGO_PORT'] ?? '27017';
    this.dbName = env['MONGO_INITDB_DATABASE'] ?? 'database_name';
    this.enable = enable ?? false;
  }

  static const defaultLanguages = {
    "aa": "Afar",
    "ab": "Abkhazian",
    "ae": "Avestan",
    "af": "Afrikaans",
    "ak": "Akan",
    "am": "Amharic",
    "an": "Aragonese",
    "ar-ae": "Arabic (U.A.E.)",
    "ar-bh": "Arabic (Bahrain)",
    "ar-dz": "Arabic (Algeria)",
    "ar-eg": "Arabic (Egypt)",
    "ar-iq": "Arabic (Iraq)",
    "ar-jo": "Arabic (Jordan)",
    "ar-kw": "Arabic (Kuwait)",
    "ar-lb": "Arabic (Lebanon)",
    "ar-ly": "Arabic (Libya)",
    "ar-ma": "Arabic (Morocco)",
    "ar-om": "Arabic (Oman)",
    "ar-qa": "Arabic (Qatar)",
    "ar-sa": "Arabic (Saudi Arabia)",
    "ar-sy": "Arabic (Syria)",
    "ar-tn": "Arabic (Tunisia)",
    "ar-ye": "Arabic (Yemen)",
    "ar": "Arabic",
    "as": "Assamese",
    "av": "Avaric",
    "ay": "Aymara",
    "az": "Azeri",
    "ba": "Bashkir",
    "be": "Belarusian",
    "bg": "Bulgarian",
    "bh": "Bihari",
    "bi": "Bislama",
    "bm": "Bambara",
    "bn": "Bengali",
    "bo": "Tibetan",
    "br": "Breton",
    "bs": "Bosnian",
    "ca": "Catalan",
    "ce": "Chechen",
    "ch": "Chamorro",
    "co": "Corsican",
    "cr": "Cree",
    "cs": "Czech",
    "cu": "Church Slavonic",
    "cv": "Chuvash",
    "cy": "Welsh",
    "da": "Danish",
    "de-at": "German (Austria)",
    "de-ch": "German (Switzerland)",
    "de-de": "German (Germany)",
    "de-li": "German (Liechtenstein)",
    "de-lu": "German (Luxembourg)",
    "de": "German",
    "div": "Divehi",
    "dv": "Divehi",
    "dz": "Bhutani",
    "ee": "Ewe",
    "el": "Greek",
    "en-au": "English (Australia)",
    "en-bz": "English (Belize)",
    "en-ca": "English (Canada)",
    "en-cb": "English (Caribbean)",
    "en-gb": "English (United Kingdom)",
    "en-ie": "English (Ireland)",
    "en-jm": "English (Jamaica)",
    "en-nz": "English (New Zealand)",
    "en-ph": "English (Philippines)",
    "en-tt": "English (Trinidad and Tobago)",
    "en-us": "English (United States)",
    "en-za": "English (South Africa)",
    "en-zw": "English (Zimbabwe)",
    "en": "English",
    "eo": "Esperanto",
    "es-ar": "Spanish (Argentina)",
    "es-bo": "Spanish (Bolivia)",
    "es-cl": "Spanish (Chile)",
    "es-co": "Spanish (Colombia)",
    "es-cr": "Spanish (Costa Rica)",
    "es-do": "Spanish (Dominican Republic)",
    "es-ec": "Spanish (Ecuador)",
    "es-es": "Spanish (Spain)",
    "es-gt": "Spanish (Guatemala)",
    "es-hn": "Spanish (Honduras)",
    "es-mx": "Spanish (Mexico)",
    "es-ni": "Spanish (Nicaragua)",
    "es-pa": "Spanish (Panama)",
    "es-pe": "Spanish (Peru)",
    "es-pr": "Spanish (Puerto Rico)",
    "es-py": "Spanish (Paraguay)",
    "es-sv": "Spanish (El Salvador)",
    "es-us": "Spanish (United States)",
    "es-uy": "Spanish (Uruguay)",
    "es-ve": "Spanish (Venezuela)",
    "es": "Spanish",
    "et": "Estonian",
    "eu": "Basque",
    "fa": "Farsi",
    "ff": "Fulah",
    "fi": "Finnish",
    "fj": "Fiji",
    "fo": "Faroese",
    "fr-be": "French (Belgium)",
    "fr-ca": "French (Canada)",
    "fr-ch": "French (Switzerland)",
    "fr-fr": "French (France)",
    "fr-lu": "French (Luxembourg)",
    "fr-mc": "French (Monaco)",
    "fr": "French",
    "fy": "Frisian",
    "ga": "Irish",
    "gd": "Gaelic",
    "gl": "Galician",
    "gn": "Guarani",
    "gu": "Gujarati",
    "gv": "Manx",
    "ha": "Hausa",
    "he": "Hebrew",
    "hi": "Hindi",
    "ho": "Hiri Motu",
    "hr-ba": "Croatian (Bosnia and Herzegovina)",
    "hr-hr": "Croatian (Croatia)",
    "hr": "Croatian",
    "ht": "Haitian",
    "hu": "Hungarian",
    "hy": "Armenian",
    "hz": "Herero",
    "ia": "Interlingua",
    "id": "Indonesian",
    "ie": "Interlingue",
    "ig": "Igbo",
    "ii": "Sichuan Yi",
    "ik": "Inupiak",
    "in": "Indonesian",
    "io": "Ido",
    "is": "Icelandic",
    "it-ch": "Italian (Switzerland)",
    "it-it": "Italian (Italy)",
    "it": "Italian",
    "iu": "Inuktitut",
    "iw": "Hebrew",
    "ja": "Japanese",
    "ji": "Yiddish",
    "jv": "Javanese",
    "jw": "Javanese",
    "ka": "Georgian",
    "kg": "Kongo",
    "ki": "Kikuyu",
    "kj": "Kuanyama",
    "kk": "Kazakh",
    "kl": "Greenlandic",
    "km": "Cambodian",
    "kn": "Kannada",
    "ko": "Korean",
    "kok": "Konkani",
    "kr": "Kanuri",
    "ks": "Kashmiri",
    "ku": "Kurdish",
    "kv": "Komi",
    "kw": "Cornish",
    "ky": "Kirghiz",
    "kz": "Kyrgyz",
    "la": "Latin",
    "lb": "Luxembourgish",
    "lg": "Ganda",
    "li": "Limburgan",
    "ln": "Lingala",
    "lo": "Laothian",
    "ls": "Slovenian",
    "lt": "Lithuanian",
    "lu": "Luba-Katanga",
    "lv": "Latvian",
    "mg": "Malagasy",
    "mh": "Marshallese",
    "mi": "Maori",
    "mk": "FYRO Macedonian",
    "ml": "Malayalam",
    "mn": "Mongolian",
    "mo": "Moldavian",
    "mr": "Marathi",
    "ms-bn": "Malay (Brunei Darussalam)",
    "ms-my": "Malay (Malaysia)",
    "ms": "Malay",
    "mt": "Maltese",
    "my": "Burmese",
    "na": "Nauru",
    "nb": "Norwegian (Bokmal)",
    "nd": "North Ndebele",
    "ne": "Nepali (India)",
    "ng": "Ndonga",
    "nl-be": "Dutch (Belgium)",
    "nl-nl": "Dutch (Netherlands)",
    "nl": "Dutch",
    "nn": "Norwegian (Nynorsk)",
    "no": "Norwegian",
    "nr": "South Ndebele",
    "ns": "Northern Sotho",
    "nv": "Navajo",
    "ny": "Chichewa",
    "oc": "Occitan",
    "oj": "Ojibwa",
    "om": "(Afan)/Oromoor/Oriya",
    "or": "Oriya",
    "os": "Ossetian",
    "pa": "Punjabi",
    "pi": "Pali",
    "pl": "Polish",
    "ps": "Pashto/Pushto",
    "pt-br": "Portuguese (Brazil)",
    "pt-pt": "Portuguese (Portugal)",
    "pt": "Portuguese",
    "qu-bo": "Quechua (Bolivia)",
    "qu-ec": "Quechua (Ecuador)",
    "qu-pe": "Quechua (Peru)",
    "qu": "Quechua",
    "rm": "Rhaeto-Romanic",
    "rn": "Kirundi",
    "ro": "Romanian",
    "ru": "Russian",
    "rw": "Kinyarwanda",
    "sa": "Sanskrit",
    "sb": "Sorbian",
    "sc": "Sardinian",
    "sd": "Sindhi",
    "se-fi": "Sami (Finland)",
    "se-no": "Sami (Norway)",
    "se-se": "Sami (Sweden)",
    "se": "Sami",
    "sg": "Sangro",
    "sh": "Serbo-Croatian",
    "si": "Singhalese",
    "sk": "Slovak",
    "sl": "Slovenian",
    "sm": "Samoan",
    "sn": "Shona",
    "so": "Somali",
    "sq": "Albanian",
    "sr-ba": "Serbian (Bosnia and Herzegovina)",
    "sr-sp": "Serbian (Serbia and Montenegro)",
    "sr": "Serbian",
    "ss": "Siswati",
    "st": "Sesotho",
    "su": "Sundanese",
    "sv-fi": "Swedish (Finland)",
    "sv-se": "Swedish (Sweden)",
    "sv": "Swedish",
    "sw": "Swahili",
    "sx": "Sutu",
    "syr": "Syriac",
    "ta": "Tamil",
    "te": "Telugu",
    "tg": "Tajik",
    "th": "Thai",
    "ti": "Tigrinya",
    "tk": "Turkmen",
    "tl": "Tagalog",
    "tn": "Tswana",
    "to": "Tonga",
    "tr": "Turkish",
    "ts": "Tsonga",
    "tt": "Tatar",
    "tw": "Twi",
    "ty": "Tahitian",
    "ug": "Uighur",
    "uk": "Ukrainian",
    "ur": "Urdu",
    "us": "English",
    "uz": "Uzbek",
    "ve": "Venda",
    "vi": "Vietnamese",
    "vo": "Volapuk",
    "wa": "Walloon",
    "wo": "Wolof",
    "xh": "Xhosa",
    "yi": "Yiddish",
    "yo": "Yoruba",
    "za": "Zhuang",
    "zh-cn": "Chinese (China)",
    "zh-hk": "Chinese (Hong Kong SAR)",
    "zh-mo": "Chinese (Macau SAR)",
    "zh-sg": "Chinese (Singapore)",
    "zh-tw": "Chinese (Taiwan)",
    "zh": "Chinese",
    "zu": "Zulu"
  };
}
