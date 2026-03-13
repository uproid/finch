import 'package:finch/finch_route.dart';

class TestMiddleware extends Middleware {
  @override
  Future<String?> handle() async {
    rq.addParam('middleware', "Test Middleware Active");
    return null;
  }
}
