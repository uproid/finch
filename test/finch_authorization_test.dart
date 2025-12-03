import 'package:finch/route.dart';
import 'package:test/test.dart';

void main() {
  group('Test Authorization', () {
    test('Check Authorization Bearer Token', () {
      Authorization.parse('Bearer mysecrettoken');
      var auth = Authorization.parse('Bearer mysecrettoken');
      expect(auth.type, AuthType.bearer);
      expect(auth.value, 'mysecrettoken');
    });

    test('Check Authorization Basic Auth', () {
      var auth = Authorization.parse('Basic dXNlcjpwYXNzd29yZA==');
      expect(auth.type, AuthType.basic);
      expect(auth.value, 'user:password');
      expect(auth.getBasicUsername(), 'user');
      expect(auth.getBasicPassword(), 'password');
    });

    test('Check Authorization None', () {
      var auth = Authorization.parse('NoAuth somevalue');
      expect(auth.type, AuthType.none);
      expect(auth.value, '');
    });

    test('Check Authorization Empty', () {
      var auth = Authorization.parse('');
      expect(auth.type, AuthType.none);
      expect(auth.value, '');
    });

    test('Check Authorization Bearer Token', () {
      var auth = Authorization.parse('Bearer ');
      expect(auth.type, AuthType.bearer);
      expect(auth.value, '');
    });

    test('Check Authorization Bearer Token', () {
      var auth = Authorization.parse('Basic ');
      expect(auth.type, AuthType.basic);
      expect(auth.value, '');
    });

    test('Check Authorization Bearer Token', () {
      var auth = Authorization.parse('Basic invalidbase64');
      expect(auth.type, AuthType.basic);
      expect(auth.value, '');
    });

    test('Check Authorization Bearer Token', () {
      var auth = Authorization.parse('Basic dXNlcg==');
      expect(auth.type, AuthType.basic);
      expect(auth.value, 'user');
      expect(auth.getBasicUsername(), '');
      expect(auth.getBasicPassword(), '');
    });

    test('Check Authorization Bearer Token', () {
      var auth = Authorization.parse('Basic');
      expect(auth.type, AuthType.none);
      expect(auth.value, '');
      expect(auth.getBasicUsername(), '');
      expect(auth.getBasicPassword(), '');
    });
  });
}
