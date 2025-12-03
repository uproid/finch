import 'package:test/test.dart';
import 'package:finch/src/tools/convertor/serializable/datetime_converter.dart';
import 'package:finch/src/tools/convertor/serializable/object_id_converter.dart';
import 'package:finch/src/tools/convertor/serializable/value_converter/json_value.dart';
import 'package:mongo_dart/mongo_dart.dart';

void main() {
  group('DateTimeConverter Tests', () {
    test('fromJson with valid DateTime', () {
      const converter = DateTimeConverter();
      var date = DateTime(2024, 1, 15, 10, 30);

      var result = converter.fromJson(date);
      expect(result, date);
    });

    test('fromJson with null returns default', () {
      const converter = DateTimeConverter();

      var result = converter.fromJson(null);
      expect(result, DateTime.parse('2000-01-01 00:00'));
    });

    test('toJson preserves DateTime', () {
      const converter = DateTimeConverter();
      var date = DateTime(2024, 6, 15, 14, 30, 45);

      var result = converter.toJson(date);
      expect(result, date);
    });

    test('Round-trip conversion', () {
      const converter = DateTimeConverter();
      var original = DateTime.now();

      var json = converter.toJson(original);
      var restored = converter.fromJson(json);

      expect(restored, original);
    });

    test('Default DateTime has expected value', () {
      const converter = DateTimeConverter();
      var defaultDate = converter.fromJson(null);

      expect(defaultDate.year, 2000);
      expect(defaultDate.month, 1);
      expect(defaultDate.day, 1);
      expect(defaultDate.hour, 0);
      expect(defaultDate.minute, 0);
    });
  });

  group('IDConverter (ObjectId) Tests', () {
    test('fromJson with valid ObjectId', () {
      const converter = IDConverter();
      var testId = ObjectId.parse('507f1f77bcf86cd799439011');

      var result = converter.fromJson(testId);
      expect(result, '507f1f77bcf86cd799439011');
    });

    test('fromJson with null returns empty string', () {
      const converter = IDConverter();

      var result = converter.fromJson(null);
      expect(result, '');
    });

    test('toJson with valid string', () {
      const converter = IDConverter();

      var result = converter.toJson('507f1f77bcf86cd799439011');
      expect(result, isNotNull);
      expect(result!.oid, '507f1f77bcf86cd799439011');
    });

    test('toJson with empty string returns null', () {
      const converter = IDConverter();

      var result = converter.toJson('');
      expect(result, isNull);
    });

    test('toJson with invalid string returns null', () {
      const converter = IDConverter();

      var result = converter.toJson('invalid-id');
      expect(result, isNull);
    });

    test('Round-trip conversion', () {
      const converter = IDConverter();
      var originalId = ObjectId();

      var stringId = converter.fromJson(originalId);
      var restored = converter.toJson(stringId);

      expect(restored, isNotNull);
      expect(restored!.oid, originalId.oid);
    });

    test('Multiple ObjectId conversions', () {
      const converter = IDConverter();
      var ids = [
        '507f1f77bcf86cd799439011',
        '507f191e810c19729de860ea',
        '507f191e810c19729de860eb',
      ];

      for (var id in ids) {
        var objectId = converter.toJson(id);
        expect(objectId, isNotNull);
        expect(objectId!.oid, id);

        var stringId = converter.fromJson(objectId);
        expect(stringId, id);
      }
    });
  });

  group('FinchJson Tests', () {
    test('symbolToKey converts symbols to strings', () {
      expect(FinchJson.symbolToKey(#test), '#test');
      expect(FinchJson.symbolToKey(#name), '#name');
      expect(FinchJson.symbolToKey(#value), '#value');
    });

    test('encodeMaps converts Symbol keys to Strings', () {
      var map = {#name: 'John', #age: 30, 'status': 'active'};

      var encoded = FinchJson.encodeMaps(map);

      expect(encoded['#name'], 'John');
      expect(encoded['#age'], 30);
      expect(encoded['status'], 'active');
      expect(encoded[#name], isNull); // Symbol key should be gone
    });

    test('jsonEncoder handles basic types', () {
      var data = {'name': 'Test', 'count': 42, 'active': true};

      var json = FinchJson.jsonEncoder(data);
      expect(json, isNotNull);
      expect(json, contains('name'));
      expect(json, contains('Test'));
      expect(json, contains('42'));
    });

    test('jsonEncoder handles DateTime', () {
      var data = {'created': DateTime(2024, 1, 15)};

      var json = FinchJson.jsonEncoder(data);
      expect(json, contains('2024-01-15'));
    });

    test('jsonEncoder handles ObjectId', () {
      var data = {'_id': ObjectId.parse('507f1f77bcf86cd799439011')};

      var json = FinchJson.jsonEncoder(data);
      expect(json, contains('507f1f77bcf86cd799439011'));
    });

    test('jsonEncoder handles null values', () {
      var data = {'value': null};

      var json = FinchJson.jsonEncoder(data);
      expect(json, contains('null'));
    });

    test('jsonEncoder handles nested maps', () {
      var data = {
        'user': {
          'name': 'John',
          'profile': {'age': 30}
        }
      };

      var json = FinchJson.jsonEncoder(data);
      expect(json, contains('John'));
      expect(json, contains('30'));
    });

    test('jsonEncoder handles lists', () {
      var data = {
        'items': [1, 2, 3],
        'tags': ['a', 'b', 'c']
      };

      var json = FinchJson.jsonEncoder(data);
      expect(json, contains('[1,2,3]'));
      expect(json, contains('["a","b","c"]'));
    });

    test('jsonEncoder handles mixed Symbol and String keys', () {
      var data = {
        #symbolKey: 'value1',
        'stringKey': 'value2',
        #anotherSymbol: 123
      };

      var json = FinchJson.jsonEncoder(data);
      expect(json, contains('symbolKey'));
      expect(json, contains('stringKey'));
      expect(json, contains('value1'));
      expect(json, contains('value2'));
      expect(json, contains('123'));
    });

    test('encodeMaps handles empty map', () {
      var map = {};
      var encoded = FinchJson.encodeMaps(map);

      expect(encoded, {});
    });

    test('encodeMaps preserves string keys', () {
      var map = {
        'key1': 'value1',
        'key2': 'value2',
      };

      var encoded = FinchJson.encodeMaps(map);

      expect(encoded['key1'], 'value1');
      expect(encoded['key2'], 'value2');
    });

    test('symbolToKey handles various symbol formats', () {
      // Basic symbol
      expect(FinchJson.symbolToKey(#simple), '#simple');

      // Symbol with underscores
      expect(FinchJson.symbolToKey(#snake_case), '#snake_case');

      // Symbol with numbers
      expect(FinchJson.symbolToKey(#item123), '#item123');
    });
  });

  group('JSON Encoding Edge Cases', () {
    test('Handle Duration type', () {
      var data = {'duration': Duration(hours: 2, minutes: 30)};

      var json = FinchJson.jsonEncoder(data);
      expect(json, contains('2:30:00'));
    });

    test('Handle integers in encoding', () {
      var data = {'count': 42, 'negative': -10, 'zero': 0};

      var json = FinchJson.jsonEncoder(data);
      expect(json, contains('42'));
      expect(json, contains('-10'));
      expect(json, contains('0'));
    });

    test('Complex nested structure', () {
      var data = {
        'level1': {
          #symbolKey: 'value',
          'level2': {
            'items': [1, 2, 3],
            'metadata': {
              'created': DateTime(2024, 1, 1),
              '_id': ObjectId.parse('507f1f77bcf86cd799439011')
            }
          }
        }
      };

      var json = FinchJson.jsonEncoder(data);
      expect(json, isNotNull);
      expect(json.isNotEmpty, true);
    });

    test('Empty structures', () {
      expect(FinchJson.jsonEncoder({}), '{}');
      expect(FinchJson.jsonEncoder([]), '[]');
      expect(FinchJson.jsonEncoder({'empty': {}}), '{"empty":{}}');
      expect(FinchJson.jsonEncoder({'empty': []}), '{"empty":[]}');
    });
  });
}
