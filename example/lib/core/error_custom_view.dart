import 'package:finch/htmler.dart';
import 'package:finch/ui.dart';

class ErrorCustomView extends FinchStringWidget {
  @override
  Tag Function(Map<dynamic, dynamic> args)? get generateHtml => (args) {
        var statusCode = args['status'] ?? 404;
        if (statusCode != 404) {
          return ErrorWidget().generateHtml!.call(args);
        }

        return $Cache(
          children: [
            $JinjaInclude('errors/404.j2.html'),
          ],
        );
      };
}
