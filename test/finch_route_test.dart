import 'package:finch/finch_route.dart';
import 'package:test/test.dart';

void main() {
  group('Finch Route Test', () {
    test('Test1', () async {
      final route = FinchRoute(
        path: '/test',
        children: [
          FinchRoute(path: '/child1'),
          FinchRoute(path: '/child2'),
        ],
        hosts: ['example.com', 'api.example.com'],
        methods: ['GET', 'POST'],
        key: 'route1',
        index: () async {
          return 'Index Handler';
        },
        ports: [8080, 9090],
        permissions: ['read', 'write'],
        excludePaths: ['/exclude1', '/exclude2'],
        extraPath: ['/extra1', '/extra2'],
      );
      for (var method in ['GET', 'POST']) {
        var map = route.toMap('/parent/', false, method);

        // /test
        expect(map[0]['fullPath'], '/parent/test/');
        expect(map[0]['method'], method);
        expect(map[0]['hosts'], ['example.com', 'api.example.com']);
        expect(map[0]['ports'], [8080, 9090]);
        expect(map[0]['permissions'], ['read', 'write']);

        // /extra1
        expect(map[1]['fullPath'], '/parent/extra1/');
        expect(map[1]['method'], method);
        expect(map[1]['hosts'], ['example.com', 'api.example.com']);
        expect(map[1]['ports'], [8080, 9090]);
        expect(map[1]['permissions'], ['read', 'write']);

        // /extra2
        expect(map[2]['fullPath'], '/parent/extra2/');
        expect(map[2]['method'], method);
        expect(map[2]['hosts'], ['example.com', 'api.example.com']);
        expect(map[2]['ports'], [8080, 9090]);
        expect(map[2]['permissions'], ['read', 'write']);
      }
    });
  });
}
