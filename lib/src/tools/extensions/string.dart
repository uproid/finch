import 'package:finch/finch_tools.dart';

extension StringExtension on String {
  String snakeCase() {
    final regex = RegExp(r'(?<=[a-z])[A-Z]');
    return trim()
        .replaceAll(' ', '_')
        .toSlug()
        .replaceAllMapped(regex, (match) => '_${match.group(0)}')
        .toLowerCase();
  }

  String pascalCase() {
    final regex = RegExp(r'(^\w|_\w)');
    return trim().replaceAll(' ', '_').toSlug().replaceAllMapped(
          regex,
          (match) => match.group(0)!.replaceAll('_', '').toUpperCase(),
        );
  }
}
