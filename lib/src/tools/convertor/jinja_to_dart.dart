import 'dart:io';
import 'package:finch/finch_tools.dart';

class JinjaToDart {
  String path;
  String fileExtention;
  JinjaToDart(this.path, {this.fileExtention = '.jinja'});

  Future<String> generate() async {
    String result = await _readPaths(path);

    File file = File(joinPaths([path, 'jinja_dart.g.dart']));
    await file.writeAsString(
      "var jinjaTemplates = $result;",
      flush: true,
    );
    return file.path;
  }

  /// Read nested paths and return a map of file paths to their contents.
  Future<String> _readPaths(String path) async {
    List<String> result = [];
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
      }
    }
    return "{\n${result.join(",\n")}\n}";
  }
}
