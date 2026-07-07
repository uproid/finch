import 'package:finch/finch_app.dart';
import 'package:finch/finch_console.dart';
import 'package:finch/finch_mail.dart';
import 'package:finch/htmler.dart';
import 'package:finch/tools.dart';
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

    MailSender.sendEmail(
      from: env['DEBUG_EMAIL_FROM'] ?? '',
      to: to,
      allowInsecure: true,
      subject: 'Finch-Example Error: $statusCode',
      fromName: env['DEBUG_EMAIL_FROM_NAME'] ?? 'Finch Example',
      host: env['DEBUG_EMAIL_HOST'] ?? '',
      port: int.tryParse(env['DEBUG_EMAIL_PORT'] ?? '587') ?? 587,
      html: args.joinMap("<hr/>", " : "),
      password: env['DEBUG_EMAIL_PASSWORD'] ?? '',
      ssl: env['DEBUG_EMAIL_SSL']?.toLowerCase() == 'true' ? true : false,
      username: env['DEBUG_EMAIL_USERNAME'] ?? '',
    );
  }
}
