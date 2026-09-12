import 'dart:convert';
import 'dart:io';

import 'package:finch/finch_tools.dart';

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
    Log.w(
      JsonEncoder.withIndent('  ').convert(object),
      level: LogLevel.FINE,
    );
  }

  /// Logs a warning message.
  ///
  /// The [object] parameter can be any type of object to be logged.
  static void w(dynamic object) {
    Log.w(object, level: LogLevel.WARNING);
    _writeLog(object, 'warning');
  }

  /// Logs an error message.
  ///
  /// The [object] parameter can be any type of object to be logged.
  static void e(dynamic object) {
    Log.w(object, level: LogLevel.ERROR);
    _writeLog(object, 'error');
    for (var callback in onError) {
      callback(object, 'error');
    }
  }

  /// Logs an informational message.
  ///
  /// The [object] parameter can be any type of object to be logged.
  static void i(dynamic object) {
    Log.w(object, level: LogLevel.INFO);
    _writeLog(object);
  }

  /// Logs an debug message.
  ///
  /// The [object] parameter can be any type of object to be logged.
  static void d(dynamic object) {
    Log.w(object, level: LogLevel.DEBUG);
    _writeLog(object);
  }

  /// Logs a fatal or critical error message.
  ///
  /// The [object] parameter can be any type of object to be logged.
  static void p(dynamic object) {
    Log.w(object, level: LogLevel.FINE);
    _writeLog(object, 'fatal');
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
      //write(object);
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

  /// Checks if the application is not running in debug mode.
  static bool get isNotDebug => !isDebug;

  /// Checks if the application is running in test mode.
  ///
  /// This method determines if the current execution environment is a test
  /// environment by checking the FINCH_IS_TEST environment variable.
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
    return Platform.environment['FINCH_IS_TEST'] == 'true';
  }
}

class Print {
  static void error(String message) {
    Log.w(message, level: LogLevel.ERROR, header: false);
  }

  static void info(String message) {
    Log.w(message, level: LogLevel.INFO, header: false);
  }

  static void debug(String message) {
    Log.w(message, level: LogLevel.DEBUG, header: false);
  }

  static void fatal(String message) {
    Log.w(message, level: LogLevel.ERROR, header: false);
  }

  static void warning(String message) {
    Log.w(message, level: LogLevel.WARNING, header: false);
  }
}

class Log {
  static void w(dynamic object,
      {var level = LogLevel.FINE, var header = true}) {
    final frames = StackTrace.current.toString().split('\n');
    final callerFrame = frames
        .firstWhere(
          (frame) => !frame.contains('console.dart'),
          orElse: () => '',
        )
        .replaceFirst(RegExp(r'^\s*#?\d+\s+'), '')
        .trim();

    String startColor = "";
    String endColor = "\x1B[0m";

    switch (level) {
      case LogLevel.ERROR:
        startColor = "\x1B[38;5;196m"; // bright red
        break;

      case LogLevel.WARNING:
        startColor = "\x1B[38;2;255;193;7m";
        break;
      case LogLevel.DEBUG:
        startColor = "\x1B[38;2;150;150;150m"; // gray
        break;

      case LogLevel.FINE:
        startColor = "\x1B[38;2;80;220;120m"; // gray
        break;
    }

    StringBuffer str = StringBuffer();
    str.writeln("$startColor┌${"─" * 98}┐$endColor");
    if (header) {
      str.writeln("$startColor│ $callerFrame$endColor");
      str.writeln("$startColor├${"─" * 98}┤$endColor");
    }

    if (object is Map &&
        object.containsKey('error') &&
        object.containsKey('stack')) {
      str.writeln(
          "$startColor  $level ${DateTime.now().format('y-M-d H:m:s')} ${object['error']}$endColor");
      str.writeln("$startColor├${"─" * 98}┤$endColor");
      int index = 0;
      for (var s in object['stack'] as List) {
        var line = s.toString().replaceFirst(RegExp(r'^\s*\d+\s+'), '').trim();
        line = line.replaceAll('\n', ' ');
        if (line.isNotEmpty) {
          str.writeln("$startColor  ${++index}. $line$endColor");
        }
      }
    } else {
      for (var obLine in object.toString().split('\n')) {
        str.writeln("$startColor  $obLine$endColor");
      }
    }

    str.writeln(startColor + ("└${"─" * 98}┘") + endColor);

    print(str.toString());
  }
}

enum LogLevel {
  ERROR,
  WARNING,
  INFO,
  FINE,
  DEBUG;

  @override
  String toString() {
    switch (this) {
      case LogLevel.ERROR:
        return "ERROR";
      case LogLevel.INFO:
        return "INFO";
      case LogLevel.FINE:
        return "FINE";
      case LogLevel.DEBUG:
        return "DEBUG";
      case LogLevel.WARNING:
        return "WARNING";
    }
  }
}
