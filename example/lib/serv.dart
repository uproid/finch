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

  ServManager([
    ServPath(
      path: a.configs.languagePath,
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
    ServPath(
      path: a.configs.widgetsPath,
      extensions: [a.configs.widgetsType],
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
  return WidgetToDart(
    a.configs.widgetsPath,
    fileExtention: a.configs.widgetsType,
  ).generate();
}

Future<({Map<String, Map<String, String>> map, String path})>
    _modifyLanguages() async {
  var res = await LanguageToDart(
    a.configs.languagePath,
    fileExtention: '.json',
  ).generate();

  a.configs.dartLanguages = res.map;
  FinchApp.appLanguages = res.map;

  return res;
}

class ServManager {
  final List<ServPath> servs;
  final List<String> _watchedPaths = [];

  ServManager(this.servs);

  void watching() {
    for (var i = 0; i < servs.length; i++) {
      var serv = servs[i];
      if (_watchedPaths.contains(serv.path)) {
        continue;
      }
      print(serv.path);
      _watchedPaths.add(serv.path);
      var directory = Directory(serv.path);
      directory
          .watch(events: FileSystemEvent.all, recursive: true)
          .listen((event) {
        serv.run(event.path);
      });

      if (serv.recursive) {
        directory.listSync().whereType<Directory>().forEach((subDir) {
          servs.add(ServPath(
            path: subDir.path,
            extensions: serv.extensions,
            recursive: serv.recursive,
            onChange: serv.onChange,
          ));
        });
        watching();
      }
    }
  }
}

class ServPath {
  String path;
  List<String> extensions;
  bool recursive;
  Future<void> Function(String path) onChange;
  var doing = false;

  ServPath({
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
