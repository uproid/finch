import 'dart:io';

import 'package:finch/finch_tools.dart';
import 'package:finch/src/tools/extensions/string.dart';

class MakeMiddleware {
  static Future<String> make(String name, String path) async {
    final fileName = '${name.snakeCase()}_middleware.dart';
    final className = '${name.pascalCase()}Middleware';
    final content = '''import 'package:finch/finch_route.dart';

class ${className}Middleware extends Middleware {
  @override
  Future<String?> handle() async {
    rq.addParam('middleware_${name.snakeCase()}', "Test Middleware Active");
    return null;
  }
}
''';
    if (!Directory(path).existsSync()) {
      Directory(path).createSync(recursive: true);
    }
    final file = File(joinPaths([path, fileName]));
    if (file.existsSync()) {
      throw Exception("Middleware already exists at path: ${file.path}");
    }
    await file.writeAsString(content);
    return file.path;
  }
}
