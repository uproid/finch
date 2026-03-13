import 'package:finch/route.dart';

abstract class Middleware {
  Request get rq => Context.rq;

  Middleware();

  Future<String?> handle();
}
