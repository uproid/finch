import 'package:capp/capp.dart';
import 'package:finch/src/cli/commands/commands.dart';
import 'package:finch/src/cli/commands/create.dart';
import 'package:finch/src/cli/commands/main.dart';

void main(List<String> args) async {
  final helpOption = CappOption(
    name: 'help',
    shortName: 'h',
    hideInHelp: true,
    onSelect: (c) {
      c.writeHelp();
      return false;
    },
  );

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
      run: (c) => Main().main(c),
    ),
    controllers: [
      CappController(
        'templates',
        options: [helpOption],
        description: 'Show the list of available templates',
        run: (c) => ProjectCommands.getTemplateList(c),
      ),
      CappController(
        'create',
        description: 'Make new project',
        options: [
          helpOption,
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
          CappOption(
            name: 'template',
            shortName: 't',
            description: 'Project template [simple, example,...]',
            value: 'simple',
          ),
        ],
        run: (c) => CreateProject().create(c),
      ),
      CappController(
        'get',
        description: 'Get packages of project, (dart pub get)',
        run: (c) => ProjectCommands().get(c),
        options: [helpOption],
      ),
      CappController(
        'runner',
        description:
            'Build runner of project, (dart pub run build_runner build)',
        run: (c) => ProjectCommands().runner(c),
        options: [helpOption],
      ),
      CappController(
        'run',
        description: 'Run project, (dart run)',
        run: (c) => ProjectCommands().run(c),
        options: [
          helpOption,
          CappOption(
            name: 'path',
            shortName: 'p',
            description: 'Path of app file',
          ),
          CappOption(
            name: 'args',
            shortName: 'a',
            description: 'Arguments for app file',
          ),
        ],
      ),
      CappController(
        'serve',
        description: 'Serve project with file watcher',
        run: (c) => ProjectCommands().run(c, serve: true),
        options: [
          helpOption,
          CappOption(
            name: 'path',
            shortName: 'p',
            description: 'Path of app file',
          ),
          CappOption(
            name: 'args',
            shortName: 'a',
            description: 'Arguments for app file',
          ),
        ],
      ),
      CappController(
        'build',
        description: 'Build Project (dart compile exe)',
        run: (c) => ProjectCommands().build(c),
        options: [
          helpOption,
          CappOption(
            name: 'cli',
            shortName: 'c',
            description: 'Build for cli',
          ),
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
          ),
          CappOption(
            name: 'type',
            shortName: 't',
            description: 'Type of build (zip, exe)',
          ),
        ],
      ),
      CappController(
        'migrate',
        description: 'Migrate project to new version of Finch',
        options: [
          helpOption,
          CappOption(
            name: 'create',
            shortName: 'c',
            description: 'Create new project and move files',
          ),
          CappOption(
            name: 'name',
            shortName: 'n',
            description: 'Name of migration file (only for create option)',
          ),
          CappOption(
            name: 'sqlite',
            shortName: 's',
            description: 'Migrate SQLite files',
          ),
        ],
        run: (c) async {
          if (c.existsOption('create')) {
            return await ProjectCommands().createMigrateFile(c);
          }
          return CappConsole.empty;
        },
      ),
      CappController(
        'test',
        description: 'Unit test of project, (dart test)',
        run: (c) => ProjectCommands().test(c),
        options: [
          helpOption,
          CappOption(
            name: 'reporter',
            shortName: 'r',
            description: 'Set how to print test results',
          ),
        ],
      ),
      CappController(
        'make:controller',
        description: 'Make new controller',
        run: (c) => ProjectCommands().makeController(c),
        options: [
          helpOption,
          CappOption(
            name: 'name',
            shortName: 'n',
            description: 'Name of controller',
          ),
          CappOption(
            name: 'path',
            shortName: 'p',
            description: 'Path of controller (default: ./lib/controllers/)',
          ),
        ],
      ),
      CappController(
        'make:service',
        description: 'Make new service',
        run: (c) => ProjectCommands().makeService(c),
        options: [
          helpOption,
          CappOption(
            name: 'name',
            shortName: 'n',
            description: 'Name of service',
          ),
          CappOption(
            name: 'path',
            shortName: 'p',
            description: 'Path of service (default: ./lib/services/)',
          ),
        ],
      ),
      CappController(
        'make:middleware',
        description: 'Make new middleware',
        run: (c) => ProjectCommands().makeMiddleware(c),
        options: [
          helpOption,
          CappOption(
            name: 'name',
            shortName: 'n',
            description: 'Name of middleware',
          ),
          CappOption(
            name: 'path',
            shortName: 'p',
            description: 'Path of middleware (default: ./lib/middleware/)',
          ),
        ],
      ),
    ],
  );

  cmdManager.process();
}
