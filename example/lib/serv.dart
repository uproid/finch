import 'dart:io';
import 'package:finch/console.dart';
import 'package:finch/finch_app.dart';
import 'app.dart' as a;

void main(List<String>? args) {
  /// Start file watcher for languages and widgets directories
  _startFileWatcher([
    a.configs.languagePath,
    a.configs.widgetsPath,
  ]);

  a.main(args);
}

/// Watches specified directories for file changes and logs them
void _startFileWatcher(List<String> directories) {
  for (final dirPath in directories) {
    final directory = Directory(dirPath);

    // Check if directory exists before watching
    if (!directory.existsSync()) {
      Print.error('⚠️  Directory not found: $dirPath');
      continue;
    }

    Print.info('👁️  Watching directory: $dirPath');

    // Watch the directory for changes
    directory.watch(recursive: true).listen(
      (FileSystemEvent event) {
        if (event.path.endsWith('.${a.configs.widgetsType}')) {
          final eventType = _getEventType(event);

          WidgetToDart(
            a.configs.widgetsPath,
            fileExtention: a.configs.widgetsType,
          ).generate().then((filePath) {
            Print.fatal('$eventType: ${event.path}\n'
                ' →  widgets file: $filePath');
          });
        } else if (event.path.endsWith('.json')) {
          final eventType = _getEventType(event);

          LanguageToDart(
            a.configs.languagePath,
            fileExtention: '.json',
          ).generate().then((res) {
            a.configs.dartLanguages = res.map;
            FinchApp.appLanguages = res.map;
            Print.info('$eventType: ${event.path}\n'
                ' →  language file: ${res.path}');
          });
        }
      },
      onError: (error) {
        Print.error('❌ Error watching $dirPath: $error');
      },
    );
  }
}

/// Returns a human-readable event type
String _getEventType(FileSystemEvent event) {
  if (event is FileSystemCreateEvent) {
    return 'CREATED ✨';
  } else if (event is FileSystemModifyEvent) {
    return 'MODIFIED ';
  } else if (event is FileSystemDeleteEvent) {
    return 'DELETED 🗑️';
  } else if (event is FileSystemMoveEvent) {
    return 'MOVED 📦';
  }
  return 'UNKNOWN ❓';
}
