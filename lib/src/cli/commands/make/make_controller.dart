import 'dart:io';

import 'package:finch/finch_tools.dart';
import 'package:finch/src/tools/extensions/string.dart';

class MakeController {
  static Future<String> make(String name, String path) async {
    final fileName = '${name.snakeCase()}_controller.dart';
    final className = '${name.pascalCase()}Controller';
    final content = '''import 'package:finch/route.dart';
       
class $className extends Controller {
  @override
  Future<String> index() async {
    return rq.renderString(text: 'Hello from $className');
  }
}
''';
    if (!Directory(path).existsSync()) {
      Directory(path).createSync(recursive: true);
    }
    final file = File(joinPaths([path, fileName]));
    if (file.existsSync()) {
      throw Exception("Controller already exists at path: ${file.path}");
    }
    await file.writeAsString(content);
    return file.path;
  }
}
