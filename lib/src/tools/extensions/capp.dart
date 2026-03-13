import 'dart:io';

import 'package:finch/capp.dart';

extension CManager on CappManager {
  static void _print(String text, [CappColors color = CappColors.none]) {
    switch (color) {
      case CappColors.warning:
        print('\x1B[33m$text\x1B[0m');
      case CappColors.error:
        print('\x1B[31m$text\x1B[0m');
      case CappColors.success:
        print('\x1B[32m$text\x1B[0m');
      case CappColors.info:
        print('\x1B[36m$text\x1B[0m');
      default:
        print(text);
    }
  }

  void _printin(String text, [CappColors color = CappColors.none]) {
    switch (color) {
      case CappColors.warning:
        stdout.write('\x1B[33m$text\x1B[0m');
      case CappColors.error:
        stdout.write('\x1B[31m$text\x1B[0m');
      case CappColors.success:
        stdout.write('\x1B[32m$text\x1B[0m');
      case CappColors.info:
        stdout.write('\x1B[36m$text\x1B[0m');
      default:
        stdout.write(text);
    }
  }

  CappConsole writeHelpModern([List<CappController>? myControllers]) {
    var selectedControllers = myControllers ?? [...controllers, main];

    var maxNameLen = 0;
    for (var controller in selectedControllers) {
      for (var option in controller.options) {
        if (option.name.length > maxNameLen) {
          maxNameLen = option.name.length;
        }
      }
    }

    for (var controller in selectedControllers) {
      if (controller.name.isNotEmpty) {
        _print("\x1B[1m✔ ${controller.name}\x1B[22m", CappColors.success);
        if (controller.description.isNotEmpty) {
          _print("\t${controller.description}", CappColors.warning);
        }
      } else {
        _print(controller.description, CappColors.info);
      }
      for (var option in controller.options) {
        var nameCol = '--${option.name}'.padRight(maxNameLen + 2);
        _print("\t-${option.shortName}, $nameCol ${option.description}");
      }
    }

    return CappConsole('');
  }
}
