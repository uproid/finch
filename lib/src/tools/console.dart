import 'dart:io';
import 'package:logger/logger.dart';

typedef LogCallback = void Function(Object? log, String type);

/// A utility class for logging messages with different severity levels.
/// The [Console] class provides static methods for logging warnings, errors,
/// information, debugging messages, and fatal errors. The logs are managed using
/// the [Logger] package and optionally printed to the console.
/// Example usage:
/// ```dart
/// Console.i("This is an informational message.");
/// Console.e("This is an error message.");
/// ```
class Console {
  static final onError = <LogCallback>[];
  static final onLogging = <LogCallback>[];

  /// The [Logger] instance used for managing log messages.
  static final _logger = Logger(
    level: isTestRunning() ? Level.off : Level.debug,
    printer: PrettyPrinter(
      printEmojis: false,
    ),
  );

  /// Logs a formatted JSON object with visual separators.
  ///
  /// This method creates a visually distinct log entry for JSON or complex objects,
  /// using separators and special formatting to make the output easily readable.
  /// The object is logged as a fatal level message with no method count and
  /// clear visual boundaries.
  ///
  /// [object] The object to be logged, typically a Map, List, or any JSON-serializable object
  ///
  /// Example usage:
  /// ```dart
  /// Console.json({'user': 'john', 'status': 'active', 'permissions': ['read', 'write']});
  /// // Output:
  /// // ==================================================
  /// // {user: john, status: active, permissions: [read, write]}
  /// // ==================================================
  /// ```
  static void json(dynamic object) {
    var log = Logger(
      level: isTestRunning() ? Level.off : Level.debug,
      printer: PrettyPrinter(
        printEmojis: false,
        noBoxingByDefault: true,
        excludeBox: {},
        colors: true,
        methodCount: 0,
      ),
    );

    log.f("=" * 50 + '\n');
    log.f(object);
    log.f('\n${"=" * 50}');
  }

  /// Logs a warning message.
  ///
  /// The [object] parameter can be any type of object to be logged.
  static void w(dynamic object) {
    _logger.w(object);
    _writeLog(object, 'warning');
  }

  /// Logs an error message.
  ///
  /// The [object] parameter can be any type of object to be logged.
  static void e(dynamic object) {
    _logger.e(object);
    _writeLog(object, 'error');
    for (var callback in onError) {
      callback(object, 'error');
    }
  }

  /// Logs an informational message.
  ///
  /// The [object] parameter can be any type of object to be logged.
  static void i(dynamic object) {
    _logger.i(object);
    _writeLog(object);
  }

  /// Logs a fatal or critical error message.
  ///
  /// The [object] parameter can be any type of object to be logged.
  static void p(dynamic object) {
    _logger.f(object);
    _writeLog(object, 'fatal');
  }

  /// Logs a debug message.
  ///
  /// The [object] parameter can be any type of object to be logged.
  static void d(dynamic object) {
    _logger.d(object);
    _writeLog(object, 'debug');
  }

  /// Writes the log to the console.
  ///
  /// This is a private method used internally by the logging methods
  /// to print the log message.
  static void _writeLog(dynamic object, [String type = 'info']) {
    if (isDebug) {
      for (var callback in onLogging) {
        callback(object, type);
      }
    } else {
      write(object);
    }
  }

  /// Prints the given [obj] to the console.
  ///
  /// This method is public and can be used to directly print messages.
  static void write(dynamic obj) => print(obj);

  /// Checks if the application is running in debug mode.
  ///
  /// Returns `true` if in debug mode; otherwise, returns `false`.
  /// This is determined using the Dart `assert` statement.
  static bool get isDebug {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  /// Checks if the application is running in test mode.
  ///
  /// This method determines if the current execution environment is a test
  /// environment by checking the WEBAPP_IS_TEST environment variable.
  /// When running tests, certain logging and debugging features may be
  /// disabled to avoid interference with test output.
  ///
  /// Returns `true` if the application is running in test mode, `false` otherwise.
  ///
  /// Example usage:
  /// ```dart
  /// if (!Console.isTestRunning()) {
  ///   Console.i('Application started in development mode');
  /// }
  /// ```
  static bool isTestRunning() {
    return Platform.environment['WEBAPP_IS_TEST'] == 'true';
  }
}
