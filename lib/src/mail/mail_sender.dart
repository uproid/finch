import 'package:finch/src/tools/console.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

/// A utility class for sending emails using SMTP.
/// The `MailSender` class provides a simple interface for sending emails using
/// the `mailer` package. It allows specifying various email properties and
/// SMTP server configurations, making it easy to send emails programmatically.
class MailSender {
  /// Sends an email using the specified parameters.
  ///
  /// The [sendEmail] method sends an email using the SMTP protocol. It supports
  /// HTML and plain text formats, and allows you to configure various email
  /// properties like sender address, recipients, subject, and more.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// bool success = await MailSender.sendEmail(
  ///   from: 'sender@example.com',
  ///   fromName: 'Sender Name',
  ///   host: 'smtp.example.com',
  ///   port: 587,
  ///   to: ['recipient@example.com'],
  ///   subject: 'Test Email',
  ///   html: '<h1>Hello, World!</h1>',
  ///   text: 'Hello, World!',
  ///   username: 'smtp-username',
  ///   password: 'smtp-password',
  ///   ssl: true,
  ///   allowInsecure: false,
  /// );
  ///
  /// if (success) {
  ///   print('Email sent successfully!');
  /// } else {
  ///   print('Failed to send email.');
  /// }
  /// ```
  ///
  /// Returns `true` if the email is sent successfully, otherwise returns `false`.
  ///
  /// Parameters:
  ///
  /// - [from]: The sender's email address. (required)
  /// - [fromName]: The name displayed as the sender (optional, defaults to an empty string).
  /// - [host]: The SMTP server host (optional, defaults to 'localhost').
  /// - [port]: The SMTP server port (optional, defaults to 1025).
  /// - [to]: A list of recipient email addresses. (required)
  /// - [subject]: The email subject (optional, defaults to an empty string).
  /// - [html]: The email body in HTML format (optional, defaults to an empty string).
  /// - [text]: The email body in plain text format (optional, defaults to an empty string).
  /// - [password]: The SMTP server password (optional).
  /// - [username]: The SMTP server username (optional).
  /// - [ssl]: Whether to use SSL/TLS for the SMTP connection (optional, defaults to `true`).
  /// - [allowInsecure]: Whether to allow insecure connections if SSL is disabled (optional, defaults to `true`).
  ///
  /// Throws a [MailerException] if the email fails to send.
  static Future<bool> sendEmail({
    required String from,
    String fromName = '',
    String host = 'localhost',
    int port = 1025,
    required List<String> to,
    String subject = '',
    String html = '',
    String text = '',
    String? password,
    String? username,
    bool ssl = true,
    bool allowInsecure = true,
  }) async {
    // Set up SMTP server credentials for Mailcatcher.
    final smtpServer = SmtpServer(
      host,
      port: port,
      ssl: ssl,
      allowInsecure: allowInsecure,
      password: password,
      username: username,
    );

    // Create a new email message.
    final message = Message()
      ..from = Address(from, fromName)
      ..recipients = to
      ..subject = subject
      ..text = text
      ..html = html;

    try {
      // Send the email using the SMTP server.
      await send(message, smtpServer);
      return true;
    } catch (e) {
      Console.e('Message not sent: ${e.toString()}');
    }

    return false;
  }
}
