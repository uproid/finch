import 'dart:io';
import 'package:path/path.dart' as p;

extension FinchDirectory on Directory {
  Future<void> copyDirectory(Directory to) async {
    if (!to.existsSync()) {
      to.createSync(recursive: true);
    }

    for (var entity in listSync(recursive: true)) {
      if (entity is Directory) {
      } else if (entity is File) {
        var filePath = p.join(
          to.path,
          p.relative(entity.path, from: path),
        );
        var file = File(filePath);
        if (!file.parent.existsSync()) {
          file.parent.createSync(recursive: true);
        }
        entity.copySync(file.path);
      }
    }
  }

  Future<void> cleanDirectory() async {
    deleteSync(recursive: true);
    createSync(recursive: true);
  }
}
