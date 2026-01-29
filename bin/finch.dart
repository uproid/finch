import 'package:capp/capp.dart';
import 'package:finch/src/cli/commands/commands.dart';
import 'package:finch/src/cli/commands/create.dart';
import 'package:finch/src/cli/commands/main.dart';

void main(List<String> args) async {
  final cmdManager = CappManager(
    args: args,
    main: CappController(
      '',
      options: [
        CappOption(
          name: 'help',
          description: 'Show the help',
          shortName: 'h',
        ),
        CappOption(
          name: 'version',
          description: 'Finch Version',
          shortName: 'v',
        ),
        CappOption(
          name: 'update',
          description: 'Update Finch',
          shortName: 'u',
        ),
      ],
      run: (controller) => Main().main(controller),
    ),
    controllers: [
      CappController(
        'create',
        description: 'Make new project',
        options: [
          CappOption(
            name: 'path',
            shortName: 'p',
            description: 'Path of the project',
          ),
          CappOption(
            name: 'name',
            shortName: 'n',
            description: 'Name of project',
          ),
          CappOption(
            name: 'docker',
            shortName: 'd',
            description: 'Use docker',
          ),
        ],
        run: (controller) => CreateProject().create(controller),
      ),
      CappController(
        'get',
        description: 'Get pacakges of project, (dart pub get)',
        run: (controller) => ProjectCommands().get(controller),
        options: [],
      ),
      CappController(
        'runner',
        description:
            'Build runner of project, (dart pub run build_runner build)',
        run: (controller) => ProjectCommands().runner(controller),
        options: [],
      ),
      CappController(
        'run',
        description: 'Run project, (dart run)',
        run: (controller) => ProjectCommands().run(controller),
        options: [
          CappOption(
            name: 'path',
            shortName: 'p',
            description: 'Path of app file',
          ),
        ],
      ),
      CappController(
        'serve',
        description: 'Serve project with file watcher',
        run: (controller) => ProjectCommands().run(controller, serve: true),
        options: [
          CappOption(
            name: 'path',
            shortName: 'p',
            description: 'Path of app file',
          ),
        ],
      ),
      CappController(
        'build',
        description: 'Build Project (dart compile exe)',
        run: (controller) => ProjectCommands().build(controller),
        options: [
          CappOption(
            name: 'appPath',
            shortName: 'a',
            description: 'Path of app file',
          ),
          CappOption(
            name: 'langPath',
            shortName: 'l',
            description: 'Languages path',
          ),
          CappOption(
            name: 'publicPath',
            shortName: 'p',
            description: 'Public path',
          ),
          CappOption(
            name: 'widgetPath',
            shortName: 'w',
            description: 'Widgets path',
          ),
          CappOption(
            name: 'envPath',
            shortName: 'e',
            description: 'Envitoment file (.env) path',
          ),
          CappOption(
            name: 'output',
            shortName: 'o',
            description: 'Output path',
            value: './finch_build',
          ),
          CappOption(
            name: 'type',
            shortName: 't',
            description: 'Type of build (zip, exe)',
          ),
          CappOption(
            name: 'help',
            shortName: 'h',
            description: 'Show the help',
          ),
        ],
      ),
      CappController(
        'test',
        description: 'Unit test of project, (dart test)',
        run: (controller) => ProjectCommands().test(controller),
        options: [
          CappOption(
            name: 'reporter',
            shortName: 'r',
            description: 'Set how to print test results',
          ),
        ],
      ),
    ],
  );

  cmdManager.process();
}
