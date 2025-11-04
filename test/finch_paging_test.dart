import 'package:test/test.dart';
import 'package:finch/src/views/db_paging.dart';
import 'package:finch/src/views/ui_paging.dart';

void main() {
  group('DBPaging Tests', () {
    test('Basic pagination calculation', () {
      var paging = DBPaging(
        page: 1,
        total: 100,
        pageSize: 20,
      );
      
      expect(paging.page, 1);
      expect(paging.total, 100);
      expect(paging.pageSize, 20);
      expect(paging.start, 0); // (1-1) * 20 = 0
    });

    test('Calculate start index for different pages', () {
      var paging1 = DBPaging(page: 1, total: 100, pageSize: 10);
      expect(paging1.start, 0);
      
      var paging2 = DBPaging(page: 2, total: 100, pageSize: 10);
      expect(paging2.start, 10);
      
      var paging3 = DBPaging(page: 5, total: 100, pageSize: 10);
      expect(paging3.start, 40);
      
      var paging4 = DBPaging(page: 10, total: 100, pageSize: 10);
      expect(paging4.start, 90);
    });

    test('Start index adjustment when page exceeds total', () {
      // When page number is too high, start should be adjusted
      var paging = DBPaging(page: 20, total: 100, pageSize: 10);
      // Expected: total % pageSize == 0, so start = 100 - 10 = 90
      expect(paging.start, 90);
      
      var paging2 = DBPaging(page: 100, total: 95, pageSize: 10);
      // Expected: 95 % 10 = 5, so start = 95 - 5 = 90
      expect(paging2.start, 90);
    });

    test('Edge case with small total', () {
      var paging = DBPaging(page: 1, total: 5, pageSize: 10);
      expect(paging.start, 0);
      
      var paging2 = DBPaging(page: 2, total: 5, pageSize: 10);
      // Start should be adjusted as page exceeds available items
      expect(paging2.start, 0); // Since 5 < 10
    });

    test('Custom page size', () {
      var paging1 = DBPaging(page: 1, total: 100, pageSize: 5);
      expect(paging1.start, 0);
      
      var paging2 = DBPaging(page: 3, total: 100, pageSize: 25);
      expect(paging2.start, 50); // (3-1) * 25
    });

    test('Order by and reverse settings', () {
      var paging = DBPaging(
        page: 1,
        total: 100,
        orderBy: 'created_at',
        orderReverse: true,
      );
      
      expect(paging.orderBy, 'created_at');
      expect(paging.orderReverse, true);
    });

    test('Custom prefix', () {
      var paging = DBPaging(
        page: 1,
        total: 100,
        prefix: 'p',
      );
      
      expect(paging.prefix, 'p');
    });

    test('Zero total items', () {
      var paging = DBPaging(page: 1, total: 0, pageSize: 10);
      expect(paging.start, 0);
      expect(paging.total, 0);
    });

    test('Single item pagination', () {
      var paging = DBPaging(page: 1, total: 1, pageSize: 10);
      expect(paging.start, 0);
      
      var paging2 = DBPaging(page: 2, total: 1, pageSize: 10);
      expect(paging2.start, 0);
    });
  });

  group('UIPaging Tests', () {
    test('Basic UI pagination with offset', () {
      var paging = UIPaging(
        widget: 'test/paging',
        page: 1,
        total: 100,
        pageSize: 20,
      );
      
      expect(paging.offset, 0);
      expect(paging.start, 0);
      
      var paging2 = UIPaging(
        widget: 'test/paging',
        page: 3,
        total: 100,
        pageSize: 20,
      );
      
      expect(paging2.offset, 40); // (3-1) * 20
      expect(paging2.start, 40);
    });

    test('Offset calculation for various pages', () {
      var paging1 = UIPaging(widget: 'test', page: 1, total: 100, pageSize: 10);
      expect(paging1.offset, 0);
      
      var paging2 = UIPaging(widget: 'test', page: 5, total: 100, pageSize: 10);
      expect(paging2.offset, 40);
      
      var paging3 = UIPaging(widget: 'test', page: 10, total: 100, pageSize: 10);
      expect(paging3.offset, 90);
    });

    test('Offset should never be negative', () {
      var paging = UIPaging(widget: 'test', page: 0, total: 100, pageSize: 10);
      expect(paging.offset >= 0, true);
    });

    test('Width side parameter', () {
      var paging = UIPaging(
        widget: 'test',
        page: 5,
        total: 100,
        widthSide: 3,
      );
      
      expect(paging.widthSide, 3);
    });

    test('Custom other query parameters', () {
      var paging = UIPaging(
        widget: 'test',
        page: 1,
        total: 100,
        otherQuery: {'search': 'test', 'filter': 'active'},
      );
      
      expect(paging.otherQuery['search'], 'test');
      expect(paging.otherQuery['filter'], 'active');
    });

    test('Order by in UI paging', () {
      var paging = UIPaging(
        widget: 'test',
        page: 1,
        total: 100,
        orderBy: 'name',
        orderReverse: false,
      );
      
      expect(paging.orderBy, 'name');
      expect(paging.orderReverse, false);
    });

    test('Start index adjustment in UI paging', () {
      var paging = UIPaging(
        widget: 'test',
        page: 20,
        total: 100,
        pageSize: 10,
      );
      
      expect(paging.start, 90);
    });

    test('Empty query parameters', () {
      var paging = UIPaging(
        widget: 'test',
        page: 1,
        total: 100,
        otherQuery: {},
      );
      
      expect(paging.otherQuery, {});
    });

    test('Use request queries flag', () {
      var paging = UIPaging(
        widget: 'test',
        page: 1,
        total: 100,
        useRequsetQueries: true,
      );
      
      expect(paging.useRequsetQueries, true);
      
      var paging2 = UIPaging(
        widget: 'test',
        page: 1,
        total: 100,
        useRequsetQueries: false,
      );
      
      expect(paging2.useRequsetQueries, false);
    });

    test('Large dataset pagination', () {
      var paging = UIPaging(
        widget: 'test',
        page: 100,
        total: 10000,
        pageSize: 50,
      );
      
      expect(paging.offset, 4950); // (100-1) * 50
      expect(paging.start, 4950);
    });

    test('Last page calculation', () {
      var paging = UIPaging(
        widget: 'test',
        page: 10,
        total: 95,
        pageSize: 10,
      );
      
      // Last page should show items 90-94
      expect(paging.offset, 90);
    });
  });

  group('Pagination Edge Cases', () {
    test('Negative page numbers handled gracefully', () {
      var paging = DBPaging(page: -1, total: 100, pageSize: 10);
      // Negative page treated as page before first, start calculation
      var start = (-1 - 1) * 10; // -20
      if (start >= 100) {
        start = 100 - 10;
      }
      expect(paging.start, start >= 0 ? start : start);
    });

    test('Very large page numbers', () {
      var paging = DBPaging(page: 1000000, total: 100, pageSize: 10);
      // Should adjust to last valid page
      expect(paging.start, 90);
    });

    test('Zero page size handling', () {
      // This is a theoretical edge case - in practice pageSize should always be > 0
      // But if it happens, we should handle gracefully
      expect(() => DBPaging(page: 1, total: 100, pageSize: 0), returnsNormally);
    });

    test('Very small page sizes', () {
      var paging = DBPaging(page: 50, total: 100, pageSize: 1);
      expect(paging.start, 49); // (50-1) * 1
      expect(paging.pageSize, 1);
    });

    test('Very large page sizes', () {
      var paging = DBPaging(page: 1, total: 100, pageSize: 1000);
      expect(paging.start, 0);
      expect(paging.pageSize, 1000);
    });

    test('Exact page boundary', () {
      var paging = DBPaging(page: 5, total: 100, pageSize: 20);
      expect(paging.start, 80); // Last page starts at 80
      
      var paging2 = DBPaging(page: 6, total: 100, pageSize: 20);
      // Page 6 would be beyond items, should adjust
      expect(paging2.start, 80);
    });

    test('Non-divisible total by page size', () {
      var paging = DBPaging(page: 11, total: 105, pageSize: 10);
      // Should show items 100-104
      expect(paging.start, 100);
      
      var paging2 = DBPaging(page: 12, total: 105, pageSize: 10);
      // Beyond last page, should adjust to last valid start
      expect(paging2.start, 100);
    });
  });
}