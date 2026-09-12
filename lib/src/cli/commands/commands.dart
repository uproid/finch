import 'dart:convert';
import 'dart:io';
import 'package:capp/capp.dart';
import 'package:finch/model_less.dart';
import 'package:finch/src/cli/commands/make/make_controller.dart';
import 'package:finch/src/cli/commands/make/make_middleware.dart';
import 'package:finch/src/cli/commands/make/make_service.dart';
import 'package:finch/src/db/mysql/mysql_migration.dart';
import 'package:finch/src/tools/convertor/language_to_dart.dart';
import 'package:finch/src/tools/convertor/widget_to_dart.dart';
import 'package:finch/src/tools/extensions/directory.dart';
import 'package:finch/src/tools/path.dart';
import 'package:finch/finch_app.dart';
import 'package:archive/archive_io.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as p;
import 'package:finch/src/tools/http/http.dart';

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
    List<String> serveCommands = [
      // Bind address defaults to localhost, which is unreachable from
      // outside a Docker container even when the port is published — bind
      // to 0.0.0.0 so the debugger's DevTools panel can reach it.
      '--enable-vm-service=8181/0.0.0.0',
      '--disable-service-auth-codes'
    ];
    var runCommand = <String>[
      'dart',
      'run',
      "--enable-asserts",
      if (serve) ...serveCommands,
      path,
    ];
    runCommand.addAll(args);

    // Terminal WebSocket: streams the running app's stdout/stderr to any
    // connected client and lets a client send text back in as if it had
    // been typed at this same prompt (handled by handleLine, wired below).
    HttpServer? terminalServer;
    final terminalClients = <WebSocket>{};
    Future<void> Function(String)? onTerminalCommand;

    void broadcastTerminal(String message) {
      for (var ws in terminalClients.toList()) {
        try {
          ws.add(message);
        } catch (_) {
          terminalClients.remove(ws);
        }
      }
    }

    if (serve) {
      var terminalPort =
          int.tryParse(controller.getOption('terminalPort', def: '8282')) ??
              8282;
      terminalServer = await HttpServer.bind(
        InternetAddress.anyIPv4,
        terminalPort,
      );
      terminalServer.listen((HttpRequest request) async {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          var socket = await WebSocketTransformer.upgrade(request);
          terminalClients.add(socket);
          socket.listen(
            (message) async {
              if (message is String && message.trim().isNotEmpty) {
                await onTerminalCommand?.call(message.trim());
              }
            },
            onDone: () => terminalClients.remove(socket),
            onError: (_) => terminalClients.remove(socket),
          );
        } else {
          request.response.statusCode = HttpStatus.forbidden;
          await request.response.close();
        }
      });
      CappConsole.write(
        "Finch terminal WebSocket listening on ws://localhost:${terminalServer.port}",
        CappColors.info,
      );
    }

    CappConsole.write(runCommand.join(' '), CappColors.info);
    var proccess = await Process.start(
      'dart',
      runCommand.sublist(1),
      mode: ProcessStartMode.normal,
      workingDirectory: File(path).parent.parent.path,
      environment: {
        if (terminalServer != null)
          'FINCH_TERMINAL_PORT': terminalServer.port.toString(),
      },
    );

    // Forward stdout and stderr to console
    proccess.stdout.listen((data) {
      stdout.add(data);
      broadcastTerminal(utf8.decode(data, allowMalformed: true));
    });
    proccess.stderr.listen((data) {
      stderr.add(data);
      broadcastTerminal(utf8.decode(data, allowMalformed: true));
    });

    var help = "Project is running (${proccess.pid})...\n\n"
        "┌┬┬┬┬┬┬┬┬┬┬┬──────────────┬┬┬┬┬┬┬┬┬┬┬┬┐\n"
        "││││││││││││ @> Finch CLI │││││││││││││\n"
        "├┴┴┴┴┴┴┴┴┴┴┴──────────────┴┴┴┴┴┴┴┴┴┴┴┴┤\n"
        "│ * Press 'r' to Reload  the project  │\n"
        "│ * Press 'c' to clear screen         │\n"
        "│ * Press 'i' to write info           │\n"
        "│ * Press 'h' to show history         │\n"
        "│ * Press 'q' to quit the project     │\n"
        "└─────────────────────────────────────┘\n"
        "${terminalServer != null ? "\nTerminal WebSocket: ws://localhost:${terminalServer.port}\n" : ''}";

    // Read raw keystrokes ourselves (no OS line-buffering, no OS echo). This
    // is what lets us drop arrow-key escape sequences before they ever reach
    // the screen, while still building up a line the same way the shell
    // would, so 'r'/'c'/'i'/'q' only trigger on a complete line typed by
    // itself (not merely typed as the first letter of a longer command)
    // and anything else is forwarded to the child process whole, on Enter.
    final hasTerminal = stdin.hasTerminal;

    void setRawMode(bool raw) {
      if (!hasTerminal) return;
      stdin.echoMode = !raw;
      stdin.lineMode = !raw;
    }

    setRawMode(true);

    var currentLine = '';
    // Index into currentLine the next typed/deleted character applies at.
    var cursorPos = 0;
    final commandHistory = <String>[];
    // Index into commandHistory that Up/Down currently point at.
    // == commandHistory.length means "not browsing history" (a fresh line).
    var historyIndex = 0;

    void redrawLine() {
      if (!hasTerminal) return;
      stdout.write('\r\x1B[K$currentLine');
      var moveLeft = currentLine.length - cursorPos;
      if (moveLeft > 0) stdout.write('\x1B[${moveLeft}D');
    }

    Future<void> handleLine(String userInput) async {
      userInput = userInput.trim();

      if (userInput.isNotEmpty &&
          (commandHistory.isEmpty || commandHistory.last != userInput)) {
        commandHistory.add(userInput);
      }
      historyIndex = commandHistory.length;

      if (userInput.toLowerCase() == 'r') {
        CappConsole.clear();
        commandHistory.clear();
        historyIndex = 0;
        CappConsole.write("Restart project...", CappColors.warning);
        proccess.kill();
        proccess = await Process.start(
          'dart',
          runCommand.sublist(1),
          mode: ProcessStartMode.normal,
          workingDirectory: File(path).parent.parent.path,
          environment: {
            if (terminalServer != null)
              'FINCH_TERMINAL_PORT': terminalServer.port.toString(),
          },
        );
        // Forward stdout and stderr to console
        proccess.stdout.listen((data) {
          stdout.add(data);
          broadcastTerminal(utf8.decode(data, allowMalformed: true));
        });
        proccess.stderr.listen((data) {
          stderr.add(data);
          broadcastTerminal(utf8.decode(data, allowMalformed: true));
        });
      } else if (['q', 'qy', 'qq'].contains(userInput.toLowerCase())) {
        var res = true;
        if (userInput.toLowerCase() == 'q') {
          // yesNo() reads its own line, so give the terminal back its normal
          // echo/line-editing behavior for the duration of the prompt.
          setRawMode(false);
          res = CappConsole.yesNo("Do you want to quit the project?");
          if (!res) setRawMode(true);
        }
        if (res) {
          setRawMode(false);
          proccess.kill();
          exit(0);
        }
      } else if (userInput.toLowerCase() == 'c') {
        CappConsole.clear();
      } else if (userInput.toLowerCase() == 'i') {
        CappConsole.write("Finch version: v${FinchApp.info.version}");
        CappConsole.write("Dart version: v${Platform.version}");
      } else if (userInput.toLowerCase() == 'h') {
        CappConsole.writeTable(
          [
            ['Command History'],
            ...commandHistory.map((e) => [e]),
          ],
          color: CappColors.info,
        );
      } else if (userInput.isNotEmpty) {
        try {
          proccess.stdin.writeln(userInput);
        } catch (e) {
          CappConsole.write(
            "Error sending input to process: $e",
            CappColors.error,
          );
        }
      }
    }

    // Let websocket terminal clients send commands the same way keystrokes do.
    onTerminalCommand = handleLine;

    // Listen for user input in a separate loop
    stdin.listen((input) async {
      // Arrow keys (and other special keys) are sent as an escape sequence:
      // ESC '[' <letter>. Up/Down browse command history; anything else
      // in that family is dropped silently instead of being echoed as
      // literal garbage or forwarded raw.
      if (input.isNotEmpty && input.first == 0x1B) {
        if (input.length >= 3 && input[1] == 0x5B) {
          if (input[2] == 0x41 && historyIndex > 0) {
            // Arrow Up
            historyIndex--;
            currentLine = commandHistory[historyIndex];
            cursorPos = currentLine.length;
            redrawLine();
          } else if (input[2] == 0x42) {
            // Arrow Down
            if (historyIndex < commandHistory.length - 1) {
              historyIndex++;
              currentLine = commandHistory[historyIndex];
            } else {
              historyIndex = commandHistory.length;
              currentLine = '';
            }
            cursorPos = currentLine.length;
            redrawLine();
          } else if (input[2] == 0x44) {
            // Arrow Left: move the cursor within the current line.
            if (cursorPos > 0) {
              cursorPos--;
              stdout.write('\x1B[D');
            }
          } else if (input[2] == 0x43) {
            // Arrow Right: move the cursor within the current line.
            if (cursorPos < currentLine.length) {
              cursorPos++;
              stdout.write('\x1B[C');
            }
          } else if (input.length >= 4 &&
              input[2] == 0x33 &&
              input[3] == 0x7E) {
            // Delete (ESC [ 3 ~): remove the character under the cursor,
            // same as Backspace but on the other side of it.
            if (cursorPos < currentLine.length) {
              currentLine = currentLine.substring(0, cursorPos) +
                  currentLine.substring(cursorPos + 1);
              redrawLine();
            }
          }
        }
        return;
      }

      for (var byte in input) {
        if (byte == 0x0D || byte == 0x0A) {
          // Enter: finish the line and dispatch it.
          if (hasTerminal) stdout.writeln();
          var line = currentLine;
          currentLine = '';
          cursorPos = 0;
          await handleLine(line);
        } else if (byte == 0x7F || byte == 0x08) {
          // Backspace: drop the character just before the cursor, if any.
          if (cursorPos > 0) {
            currentLine = currentLine.substring(0, cursorPos - 1) +
                currentLine.substring(cursorPos);
            cursorPos--;
            redrawLine();
          }
        } else {
          // Insert the typed character at the cursor position.
          currentLine = currentLine.substring(0, cursorPos) +
              String.fromCharCode(byte) +
              currentLine.substring(cursorPos);
          cursorPos++;
          redrawLine();
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
    var type = _pubspec(
      isSqlite ? 'sqlite_migrate/type' : 'mysql_migrate/type',
      def: 'sql',
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
        type: type,
        isSqlite: isSqlite,
      ),
      type: CappProgressType.circle,
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

  static Future<CappConsole> getTemplateList(CappController c) async {
    var res = [
      ['#', 'Key', 'Github Link', 'Description'],
    ];
    var githubUrl = 'https://api.github.com/users/uproid/repos';
    var request = await CappConsole.progress(
      "Fetching templates from GitHub",
      () async => FinchHttp.get(Uri.parse(githubUrl)),
      type: CappProgressType.timer,
    );

    if (request.status == 200) {
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
            htmlUrl.split('//').last,
            '${description.substring(
              0,
              description.length > 25 ? 25 : description.length,
            )}...',
          ]);
        }
      }
    } else {
      return CappConsole(
        "Failed to fetch templates from GitHub. Status code: ${request.status}",
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

  Future<CappConsole> makeController(CappController c) async {
    var name = c.getOption('name', def: '');
    var path = c.getOption('path', def: './lib/controllers');

    if (c.getOption('path').isNotEmpty) {
      path = c.getOption('path');
    }

    if (name.isEmpty) {
      name = CappConsole.read("Enter controller name:", isRequired: true);
    }
    var res = await CappConsole.progress<String>(
      "Creating controller...",
      () async => MakeController.make(name, path),
      type: CappProgressType.circle,
    );
    return CappConsole(res, CappColors.success);
  }

  Future<CappConsole> makeService(CappController c) async {
    var name = c.getOption('name', def: '');
    var path = c.getOption('path', def: './lib/services');

    if (c.getOption('path').isNotEmpty) {
      path = c.getOption('path');
    }

    if (name.isEmpty) {
      name = CappConsole.read("Enter service name:", isRequired: true);
    }
    var res = await CappConsole.progress<String>(
      "Creating service...",
      () async => MakeService.make(name, path),
      type: CappProgressType.circle,
    );
    return CappConsole(res, CappColors.success);
  }

  Future<CappConsole> makeMiddleware(CappController c) async {
    var name = c.getOption('name', def: '');
    var path = c.getOption('path', def: './lib/middleware');

    if (c.getOption('path').isNotEmpty) {
      path = c.getOption('path');
    }

    if (name.isEmpty) {
      name = CappConsole.read("Enter middleware name:", isRequired: true);
    }
    var res = await CappConsole.progress<String>(
      "Creating middleware...",
      () async => MakeMiddleware.make(name, path),
      type: CappProgressType.circle,
    );
    return CappConsole(res, CappColors.success);
  }
}
