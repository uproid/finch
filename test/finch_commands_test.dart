import 'dart:io';

import 'package:finch/app.dart';
import 'package:test/test.dart';

void main() {
  group('Finch Commands Test', () {
    test('Finch help command runs without error', () async {
      final result = await Process.run(
        'dart',
        ['run', 'bin/finch.dart', 'help'],
        workingDirectory: Directory.current.path,
      );

      expect(result.exitCode, equals(0),
          reason: 'Command should exit with code 0');

      expect(result.stdout.toString(), isNotEmpty,
          reason: 'Help output should not be empty');
    }, timeout: const Timeout(Duration(minutes: 1)));

    test('Finch version command runs without error', () async {
      final result = await Process.run(
        'dart',
        ['run', 'bin/finch.dart', '--version'],
        workingDirectory: Directory.current.path,
      );

      expect(
        result.stdout.toString(),
        contains('Finch Version: v${FinchApp.info.version}'),
        reason: 'Version command info should be correct',
      );
    }, timeout: const Timeout(Duration(minutes: 1)));
  });
}
