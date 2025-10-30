import 'dart:async';
import '../render/request.dart';

class Context {
  static const String _requestKey = 'wa_request_context';

  static Request get rq {
    final context = Zone.current[_requestKey];
    if (context == null) {
      throw StateError('No Request found in current zone. '
          'This method can only be called within a request context.');
    }
    return context as Request;
  }

  static bool get hasCurrent {
    return Zone.current[_requestKey] != null;
  }

  static T run<T>(Request request, T Function() body) {
    return runZoned(
      body,
      zoneValues: {
        _requestKey: request,
      },
    );
  }

  static void runVoid(Request request, void Function() body) {
    runZoned(
      body,
      zoneValues: {
        _requestKey: request,
      },
    );
  }
}
