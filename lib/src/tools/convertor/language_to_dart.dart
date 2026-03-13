import 'dart:convert';
import 'dart:io';
import 'package:finch/finch_tools.dart';

class LanguageToDart {
  String path;
  String fileExtention;
  LanguageToDart(this.path, {this.fileExtention = '.json'});

  Future<({String path, Map<String, Map<String, String>> map})>
      generate() async {
    var result = await _readPaths(path);

    File file = File(joinPaths([path, 'language_dart.g.dart']));
    await file.writeAsString(
      "var languageDart = ${result.dart};",
      flush: true,
    );

    return (path: file.path, map: result.map);
  }

  /// Read nested paths and return a map of file paths to their contents.
  Future<({String dart, Map<String, Map<String, String>> map})> _readPaths(
      String path) async {
    String result = "";
    Map<String, Map<String, String>> map = {};
    var dir = Directory(path);
    await for (var entity in dir.list()) {
      if (entity is File &&
          entity.path.endsWith(fileExtention) &&
          entity.existsSync()) {
        var content = await entity.readAsString();
        var relatedPath = entity.path.substring(path.length + 1);
        relatedPath = pathNorm(
          relatedPath,
          normSlashs: true,
          endWithSlash: false,
        );
        var langMap = FinchJson.jsonDecoder(content);
        if (langMap != null) {
          var languageName = entity.fileName;
          map[languageName] = {};
          result += '\t"$languageName": ';
          result += jsonEncode(langMap);
          map[languageName] = Map<String, String>.from(langMap
              .map((key, value) => MapEntry(key.toString(), value.toString())));
          result += ',\n';
        }
      }
    }
    return (dart: "{\n $result \n}", map: map);
  }
}
