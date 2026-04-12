import 'package:finch/capp.dart';

extension CManager on CappManager {
  Future<CappConsole> writeHelp([
    List<CappController>? extraControllers,
  ]) async {
    return writeHelpModern(extraControllers);
  }
}
