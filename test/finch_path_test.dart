import 'package:test/test.dart';
import 'package:finch/src/tools/path.dart';

void main() {
  group('Finch Route Test', () {
    test('check uri segments', () async {
      var uri =
          Uri.parse('http://localhost:8080/%AF/test?a_%AF=value1&key2=value2');
      expect(uri.safePathSegments, ['�', 'test']);
      expect(uri.safeQueryParameters['a_�'], 'value1');
      expect(uri.safeQueryParameters['key2'], 'value2');
    });
  });
}
