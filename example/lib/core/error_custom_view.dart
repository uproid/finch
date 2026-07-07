import 'package:finch/finch_app.dart';
import 'package:finch/finch_console.dart';
import 'package:finch/finch_mail.dart';
import 'package:finch/htmler.dart';
import 'package:finch/route.dart';
import 'package:finch/ui.dart';

class ErrorCustomView extends FinchStringWidget {
  @override
  Tag Function(Map<dynamic, dynamic> args)? get generateHtml => (args) {
        var statusCode = args['status'] ?? 404;
        if (statusCode != 404) {
          if (Console.isNotDebug) {
            _sendEmail(statusCode, args);
          }
          return ErrorWidget().generateHtml!.call(args);
        }

        return $Cache(
          children: [
            $JinjaInclude('errors/404.j2.html'),
          ],
        );
      };

  Future<void> _sendEmail(int statusCode, Map<dynamic, dynamic> args) async {
    var to = [env['DEBUG_EMAIL_TO'] ?? ''];
    if (to.isEmpty) return;

    args.addAll(<String, dynamic>{
      'url': Context.rq.uri.toString(),
      'method': Context.rq.method,
      'headers': Context.rq.headers,
      'data': Context.rq.getAllData(),
      'route': Context.rq.route?.toDetails(),
      'ip': Context.rq.getIP(),
    });

    MailSender.sendEmail(
      from: env['DEBUG_EMAIL_FROM'] ?? '',
      to: to,
      allowInsecure: true,
      subject: 'Finch-Example Error: $statusCode',
      fromName: env['DEBUG_EMAIL_FROM_NAME'] ?? 'Finch Example',
      host: env['DEBUG_EMAIL_HOST'] ?? '',
      port: int.tryParse(env['DEBUG_EMAIL_PORT'] ?? '587') ?? 587,
      html: _mapToHtml(args),
      password: env['DEBUG_EMAIL_PASSWORD'] ?? '',
      ssl: env['DEBUG_EMAIL_SSL']?.toLowerCase() == 'true' ? true : false,
      username: env['DEBUG_EMAIL_USERNAME'] ?? '',
    );
  }

  String _mapToHtml(Map args) {
    var res = "";
    for (var key in args.keys) {
      var arg = args[key];
      res += "<b>$key</b>: ";
      if (arg is List) {
        res += "${arg.join(', ')}<hr>";
      } else if (arg is Map) {
        res += _mapToHtml(arg);
      } else {
        res += "${arg.toString()}<hr>";
      }
    }
    return res;
  }
}
