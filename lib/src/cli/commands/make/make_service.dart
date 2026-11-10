import 'dart:io';

import 'package:finch/finch_tools.dart';
import 'package:finch/src/tools/extensions/string.dart';

class MakeService {
  static Future<String> make(String name, String path) async {
    final fileName = '${name.snakeCase()}_service.dart';
    final className = '${name.pascalCase()}Service';
    final content = '''import 'package:finch/route.dart';
       
class $className extends FinchService {
  $className() {
    // TODO: You can initialize your service here
  }
}
''';
    if (!Directory(path).existsSync()) {
      Directory(path).createSync(recursive: true);
    }
    final file = File(joinPaths([path, fileName]));
    if (file.existsSync()) {
      throw Exception("Service already exists at path: ${file.path}");
    }
    await file.writeAsString(content);
    return file.path;
  }
}
