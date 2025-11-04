import 'package:finch/finch_model.dart';
import 'package:test/test.dart';
import 'package:finch/finch_tools.dart';
import 'package:finch/finch_model_less.dart';
import 'package:mongo_dart/mongo_dart.dart';

void main() {
  group('String Validator Extended Tests', () {
    test('Email validation - comprehensive edge cases', () {
      // Valid emails
      expect('simple@example.com'.isEmail, true);
      expect('user.name@example.com'.isEmail, true);
      expect('user+tag@example.com'.isEmail, true);
      expect('user_name@example.co.uk'.isEmail, true);
      expect('123@example.com'.isEmail, true);
      expect('a@b.c'.isEmail, true);

      // Invalid emails
      expect(''.isEmail, false);
      expect('@example.com'.isEmail, false);
      expect('user@'.isEmail, false);
      expect('user'.isEmail, false);
      expect('user@domain'.isEmail, false);
      expect('user name@example.com'.isEmail, false);
      expect('user@exam ple.com'.isEmail, false);
      expect('user@@example.com'.isEmail, false);
      expect('user@example..com'.isEmail, false);
    });

    test('Password validation - comprehensive edge cases', () {
      // Valid passwords
      expect('@Test123'.isPassword, true);
      expect('P@ssw0rd'.isPassword, true);
      expect('Abcd123!'.isPassword, true);
      expect('!@#\$%^&*Aa1'.isPassword, true);
      expect('MyP@ssw0rd123'.isPassword, true);

      // Invalid passwords
      expect(''.isPassword, false);
      expect('short1!'.isPassword, false); // too short
      expect('NoDigits!'.isPassword, false); // no numbers
      expect('nospecial123'.isPassword, false); // no special chars
      expect('12345678!'.isPassword, false); // no letters
      expect('UPPERCASE123!'.isPassword, true); // has all requirements
      expect('lowercase123!'.isPassword, true); // has all requirements
      expect('OnlyLetters'.isPassword, false); // no special char or digit
      expect('OnlyLettersAndNumbers123'.isPassword, false); // no special char
    });

    test('toBool conversion - comprehensive cases', () {
      expect('true'.toBool, true);
      expect('TRUE'.toBool, true);
      expect('True'.toBool, true);
      expect('TrUe'.toBool, true);
      expect('1'.toBool, true);
      expect('  1  '.toBool, true);
      expect('  true  '.toBool, true);

      expect('false'.toBool, false);
      expect('FALSE'.toBool, false);
      expect('0'.toBool, false);
      expect(''.toBool, false);
      expect('no'.toBool, false);
      expect('yes'.toBool, false);
      expect('2'.toBool, false);
      expect('anything'.toBool, false);
    });
  });

  group('ConvertString Extended Tests', () {
    test('MD5 hashing', () {
      expect(''.toMd5(), 'd41d8cd98f00b204e9800998ecf8427e');
      expect('test'.toMd5(), '098f6bcd4621d373cade4e832627b4f6');
      expect('The quick brown fox'.toMd5(), 'a2004f37730b9445670a738fa0fc9ee5');
    });

    test('Base64 encoding/decoding roundtrip', () {
      var testStrings = [
        '',
        'a',
        'test',
        'Hello World!',
        'Special chars: @#\$%^&*()',
        '日本語',
        'Émojis: 😀🎉',
      ];

      for (var str in testStrings) {
        var encoded = str.toBase64();
        var decoded = encoded.fromBase64();
        expect(decoded, str, reason: 'Failed roundtrip for: $str');
      }
    });

    test('Base64 decode with default value', () {
      expect('invalid!@#'.fromBase64(def: 'default'), 'default');
      expect(''.fromBase64(def: 'empty'), '');
    });

    test('Base32 encoding/decoding roundtrip', () {
      var testStrings = [
        'test',
        'uproid',
        'Hello World',
        'ABC123',
      ];

      for (var str in testStrings) {
        var encoded = str.toBase32();
        var decoded = encoded.fromBase32();
        expect(decoded, str, reason: 'Failed roundtrip for: $str');
      }
    });

    test('Base32 decode with default value', () {
      expect('invalid!@#'.fromBase32(def: 'default'), 'default');
      expect(''.fromBase32(def: 'empty'), '');
    });

    test('toSlug comprehensive cases', () {
      expect('Hello World'.toSlug(), 'hello-world');
      expect('  Hello   World  '.toSlug(), 'hello-world');
      expect('Test-Slug'.toSlug(), 'test-slug');
      expect('Special@#Chars!'.toSlug(), 'specialchars');
      expect('Numbers123'.toSlug(), 'numbers123');
      expect('Multiple   Spaces'.toSlug(), 'multiple-spaces');
      expect('CamelCase'.toSlug(), 'camelcase');
      expect('snake_case'.toSlug(), 'snakecase');
      expect('kebab-case'.toSlug(), 'kebab-case');
      expect('Mixed_Style-Test'.toSlug(), 'mixedstyle-test');
      expect(''.toSlug(), '');
    });

    test('isSlug validation', () {
      expect('valid-slug'.isSlug(), true);
      expect('validslug'.isSlug(), true);
      expect('valid-slug-123'.isSlug(), true);
      expect('123-456'.isSlug(), true);

      expect('Invalid Slug'.isSlug(), false);
      expect('Invalid_Slug'.isSlug(), false);
      expect('Invalid@Slug'.isSlug(), false);
      expect('UPPERCASE'.isSlug(), false);
      expect('Has Space'.isSlug(), false);
    });

    test('ObjectId conversion', () {
      var validId = '507f1f77bcf86cd799439011';
      var oid = validId.oID;
      expect(oid, isNotNull);
      expect(oid!.oid, validId);

      expect('invalid'.oID, isNull);
      expect(''.oID, isNull);
      expect('  '.oID, isNull);
    });
  });

  group('SafeString Extended Tests', () {
    test('removeHtmlTags comprehensive cases', () {
      expect('ssss<p>Hello</p>'.removeHtmlTags(), 'ssssHello');
      expect('vvv<div><span>Nested</span></div>sss'.removeHtmlTags(),
          'vvvNestedsss');
      expect('a<p>Multiple <b>tags</b> here</p>b'.removeHtmlTags(),
          'aMultiple tags hereb');
      expect('No tags'.removeHtmlTags(), 'No tags');
      expect(''.removeHtmlTags(), '');

      // With custom replacement
      expect('<p>Hello</p>'.removeHtmlTags(replace: ' '), ' Hello ');
      expect('<p>A</p><p>B</p>'.removeHtmlTags(replace: '|'), '|A||B|');
    });

    test('removeScripts comprehensive cases', () {
      expect('<script>alert("xss")</script>'.removeScripts(), '');
      expect('<div>Safe</div><script>bad()</script>'.removeScripts(),
          '<div>Safe</div>');
      expect('<div onclick="alert()">Click</div>'.removeScripts(),
          '<div>Click</div>');
      expect('<button onload="evil()">Button</button>'.removeScripts(),
          '<button>Button</button>');
      expect(
          '<a onmouseover="steal()">Link</a>'.removeScripts(), '<a>Link</a>');
      expect(
          'No scripts here onclick'.removeScripts(), 'No scripts here onclick');
      expect(''.removeScripts(), '');
    });

    test('HTML escape/unescape', () {
      expect('<div>'.escape(), '&lt;div&gt;');
      expect('&lt;div&gt;'.unescape(), '<div>');
      expect('"quotes"'.escape(), '&quot;quotes&quot;');
      expect('&quot;quotes&quot;'.unescape(), '"quotes"');
      expect("'single'".escape(), '&#39;single&#39;');

      // Roundtrip
      var html = '<p>Hello & "World"</p>';
      expect(html.escape().unescape(), html);
    });

    test('Encryption/decryption roundtrip', () {
      var passwords = ['pass', 'password', 'a-very-long-password-key-here'];
      var texts = [' ', 'test', 'Hello World', 'Special: @#\$%'];

      for (var password in passwords) {
        for (var text in texts) {
          var encrypted = text.toSafe(password);
          var decrypted = encrypted.fromSafe(password);
          expect(decrypted, text,
              reason: 'Failed roundtrip with password: $password, text: $text');
        }
      }
    });

    test('Encryption with different password lengths', () {
      var text = 'Secret Message';

      // Short password (padded to 32)
      var short = text.toSafe('key');
      expect(short.fromSafe('key'), text);

      // Exact 32 chars
      var exact = text.toSafe('12345678901234567890123456789012');
      expect(exact.fromSafe('12345678901234567890123456789012'), text);

      // Long password (truncated to 32)
      var long = text
          .toSafe('this-is-a-very-long-password-that-exceeds-32-characters');
      expect(
          long.fromSafe(
              'this-is-a-very-long-password-that-exceeds-32-characters'),
          text);
    });

    test('Decryption with wrong password', () {
      var encrypted = 'test'.toSafe('correct');
      var decrypted = encrypted.fromSafe('wrong');
      expect(decrypted, isNot('test'));
    });
  });

  group('QueryString Extended Tests', () {
    test('Simple key-value pairs', () {
      expect(QueryString.parse('a=1&b=2&c=3'), {'a': '1', 'b': '2', 'c': '3'});
      expect(QueryString.parse('key=value'), {'key': 'value'});
      expect(QueryString.parse(''), {});
    });

    test('URL encoded values', () {
      expect(QueryString.parse('name=John%20Doe'), {'name': 'John Doe'});
      expect(QueryString.parse('email=user%40example.com'),
          {'email': 'user@example.com'});
      expect(QueryString.parse('message=Hello%2C%20World%21'),
          {'message': 'Hello, World!'});
    });

    test('Array notation', () {
      expect(QueryString.parse('tags[]=a&tags[]=b&tags[]=c'), {
        'tags': ['a', 'b', 'c']
      });
      expect(QueryString.parse('items[]=1'), {
        'items': ['1']
      });
      expect(QueryString.parse('empty[]='), {
        'empty': ['']
      });
    });

    test('Mixed arrays and regular values', () {
      var result = QueryString.parse(
          'name=John&hobbies[]=reading&hobbies[]=gaming&age=30');
      expect(result['name'], 'John');
      expect(result['hobbies'], ['reading', 'gaming']);
      expect(result['age'], '30');
    });

    test('Empty values', () {
      expect(QueryString.parse('a=&b=2'), {'a': '', 'b': '2'});
      expect(QueryString.parse('empty='), {'empty': ''});
    });

    test('Keys without values', () {
      expect(QueryString.parse('flag'), {'flag': ''});
      expect(QueryString.parse('a&b&c'), {'a': '', 'b': '', 'c': ''});
    });

    test('Special characters in keys', () {
      expect(QueryString.parse('my-key=value'), {'my-key': 'value'});
      expect(QueryString.parse('my_key=value'), {'my_key': 'value'});
    });

    test('Edge cases', () {
      expect(QueryString.parse('=value'), {});
      expect(QueryString.parse('&&&'), {});
      expect(QueryString.parse('a=1&'), {'a': '1'});
      expect(QueryString.parse('&a=1'), {'a': '1'});
    });
  });

  group('ConvertSize Extended Tests', () {
    test('Bytes', () {
      expect(ConvertSize.toLogicSizeString(0), '0 B');
      expect(ConvertSize.toLogicSizeString(1), '1 B');
      expect(ConvertSize.toLogicSizeString(512), '512 B');
      expect(ConvertSize.toLogicSizeString(1023), '1023 B');
    });

    test('Kilobytes', () {
      expect(ConvertSize.toLogicSizeString(1024), '1.00 KB');
      expect(ConvertSize.toLogicSizeString(1536), '1.50 KB');
      expect(ConvertSize.toLogicSizeString(10240), '10.00 KB');
      expect(ConvertSize.toLogicSizeString(1048569), '1023.99 KB');
    });

    test('Megabytes', () {
      expect(ConvertSize.toLogicSizeString(1048576), '1.00 MB');
      expect(ConvertSize.toLogicSizeString(5242880), '5.00 MB');
      expect(ConvertSize.toLogicSizeString(1024 * 1024 * 10), '10.00 MB');
      expect(ConvertSize.toLogicSizeString(1024 * 1024 * 1024 - 10000),
          '1023.99 MB');
    });

    test('Gigabytes', () {
      expect(ConvertSize.toLogicSizeString(1073741824), '1.00 GB');
      expect(ConvertSize.toLogicSizeString(5368709120), '5.00 GB');
      expect(ConvertSize.toLogicSizeString(10737418240), '10.00 GB');
    });

    test('Edge cases with specific values', () {
      expect(ConvertSize.toLogicSizeString(1500), '1.46 KB');
      expect(ConvertSize.toLogicSizeString(1500000), '1.43 MB');
      expect(ConvertSize.toLogicSizeString(1500000000), '1.40 GB');
    });
  });

  group('MapTools Extended Tests', () {
    test('removeAll with various scenarios', () {
      var map = {'a': 1, 'b': 2, 'c': 3, 'd': 4};
      map.removeAll(['a', 'c']);
      expect(map, {'b': 2, 'd': 4});

      map.removeAll(['b']);
      expect(map, {'d': 4});

      map.removeAll(['x', 'y']); // Non-existent keys
      expect(map, {'d': 4});

      map.removeAll([]);
      expect(map, {'d': 4});
    });

    test('select with various scenarios', () {
      var map = {'a': 1, 'b': 2, 'c': 3, 'd': 4};

      var selected = map.select(['a', 'c']);
      expect(selected, {'a': 1, 'c': 3});
      expect(map, {'a': 1, 'b': 2, 'c': 3, 'd': 4}); // Original unchanged

      selected = map.select([]);
      expect(selected, {});

      selected = map.select(['x', 'y']); // Non-existent keys
      expect(selected, {});

      selected = map.select(['a', 'b', 'c', 'd']);
      expect(selected, map);
    });

    test('add method', () {
      var map = {'a': 1};
      map.add(MapEntry('b', 2));
      expect(map, {'a': 1, 'b': 2});

      map.add(MapEntry('a', 10)); // Overwrite
      expect(map, {'a': 10, 'b': 2});
    });

    test('joinMap with various separators', () {
      var map = {'a': 1, 'b': 2, 'c': 3};
      expect(map.joinMap(':', ','), 'a:1,b:2,c:3');
      expect(map.joinMap('=', '&'), 'a=1&b=2&c=3');
      expect(map.joinMap(' -> ', ' | '), 'a -> 1 | b -> 2 | c -> 3');

      expect({}.joinMap(':', ','), '');
      expect({'a': 1}.joinMap(':', ','), 'a:1');
    });
  });

  group('ModelLess Extended Tests', () {
    test('Deep nested access', () {
      var model = ModelLess.fromJson('''{
        "level1": {
          "level2": {
            "level3": {
              "value": 42
            }
          }
        }
      }''');

      expect(model.get<int>('level1/level2/level3/value'), 42);
    });

    test('Array access in nested structures', () {
      var model = ModelLess.fromJson('''{
        "users": [
          {"name": "Alice", "age": 30},
          {"name": "Bob", "age": 25},
          {"name": "Charlie", "age": 35}
        ]
      }''');

      expect(model.get<String>('users/0/name'), 'Alice');
      expect(model.get<int>('users/1/age'), 25);
      expect(model.get<String>('users/2/name'), 'Charlie');
    });

    test('Mixed nested arrays and objects', () {
      var model = ModelLess.fromJson('''{
        "data": {
          "items": [
            {"id": 1, "tags": ["a", "b"]},
            {"id": 2, "tags": ["c", "d"]}
          ]
        }
      }''');

      expect(model.get<int>('data/items/0/id'), 1);
      expect(model.get<String>('data/items/0/tags/0'), 'a');
      expect(model.get<String>('data/items/1/tags/1'), 'd');
    });

    test('Default values for missing paths', () {
      var model = ModelLess.fromJson('{"a": 1}');

      expect(model.get<int>('nonexistent', def: -1), -1);
      expect(model.get<String>('missing', def: 'default'), 'default');
      expect(model.get<bool>('nothere', def: true), false);
    });

    test('Type conversions', () {
      var model = ModelLess.fromJson('''{
        "stringNum": "123",
        "boolStr": "true",
        "intValue": 456
      }''');

      expect(model.get<int>('stringNum'), 123);
      expect(model.get<String>('intValue'), '456');
    });

    test('Setting and getting values', () {
      var model = ModelLess();
      model['name'] = 'John';
      model['age'] = 30;

      expect(model['name'], 'John');
      expect(model.get<int>('age'), 30);
    });

    test('Removing values', () {
      var model = ModelLess.fromJson('{"a": 1, "b": 2}');
      model.remove('a');

      expect(model['a'], ''); // Returns empty string for missing keys
      expect(model['b'], 2);
    });
  });

  group('ModelLessArray Extended Tests', () {
    test('Basic operations', () {
      var array = ModelLessArray<int>();
      expect(array.isEmpty, true);
      expect(array.length, 0);

      array.set(1);
      array.set(2);
      array.set(3);

      expect(array.isEmpty, false);
      expect(array.isNotEmpty, true);
      expect(array.length, 3);
      expect(array[0], 1);
      expect(array[1], 2);
      expect(array[2], 3);
    });

    test('Type-safe get with default', () {
      var array = ModelLessArray<dynamic>();
      array.set(10);
      array.set('text');
      array.set(true);

      expect(array.get<int>(0, def: -1), 10);
      expect(array.get<String>(1, def: ''), 'text');
      expect(array.get<bool>(2, def: false), true);
      expect(array.get<int>(99, def: -1), -1); // Out of bounds
    });

    test('forEach iteration', () {
      var array = ModelLessArray<int>();
      array.set(1);
      array.set(2);
      array.set(3);

      var sum = 0;
      array.forEach<int>((val) {
        sum += val;
        return val;
      });

      expect(sum, 6);
    });

    test('Index access and modification', () {
      var array = ModelLessArray<String>();
      array.set('a');
      array.set('b');
      array.set('c');

      expect(array[1], 'b');
      array[1] = 'modified';
      expect(array[1], 'modified');
    });

    test('Out of bounds access', () {
      var array = ModelLessArray<int>();
      array.set(1);

      expect(array[0], 1);
      expect(array[5], null); // Out of bounds returns null

      expect(
          () => array[5] = 10, throwsException); // Setting out of bounds throws
    });

    test('Empty array operations', () {
      var array = ModelLessArray<int>();

      expect(array.isEmpty, true);
      expect(array[0], null);
      expect(array.get<int>(0, def: -1), -1);
    });
  });

  group('DQ (Database Query) Extended Tests', () {
    test('Basic query operations', () {
      expect(DQ.eq('value'), 'value');
      expect(DQ.eq(42), 42);
      expect(DQ.eq(null), null);
    });

    test('Logical operators', () {
      var orQuery =
          DQ.or([DQ.field('status', 'active'), DQ.field('priority', 'high')]);
      expect(orQuery['\$or'], isNotNull);
      expect((orQuery['\$or'] as List).length, 2);

      var andQuery =
          DQ.and([DQ.field('age', DQ.gte(18)), DQ.field('verified', true)]);
      expect(andQuery['\$and'], isNotNull);
      expect((andQuery['\$and'] as List).length, 2);
    });

    test('Comparison operators', () {
      expect(DQ.gt(10), {'\$gt': 10});
      expect(DQ.gte(10), {'\$gte': 10});
      expect(DQ.lt(100), {'\$lt': 100});
      expect(DQ.lte(100), {'\$lte': 100});
    });

    test('Array operators', () {
      expect(DQ.hasIn(['a', 'b', 'c']), {
        '\$in': ['a', 'b', 'c']
      });
      expect(DQ.hasNin(['x', 'y']), {
        '\$nin': ['x', 'y']
      });
    });

    test('Pattern matching', () {
      var likeQuery = DQ.like('test');
      expect(likeQuery['\$regex'], 'test');
      expect(likeQuery['\$options'], 'i');
    });

    test('Field queries', () {
      var query = DQ.field('name', 'John');
      expect(query['name'], 'John');

      var complexQuery = DQ.field('age', DQ.gte(18));
      expect(complexQuery['age'], {'\$gte': 18});
    });

    test('ObjectId queries', () {
      var testId = ObjectId.parse('507f1f77bcf86cd799439011');
      var oidQuery = DQ.oid(testId);
      expect(oidQuery['_id'], testId);

      var idQuery = DQ.id('507f1f77bcf86cd799439011');
      expect(idQuery['_id'], isNotNull);
      expect((idQuery['_id'] as ObjectId).oid, '507f1f77bcf86cd799439011');
    });

    test('Complex nested queries', () {
      var complexQuery = DQ.and([
        DQ.or([DQ.field('status', 'active'), DQ.field('status', 'pending')]),
        DQ.field('age', DQ.gte(18)),
        DQ.field('tags', DQ.hasIn(['premium', 'verified']))
      ]);

      expect(complexQuery['\$and'], isNotNull);
      expect((complexQuery['\$and'] as List).length, 3);
    });
  });

  group('Path Utilities Extended Tests', () {
    test('pathNorm with various inputs', () {
      expect(pathNorm('/path/to/file'), 'path/to/file');
      expect(pathNorm('\\path\\to\\file'), 'path\\to\\file');
      expect(pathNorm('/path/to/file', normSlashs: true), 'path/to/file');
      expect(pathNorm('\\path\\to\\file', normSlashs: true), 'path/to/file');
      expect(pathNorm('path/to/file', endWithSlash: true), 'path/to/file/');
      expect(pathNorm('path/to/file/', endWithSlash: true), 'path/to/file/');
    });

    test('joinPaths with multiple segments', () {
      var result = joinPaths(['a', 'b', 'c']);
      expect(result, contains('a'));
      expect(result, contains('/b'));
      expect(result, contains('/c'));

      result = joinPaths(['']);
      expect(result, isEmpty);
    });

    test('pathsEqual comparison', () {
      expect(pathsEqual(['/a/b', 'a/b', 'a/b/']), true);
      expect(pathsEqual(['/a/b', 'a/c']), false);
      expect(pathsEqual([]), true); // Empty list
      expect(pathsEqual(['single']), true); // Single element
    });

    test('endpointNorm with options', () {
      expect(endpointNorm(['api', 'v1']), '/api/v1/');
      expect(endpointNorm(['api', 'v1'], endWithSlash: false), '/api/v1');
      expect(endpointNorm(['api', 'v1'], startWithSlash: false), 'api/v1/');
      expect(
          endpointNorm(['api', 'v1'],
              startWithSlash: false, endWithSlash: false),
          'api/v1');
    });
  });

  group('DateTime and Date Formatting', () {
    test('DateTime format extension', () {
      var date = DateTime(2024, 1, 15, 10, 30, 45);

      expect(date.format('yyyy-MM-dd'), '2024-01-15');
      expect(date.format('HH:mm:ss'), '10:30:45');
      expect(date.format('yyyy-MM-dd HH:mm'), '2024-01-15 10:30');
      expect(date.format('MMM dd, yyyy'), 'Jan 15, 2024');
    });
  });

  group('LMap (Localized Map) Tests', () {
    test('Basic LMap with default string', () {
      var lmap = LMap({'a': 'Alpha', 'b': 'Beta'}, def: 'Not Found');

      expect(lmap['a'], 'Alpha');
      expect(lmap['b'], 'Beta');
      expect(lmap['c'], 'Not Found');
      expect(lmap['xyz'], 'Not Found');
    });

    test('LMap with @key replacement', () {
      var lmap = LMap({'a': 'Alpha'}, def: '@key');

      expect(lmap['a'], 'Alpha');
      expect(lmap['missing'], 'missing');
      expect(lmap['test'], 'test');
    });

    test('LMap with @key suffix', () {
      var lmap = LMap({'a': 'Alpha'}, def: '@key_suffix');

      expect(lmap['a'], 'Alpha');
      expect(lmap['test'], 'test_suffix');
      expect(lmap['xyz'], 'xyz_suffix');
    });

    test('LMap with empty map', () {
      var lmap = LMap({}, def: 'default');

      expect(lmap['anything'], 'default');
    });
  });

  group('String to Int Conversion', () {
    test('toInt with valid numbers', () {
      expect('123'.toInt(), 123);
      expect('0'.toInt(), 0);
      expect('-456'.toInt(), -456);
      expect('  789  '.toInt(), 789);
    });

    test('toInt with default values', () {
      expect('invalid'.toInt(def: -1), -1);
      expect(''.toInt(def: 0), 0);
      expect('12.34'.toInt(def: -1), -1); // Not a valid int
      expect('abc123'.toInt(def: 99), 99);
    });

    test('isInt validation', () {
      expect('123'.isInt, true);
      expect('0'.isInt, true);
      expect('-456'.isInt, true);

      expect('12.34'.isInt, false);
      expect('abc'.isInt, false);
      expect(''.isInt, false);
      expect('12a'.isInt, false);
    });
  });

  group('Map Navigation Extended Tests', () {
    test('Simple path navigation', () {
      var map = {
        'user': {'name': 'John', 'age': 30}
      };

      expect(map.navigation<String>(path: 'user/name', def: ''), 'John');
      expect(map.navigation<int>(path: 'user/age', def: 0), 30);
    });

    test('Deep nested navigation', () {
      var map = {
        'a': {
          'b': {
            'c': {'value': 'deep'}
          }
        }
      };

      expect(map.navigation<String>(path: 'a/b/c/value', def: ''), 'deep');
    });

    test('Array navigation', () {
      var map = {
        'items': [10, 20, 30]
      };

      expect(map.navigation<int>(path: 'items/0', def: -1), 10);
      expect(map.navigation<int>(path: 'items/2', def: -1), 30);
      expect(
          map.navigation<int>(path: 'items/5', def: -1), -1); // Out of bounds
    });

    test('Mixed object and array navigation', () {
      var map = {
        'users': [
          {
            'name': 'Alice',
            'scores': [90, 85, 88]
          },
          {
            'name': 'Bob',
            'scores': [75, 80, 82]
          }
        ]
      };

      expect(map.navigation<String>(path: 'users/0/name', def: ''), 'Alice');
      expect(map.navigation<int>(path: 'users/0/scores/1', def: 0), 85);
      expect(map.navigation<String>(path: 'users/1/name', def: ''), 'Bob');
      expect(map.navigation<int>(path: 'users/1/scores/2', def: 0), 82);
    });

    test('Navigation with missing paths', () {
      var map = {'a': 1};

      expect(map.navigation<int>(path: 'b', def: -1), -1);
      expect(map.navigation<String>(path: 'a/b/c', def: 'missing'), 'missing');
    });
  });
}
