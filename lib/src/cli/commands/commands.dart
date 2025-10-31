import 'dart:io';

import 'package:capp/capp.dart';
import 'package:finch/src/tools/extensions/directory.dart';
import 'package:finch/src/tools/path.dart';
import 'package:finch/finch_app.dart';
import 'package:archive/archive_io.dart';

class ProjectCommands {
  Future<CappConsole> get(CappController controller) async {
    await Process.start(
      'dart',
      ['pub', 'get'],
      mode: ProcessStartMode.inheritStdio,
    );
    return CappConsole("dart pub get", CappColors.info);
  }

  Future<CappConsole> runner(CappController controller) async {
    await Process.start(
      'dart',
      ['run', 'build_runner', 'build'],
      mode: ProcessStartMode.inheritStdio,
    );
    return CappConsole('dart run build_runner build', CappColors.none);
  }

  Future<CappConsole> run(CappController controller) async {
    var path = controller.getOption('path');
    var defaultPath = [
      './bin',
      './lib',
      './src',
    ];

    var defaultApp = [
      'app.dart',
      'server.dart',
      'dart.dart',
      'example.dart',
      'run.dart',
      'watcher.dart',
    ];

    if (path.isEmpty) {
      for (var p in defaultPath) {
        for (var a in defaultApp) {
          var file = File(joinPaths([p, a]));
          if (file.existsSync()) {
            path = file.path;
            break;
          }
        }
      }
    }
    if (path.isEmpty) {
      path = CappConsole.read(
        "Enter path of app file:",
        isRequired: true,
      );
      if (!File(path).existsSync()) {
        return run(controller);
      }
    } else {
      print("Running project from: $path");
    }

    var proccess = await Process.start(
      'dart',
      [
        'run',
        "--enable-asserts",
        path,
      ],
      mode: ProcessStartMode.inheritStdio,
      workingDirectory: File(path).parent.parent.path,
    );

    var help = "Project is running (${proccess.pid})...\n\n"
        "┌┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬───────────┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┐\n"
        "│││││││││││││││││││││ @> FINCH  │││││││││││││││││││││\n"
        "├┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴───────────┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┤\n"
        "│  * Press 'r' to Reload  the project               │\n"
        "├───────────────────────────────────────────────────┤\n"
        "│  * Press 'c' to clear screen                      │\n"
        "├───────────────────────────────────────────────────┤\n"
        "│  * Press 'i' to write info                        │\n"
        "├───────────────────────────────────────────────────┤\n"
        "│  * Press 'q' to quit the project                  │\n"
        "└───────────────────────────────────────────────────┘\n";

    // Listen for user input in a separate loop
    stdin.listen((input) async {
      String userInput = String.fromCharCodes(input).trim();

      if (userInput.toLowerCase() == 'r') {
        CappConsole.clear();
        CappConsole.write("Restart project...", CappColors.warning);
        proccess.kill();
        proccess = await Process.start(
          'dart',
          [
            'run',
            "--enable-asserts",
            path,
          ],
          mode: ProcessStartMode.inheritStdio,
        );
      } else if (['q', 'qy', 'qq'].contains(userInput.toLowerCase())) {
        var res = true;
        if (userInput.toLowerCase() == 'q') {
          res = CappConsole.yesNo("Do you want to quit the project?");
        }
        if (res) {
          proccess.kill();
          exit(0);
        }
      } else if (userInput.toLowerCase() == 'c') {
        CappConsole.clear();
      } else if (userInput.toLowerCase() == 'i') {
        CappConsole.write("Finch version: v${FinchApp.info.version}");
        CappConsole.write("Dart version: v${Platform.version}");
      } else {
        CappConsole.write(
          "Unknown input: ${userInput.toLowerCase()}",
          CappColors.error,
        );
        CappConsole.write(help, CappColors.success);
      }
    });

    return CappConsole(help, CappColors.success);
  }

  Future<CappConsole> test(CappController controller) async {
    var report = controller.getOption('reporter', def: '');

    await Process.start(
      'dart',
      [
        'test',
        if (report.isNotEmpty) ...['--reporter', report],
      ],
      environment: {
        'FINCH_IS_TEST': 'true',
      },
      mode: ProcessStartMode.inheritStdio,
    );
    return CappConsole("", CappColors.off);
  }

