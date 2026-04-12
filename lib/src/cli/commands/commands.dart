import 'dart:convert';
import 'dart:io';
import 'package:capp/capp.dart';
import 'package:finch/model_less.dart';
import 'package:finch/src/db/mysql/mysql_migration.dart';
import 'package:finch/src/tools/convertor/language_to_dart.dart';
import 'package:finch/src/tools/convertor/widget_to_dart.dart';
import 'package:finch/src/tools/extensions/directory.dart';
import 'package:finch/src/tools/path.dart';
import 'package:finch/finch_app.dart';
import 'package:archive/archive_io.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

class ProjectCommands {
  Map<String, dynamic> finchConfigs = {};
  ProjectCommands() {
    var pubspecPath = _findPubspecPath(Directory.current.path);
    var pubspec = _loadPubspec(pubspecPath);
    var finchYaml = pubspec['finch'] as YamlMap?;
    finchConfigs = _reformYamlToMap(finchYaml);
  }

  Future<CappConsole> get(CappController controller) async {
    await Process.start(
        'dart',
        [
          'pub',
          'get',
        ],
        mode: ProcessStartMode.inheritStdio);
    return CappConsole("dart pub get", CappColors.info);
  }

  Future<CappConsole> runner(CappController controller) async {
    await Process.start(
        'dart',
        [
          'run',
          'build_runner',
          'build',
        ],
        mode: ProcessStartMode.inheritStdio);
    return CappConsole('dart run build_runner build', CappColors.none);
  }

  Future<CappConsole> run(
    CappController controller, {
    bool serve = false,
  }) async {
    var path = controller.getOption('path');

    var defaultPath = [
      './bin',
      './lib',
      './src',
      './example/bin',
      './example/lib',
      './example/src',
    ];

    var defaultApp = [
      if (serve) 'serve.dart',
      'app.dart',
      'server.dart',
      'dart.dart',
      'example.dart',
      'run.dart',
      'watcher.dart',
    ];

    if (path.isEmpty) {
      var pubspecPath = _findPubspecPath(Directory.current.path);
      var pubspec = _loadPubspec(pubspecPath);
      if (pubspec.containsKey('finch')) {
        var finchConfig = pubspec['finch'];
        var appPathKey = serve ? 'serve' : 'app';
        if (finchConfig[appPathKey] != null) {
          var appPath = finchConfig[appPathKey];
          if (appPath is String && appPath.isNotEmpty) {
            path = appPath;
          }
        }
      }
    }

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
      path = CappConsole.read("Enter path of app file:", isRequired: true);
      if (!File(path).existsSync()) {
        return run(controller);
      }
    } else {
      print("Running project from: $path");
    }

    path = p.absolute(path);
    List<String> args = controller
        .getOption('args', def: '-v')
        .replaceAll(
          '"',
          '',
        )
        .split(' ')
        .where((element) => element.trim().isNotEmpty)
        .toList();
    List runCommand = ['dart', 'run', "--enable-asserts", path];
    runCommand.addAll(args);

    CappConsole.write(runCommand.last);
    var proccess = await Process.start(
      'dart',
      ['run', "--enable-asserts", path, ...args],
      mode: ProcessStartMode.normal,
      workingDirectory: File(path).parent.parent.path,
    );

