import 'dart:io';
import 'package:finch/finch_app.dart';
import 'package:finch/finch_tools.dart';

class WidgetToDart {
  String path;
  String fileExtention;
  WidgetToDart(this.path, {this.fileExtention = '.jinja'});

  Future<String> generate() async {
    var result = await _readPaths(path);

    File file = File(joinPaths([path, 'template_dart.g.dart']));
    await file.writeAsString(
      "var mapTemplates = ${result.dart};",
      flush: true,
    );
    if (FinchApp.config.jinjaMapTemplate != null) {
      FinchApp.config.jinjaMapTemplate = result.map;
    }
    return file.path;
  }

  /// Read nested paths and return a map of file paths to their contents.
  Future<({String dart, Map<String, String> map})> _readPaths(
      String path) async {
    List<String> result = [];
    Map<String, String> map = {};
    var dir = Directory(path);
    await for (var entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith(fileExtention)) {
        var content = await entity.readAsString();
        var relatedPath = entity.path.substring(path.length + 1);
        relatedPath = pathNorm(
          relatedPath,
          normSlashs: true,
          endWithSlash: false,
        );
        result.add('\tr"$relatedPath": r"""$content"""');
        map[relatedPath] = content;
      }
    }
    return (dart: "{\n${result.join(",\n")}\n}", map: map);
  }
}
