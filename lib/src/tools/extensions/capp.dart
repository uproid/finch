import 'package:finch/capp.dart';

extension CManager on CappManager {
  CappConsole writeHelpModern([List<CappController>? myControllers]) {
    var selectedControllers = myControllers ?? [...controllers, main];
    for (var controller in selectedControllers) {
      if (controller.name.isNotEmpty) {
        CappConsole.write("√ ${controller.name}", CappColors.success);
        if (controller.description.isNotEmpty) {
          CappConsole.write(
            "   \t${controller.description}",
            CappColors.warning,
          );
        }
      } else {
        CappConsole.write(controller.description, CappColors.info);
      }
      for (var option in controller.options) {
        CappConsole.write(
          "\t--${option.shortName}\t${option.description}",
          CappColors.none,
        );
      }
    }

    return CappConsole.write("");
  }
}