    // Forward stdout and stderr to console
    proccess.stdout.listen((data) {
      stdout.add(data);
    });
    proccess.stderr.listen((data) {
      stderr.add(data);
    });

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
              ...args,
            ],
            mode: ProcessStartMode.normal);
        // Forward stdout and stderr to console
        proccess.stdout.listen((data) {
          stdout.add(data);
        });
        proccess.stderr.listen((data) {
          stderr.add(data);
        });
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
        try {
          proccess.stdin.add(input);
        } catch (e) {
          CappConsole.write(
            "Error sending input to process: $e",
            CappColors.error,
          );
        }
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
      environment: {'FINCH_IS_TEST': 'true'},
      mode: ProcessStartMode.inheritStdio,
    );
    return CappConsole("", CappColors.off);
  }

  Future<CappConsole> build(
    CappController controller, {
    bool copyLang = true,
    bool copyWidgets = true,
  }) async {
    bool isCli = controller.existsOption('cli');

    if (controller.existsOption('h')) {
      return controller.manager.writeHelpModern([controller]);
    }

    var path = controller.getOption(
      'appPath',
      def: finchConfigs['path'] ?? './lib/app.dart',
    );
    if (path.isEmpty || !File(path).existsSync()) {
      return CappConsole(
        "The path of main file dart is requirment."
        " for example '--path ./bin/app.dart'",
        CappColors.error,
      );
    }

    var defaultOutputPath = finchConfigs['build_output'] ?? './finch_build';
    var output = controller.getOption('output', def: defaultOutputPath);
    if (output == defaultOutputPath && Directory(output).existsSync()) {
      Directory(output).deleteSync(recursive: true);
    } else if (Directory(output).existsSync()) {
      return CappConsole(
        "The output path is requirment. for example '--output ./finch_build'",
        CappColors.error,
      );
    }
    Directory(output).createSync(recursive: true);

    var publicPath = controller.getOption(
      'publicPath',
      def: finchConfigs['public_path'] ?? './public',
    );

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
    var langPath = controller.getOption(
      'langPath',
      def: finchConfigs['languages_path'] ?? './lib/languages',
    );

    if (copyLang) {
      if (langPath.isNotEmpty && Directory(langPath).existsSync()) {
        var langOutPutPath = joinPaths([output, 'lib/languages']);
        Directory(langOutPutPath).createSync(recursive: true);
        await CappConsole.progress(
          "Copy Language files",
          () => Directory(langPath).copyDirectory(Directory(langOutPutPath)),
          type: CappProgressType.circle,
        );
      }
    } else {
      await LanguageToDart(
        langPath,
        fileExtention: controller.getOption(
          'languages_type',
          def: '.${finchConfigs['languages_type'] ?? 'json'}',
        ),
      ).generate();
    }

    var widgetPath = controller.getOption(
      'widgetPath',
      def: finchConfigs['widgets_path'] ?? './lib/widgets',
    );
    if (copyWidgets) {
      if (widgetPath.isNotEmpty && Directory(widgetPath).existsSync()) {
        var widgetOutPutPath = joinPaths([output, 'lib/widgets']);
        Directory(widgetOutPutPath).createSync(recursive: true);
        await CappConsole.progress(
          "Copy widgets",
          () =>
              Directory(widgetPath).copyDirectory(Directory(widgetOutPutPath)),
          type: CappProgressType.circle,
        );
      }
    } else {
      await WidgetToDart(
        widgetPath,
        fileExtention: '.${finchConfigs['widgets_type'] ?? 'html'}',
      ).generate();
    }

    var envPath = controller.getOption('envPath', def: './.env');
    if (envPath.isNotEmpty && File(envPath).existsSync()) {
      File(envPath).copySync(joinPaths([output, 'lib', '.env']));
    } else {
      var envFile = File(joinPaths([output, 'lib', '.env']));
      envFile.createSync(recursive: true);
      envFile.writeAsStringSync(
        [
          "FINCH_VERSION='${FinchApp.info.version}'",
          "FINCH_BUILD_DATE='${DateTime.now().toUtc()}'",
        ].join('\n'),
      );
    }

    var appPath = joinPaths([output, 'lib', 'app.exe']);
    var commands = <String>[];
    if (isCli) {
      commands = ['build', 'cli', '-t', path, '-o', "$defaultOutputPath/cli"];
    } else {
      commands = ['compile', 'exe', path, '--output', appPath];
    }

    CappConsole.write(
      "> dart ${commands.join(' ')}",
      CappColors.info,
    );
    var procces = await Process.start('dart', commands,
        mode: ProcessStartMode.inheritStdio);

    var result = await CappConsole.progress<int>(
      "Build project",
      () async => await procces.exitCode,
      type: CappProgressType.circle,
    );

    if (result == 0) {
      if (isCli) {
        await Directory('$defaultOutputPath/cli/bundle/bin')
            .copyDirectory(Directory('$defaultOutputPath/lib'));
        await Directory('$defaultOutputPath/cli/bundle/lib')
            .copyDirectory(Directory('$defaultOutputPath/lib/lib'));
        Directory('$defaultOutputPath/cli/').deleteSync(recursive: true);
        File('$defaultOutputPath/lib/app')
            .renameSync('$defaultOutputPath/lib/app.exe');
      }

      var type = controller.getOption('type', def: 'exe');
      if (type == 'zip') {
        await CappConsole.progress("Compress output", () async {
          var encoder = ZipFileEncoder();
          String savePath = joinPaths([
            Directory.systemTemp.path,
            'build_${DateTime.now().millisecondsSinceEpoch}.zip',
          ]);

          encoder.create(savePath);
          await encoder.addDirectory(Directory(output));
          encoder.closeSync();
          await Directory(output).cleanDirectory();
          File(savePath).renameSync(joinPaths([output, 'finch_build.zip']));
        }, type: CappProgressType.circle);
      }
    }

    return CappConsole(
      'Finish build ${result == 0 ? 'OK!' : ''}',
      CappColors.none,
    );
  }

  Future<CappConsole> createMigrateFile(CappController c) async {
    var isSqlite = c.existsOption('sqlite');

    var defaultMigratePath = _pubspec(
      isSqlite ? 'sqlite_migrate/path' : 'mysql_migrate/path',
    );
    var path = c.getOption('path', def: defaultMigratePath);

    if (path.isEmpty) {
      return CappConsole(
        "The path of migration directory is not found."
        " please set it in pubspec.yaml"
        " \n\nfinch:\n\tmysql_migrate:\n\t\tpath: ./migrate\n",
        CappColors.error,
      );
    }

    var name = c.getOption('name', def: '');
    if (name.isEmpty) {
      name = CappConsole.read("Enter migration name:", isRequired: true);
    }
    var res = await CappConsole.progress<String>(
      "Creating migration...",
      () async => MysqlMigration.migrateCreate(
        name: name,
        migrationPath: path,
      ),
    );
    return CappConsole(res);
  }

  String _findPubspecPath(String startPath) {
    var pubspecFile = File(joinPaths([startPath, 'pubspec.yaml']));
    if (pubspecFile.existsSync()) {
      return pubspecFile.path;
    }
    throw Exception('pubspec.yaml not found');
  }

  YamlMap _loadPubspec(String path) {
    var pubspecFile = File(path);
    var content = pubspecFile.readAsStringSync();
    var pubspec = loadYaml(content);
    return pubspec;
  }

  String _pubspec(String path, {String def = ''}) {
    return finchConfigs.navigation<String>(path: path, def: def);
  }

  Map<String, dynamic> _reformYamlToMap(YamlMap? finchYaml) {
    var res = <String, dynamic>{};
    if (finchYaml == null) return res;
    finchYaml.forEach((key, value) {
      if (value is YamlMap) {
        res[key] = _reformYamlToMap(value);
      } else {
        res[key] = value;
      }
    });
    return res;
  }

  Future<CappConsole> getTemplateList(CappController c) async {
    var res = [
      ['#', 'Key', 'Github', 'Description'],
    ];
    var githubUrl = 'https://api.github.com/users/uproid/repos';
    var request = await CappConsole.progress(
      "Fetching templates from GitHub",
      () async => http.get(Uri.parse(githubUrl)),
      type: CappProgressType.timer,
    );

    if (request.statusCode == 200) {
      var repos = jsonDecode(request.body) as List<dynamic>;
      int index = 0;
      for (var repo in repos) {
        var name = repo['name'] as String;
        if (name.contains('-finch-docker')) {
          var description = repo['description'] as String? ?? '';
          var htmlUrl = repo['html_url'] as String;
          res.add([
            (++index).toString(),
            name.replaceAll('-finch-docker', ''),
            htmlUrl,
            '${description.substring(
              0,
              description.length > 20 ? 20 : description.length,
            )}...',
          ]);
        }
      }
    } else {
      return CappConsole(
        "Failed to fetch templates from GitHub. Status code: ${request.statusCode}",
        CappColors.error,
      );
    }
    CappConsole.writeTable(res, color: CappColors.info);
    CappConsole.write(
      "* Use 'finch create --template <key>' to create project with template",
      CappColors.success,
    );
    return CappConsole.empty;
  }
}
