import 'dart:io';
import 'dart:async';
import 'package:finch/console.dart';
import 'package:finch/finch_app.dart';
import 'app.dart' as a;

void main(List<String>? args) {
  a.main(args);
  // Int first conversion on startup
  _modifyLanguages();
  Print.info('✅  Initial language files converted.');
  _modifyWidgets();
  Print.info('✅  Initial widget files converted.');

  /// Start file watcher for languages and widgets directories
  _startFileWatcher([
    a.configs.languagePath,
    a.configs.widgetsPath,
  ]);
}

/// Polling-based file watcher that works in Docker
void _startFileWatcher(List<String> directories) {
  final fileModTimes = <String, DateTime>{};

  for (final dirPath in directories) {
    final directory = Directory(dirPath);

    // Check if directory exists before watching
    if (!directory.existsSync()) {
      Print.error('⚠️  Directory not found: $dirPath');
      continue;
    }

    // Initialize modification times
    _scanDirectory(directory, fileModTimes);

    Print.info(
        '👁️  Watching directory: $dirPath (polling mode for Docker compatibility)');

    // Poll every 500ms for file changes
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      try {
        _checkForChanges(directory, fileModTimes);
      } catch (e) {
        Print.error('❌ Error checking $dirPath: $e');
      }
    });
  }
}

/// Scan directory and store modification times
void _scanDirectory(Directory directory, Map<String, DateTime> fileModTimes) {
  if (!directory.existsSync()) return;

  try {
    directory.listSync(recursive: true).forEach((entity) {
      if (entity is File &&
          (entity.path.endsWith('.${a.configs.widgetsType}') ||
              entity.path.endsWith('.json'))) {
        fileModTimes[entity.path] = entity.lastModifiedSync();
      }
    });
  } catch (e) {
    // Silently ignore scan errors
  }
}

/// Check for file changes by comparing modification times
void _checkForChanges(Directory directory, Map<String, DateTime> fileModTimes) {
  if (!directory.existsSync()) return;

  final currentFiles = <String>{};

  try {
    directory.listSync(recursive: true).forEach((entity) {
      if (entity is File &&
          (entity.path.endsWith('.${a.configs.widgetsType}') ||
              entity.path.endsWith('.json'))) {
        currentFiles.add(entity.path);
        final currentModTime = entity.lastModifiedSync();
        final previousModTime = fileModTimes[entity.path];

        if (previousModTime == null) {
          // New file created
          fileModTimes[entity.path] = currentModTime;
          _handleFileChange(entity.path, 'CREATED ✨');
        } else if (currentModTime.isAfter(previousModTime)) {
          // File modified
          fileModTimes[entity.path] = currentModTime;
          _handleFileChange(entity.path, 'MODIFIED 📝');
        }
      }
    });

    // Check for deleted files
    final deletedFiles = fileModTimes.keys
        .where((path) =>
            !currentFiles.contains(path) &&
            (path.startsWith(directory.path) ||
                path.startsWith('./${directory.path}')))
        .toList();

    for (final deletedPath in deletedFiles) {
      fileModTimes.remove(deletedPath);
      Print.info('DELETED 🗑️: $deletedPath');
    }
  } catch (e) {
    // Silently ignore check errors
  }
}

/// Handle file change events
void _handleFileChange(String path, String eventType) {
  if (path.endsWith('.${a.configs.widgetsType}')) {
    _modifyLanguages().then((filePath) {
      Print.fatal('$eventType: $path\n'
          ' →  widgets file: $filePath');
    });
  } else if (path.endsWith('.json')) {
    _modifyWidgets().then((res) {
      Print.info('$eventType: $path\n'
          ' →  language file: ${res.path}');
    });
  }
}

Future<dynamic> _modifyLanguages() async {
  return WidgetToDart(
    a.configs.widgetsPath,
    fileExtention: a.configs.widgetsType,
  ).generate();
}

Future<dynamic> _modifyWidgets() async {
  var res = await LanguageToDart(
    a.configs.languagePath,
    fileExtention: '.json',
  ).generate();

  a.configs.dartLanguages = res.map;
  FinchApp.appLanguages = res.map;

  return res;
}
