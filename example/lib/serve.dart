import 'dart:io';
import 'dart:async';
import 'package:finch/console.dart';
import 'package:finch/finch_app.dart';
import 'app.dart' as app;

void main(List<String>? args) {
  app.main(args);
  // Int first conversion on startup
  _modifyLanguages();
  Print.info('✅  Initial language files converted.');
  _modifyWidgets();
  Print.info('✅  Initial widget files converted.');

  ServeManager([
    ServePath(
      path: app.configs.languagePath,
      extensions: ['json'],
      recursive: false,
      onChange: (event) async {
        var res = await _modifyLanguages();
        Print.fatal(
          'MODIFIED 📝: $event\n'
          ' →  language file: ${res.path}',
        );
      },
    ),
    ServePath(
      path: app.configs.widgetsPath,
      extensions: [app.configs.widgetsType],
      recursive: true,
      onChange: (event) async {
        var filePath = await _modifyWidgets();
        Print.info(
          'MODIFIED 📝: $event\n'
          ' →  widgets file: $filePath',
        );
      },
    ),
  ]).watching();
}

Future<String> _modifyWidgets() async {
  var res = WidgetToDart(
    app.configs.widgetsPath,
    fileExtention: app.configs.widgetsType,
  ).generate();
  app.app.debugger?.sendToAll(
    {
      'message': 'Widgets is updated, reload the page to see the changes.',
      'type': 'info'
    },
    path: 'note',
  );
  return res;
}

Future<({Map<String, Map<String, String>> map, String path})>
    _modifyLanguages() async {
  var res = await LanguageToDart(
    app.configs.languagePath,
    fileExtention: '.json',
  ).generate();

  app.configs.dartLanguages = res.map;
  FinchApp.appLanguages = res.map;
  app.app.debugger?.sendToAll(
    {'message': 'Languages is updated, reload the page to see the changes.'},
    path: 'note',
  );
  return res;
}

class ServeManager {
  final List<ServePath> serves;
  final List<String> _watchedPaths = [];

  ServeManager(this.serves);

  void watching() {
    for (var i = 0; i < serves.length; i++) {
      var serve = serves[i];
      if (_watchedPaths.contains(serve.path)) {
        continue;
      }
      _watchedPaths.add(serve.path);
      var directory = Directory(serve.path);
      directory
          .watch(events: FileSystemEvent.all, recursive: true)
          .listen((event) {
        serve.run(event.path);
      });

      if (serve.recursive) {
        directory.listSync().whereType<Directory>().forEach((subDir) {
          serves.add(ServePath(
            path: subDir.path,
            extensions: serve.extensions,
            recursive: serve.recursive,
            onChange: serve.onChange,
          ));
        });
        watching();
      }
    }
  }
}

class ServePath {
  String path;
  List<String> extensions;
  bool recursive;
  Future<void> Function(String path) onChange;
  var doing = false;

  ServePath({
    required this.path,
    required this.extensions,
    required this.onChange,
    this.recursive = true,
  });

  void run(String path) {
    if (extensions.any((ext) => path.endsWith(".$ext"))) {
      if (!doing) {
        onChange(path).then((_) {
          doing = false;
        });
      }
      doing = true;
    }
  }
}