  Future<CappConsole> build(CappController controller) async {
    if (controller.existsOption('h')) {
      var help = controller.manager.getHelp([controller]);
      return CappConsole(help, CappColors.none);
    }

    var path = controller.getOption('appPath', def: './lib/app.dart');
    if (path.isEmpty || !File(path).existsSync()) {
      return CappConsole(
          "The path of main file dart is requirment. for example '--path ./bin/app.dart'",
          CappColors.error);
    }

    var output = controller.getOption('output', def: './finch_build');
    if (output == './finch_build' && Directory(output).existsSync()) {
      Directory(output).deleteSync(recursive: true);
    } else if (Directory(output).existsSync()) {
      return CappConsole(
        "The output path is requirment. for example '--output ./finch_build'",
        CappColors.error,
      );
    }
    Directory(output).createSync(recursive: true);

    var publicPath = controller.getOption('publicPath', def: './public');
    if (publicPath.isNotEmpty && Directory(publicPath).existsSync()) {
      var publicOutPutPath = joinPaths([output, 'public']);
      Directory(publicOutPutPath).createSync(recursive: true);
      await CappConsole.progress(
        "Copy public files",
        () => Directory(publicPath).copyDirectory(Directory(publicOutPutPath)),
        type: CappProgressType.circle,
      );
    }

    Directory('$output/lib').createSync(recursive: true);

    var langPath = controller.getOption('langPath', def: './lib/languages');
    if (langPath.isNotEmpty && Directory(langPath).existsSync()) {
      var langOutPutPath = joinPaths([output, 'lib/languages']);
      Directory(langOutPutPath).createSync(recursive: true);
      await CappConsole.progress(
        "Copy Language files",
        () => Directory(langPath).copyDirectory(Directory(langOutPutPath)),
        type: CappProgressType.circle,
      );
    }

    var widgetPath = controller.getOption('widgetPath', def: './lib/widgets');
    if (widgetPath.isNotEmpty && Directory(widgetPath).existsSync()) {
      var widgetOutPutPath = joinPaths([output, 'lib/widgets']);
      Directory(widgetOutPutPath).createSync(recursive: true);
      await CappConsole.progress(
        "Copy widgets",
        () => Directory(widgetPath).copyDirectory(Directory(widgetOutPutPath)),
        type: CappProgressType.circle,
      );
    }

    var envPath = controller.getOption('envPath', def: './.env');
    if (envPath.isNotEmpty && File(envPath).existsSync()) {
      File(envPath).copySync(joinPaths([output, 'lib', '.env']));
    } else {
      var envFile = File(joinPaths([output, 'lib', '.env']));
      envFile.createSync(recursive: true);
      envFile.writeAsStringSync([
        "FINCH_VERSION='${FinchApp.info.version}'",
        "FINCH_BUILD_DATE='${DateTime.now().toUtc()}'",
      ].join('\n'));
    }

    var appPath = joinPaths([output, 'lib', 'app.exe']);
    var procces = await Process.start(
      'dart',
      ['compile', 'exe', path, '--output', appPath],
      mode: ProcessStartMode.inheritStdio,
    );

    var result = await CappConsole.progress<int>(
      "Build project",
      () async {
        return await procces.exitCode;
      },
      type: CappProgressType.circle,
    );

    if (result == 0) {
      var type = controller.getOption('type', def: 'exe');
      if (type == 'zip') {
        await CappConsole.progress(
          "Compress output",
          () async {
            var encoder = ZipFileEncoder();
            String savePath = joinPaths(
              [
                Directory.systemTemp.path,
                'build_${DateTime.now().millisecondsSinceEpoch}.zip',
              ],
            );

            encoder.create(savePath);
            await encoder.addDirectory(Directory(output));
            encoder.closeSync();
            await Directory(output).cleanDirectory();
            File(savePath).renameSync(joinPaths([
              output,
              'finch_build.zip',
            ]));
          },
          type: CappProgressType.circle,
        );
      }
    }

    return CappConsole(
        'Finish build ${result == 0 ? 'OK!' : ''}', CappColors.none);
  }
}
