import 'dart:io';

import 'package:capp/capp.dart';
import 'package:finch/src/finch_app.dart';

class Main {
  Future<CappConsole> main(CappController controller) async {
    if (controller.existsOption('version')) {
      return CappConsole(
        "Finch Version: v${FinchApp.info.version}\n"
        "Dart Version: v${Platform.version}",
      );
    }

    if (controller.existsOption('update')) {
      await Process.start(
        'dart',
        ['pub', 'global', 'activate', 'finch'],
        mode: ProcessStartMode.inheritStdio,
      );
      return CappConsole("Update Finch");
    }

    return CappConsole(
      controller.manager.getHelp(),
      controller.existsOption('help') ? CappColors.none : CappColors.warning,
    );
  }
}
