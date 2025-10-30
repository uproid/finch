import 'package:capp/capp.dart';

class RouteProject {
  Future<CappConsole> route(CappController controller) async {
    var showList = controller.existsOption('list');
    if (showList) {
      return _showList();
    }

    return CappConsole("Route project", CappColors.success);
  }

  Future<CappConsole> _showList() async {
    return CappConsole("List of routes", CappColors.info);
  }
}
