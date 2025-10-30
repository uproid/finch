import 'dart:io';
import 'package:capp/capp.dart';
import 'package:finch/finch_tools.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive_io.dart';

class CreateProject {
  String projectUrl =
      'https://github.com/uproid/example-finch-docker/archive/refs/heads/master.zip';
  String savePath =
      '${Directory.systemTemp.path}/template_${DateTime.timestamp().microsecondsSinceEpoch}.zip';

  Future<CappConsole> create(CappController controller) async {
    var result = CappConsole("Error in creating project", CappColors.error);
    var name = controller.getOption('name');
    var isDocker = controller.existsOption('docker');
    var useDocker = false;

    if (!isDocker) {
      useDocker = CappConsole.yesNo("Do you want to use docker?");
    } else {
      useDocker = true;
    }

    if (name.isEmpty) {
      name = CappConsole.read(
        "Enter project name:",
        isRequired: true,
        isSlug: true,
      );
    }

    var path = controller.getOption('path', def: name);
    path = Uri.parse(path).toFilePath(windows: Platform.isWindows);

    CappConsole.write(path, CappColors.success);
    if (Directory(path).existsSync()) {
      return CappConsole("This path already exists! ($path)", CappColors.error);
    }

    Directory(path).createSync(recursive: true);
    if (!Directory(path).existsSync()) {
      return CappConsole("Error creating this path: $path", CappColors.error);
    }

    String pathZip = await CappConsole.progress<String>(
      "Waitng...",
      () async {
        return downloadFile(projectUrl, savePath);
      },
      type: CappProgressType.circle,
    );

    if (pathZip.isNotEmpty) {
      var dirPrject = await extract(path);
      if (dirPrject.isNotEmpty) {
        await updatePacakge(
          dirPrject,
          name: name,
          useDocker: useDocker,
        );
        result = CappConsole(
            "Project created successfully: $dirPrject", CappColors.success);
      }
    }

    return result;
  }

  Future<String> downloadFile(String url, String savePath) async {
    try {
      // Make the HTTP GET request
      final response = await http.get(Uri.parse(url));

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Create a file object
        final file = File(savePath);

        // Write the response body to the file
        await file.writeAsBytes(response.bodyBytes);

        return savePath;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  Future<String> extract(String dir) async {
    try {
      final bytes = File(savePath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          var newPath =
              filename.replaceFirst('example-finch-docker-master', '');
          File(joinPaths([dir, newPath]))
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory(joinPaths([dir, filename])).createSync(recursive: true);
        }
      }

      Directory(joinPaths([dir, 'example-finch-docker-master'])).deleteSync(
        recursive: true,
      );
      return dir;
    } catch (e) {
      return "";
    }
  }

  Future updatePacakge(
    String filePath, {
    required String name,
    required bool useDocker,
  }) async {
    final file = File(joinPaths([filePath, 'pubspec.yaml']));
    var pubspec = await file.readAsString();
    pubspec = pubspec.replaceFirst('name: example', 'name: $name');
    file.writeAsStringSync(pubspec, mode: FileMode.write);

    if (!useDocker) {
      final dockerFile = File(joinPaths([filePath, 'Dockerfile']));
      dockerFile.deleteSync();

      final dockerIgnore = File(joinPaths([filePath, '.dockerignore']));
      dockerIgnore.deleteSync();

      final dockerCompose = File(joinPaths([filePath, 'docker-compose.yaml']));
      dockerCompose.deleteSync();
    }
  }
}
