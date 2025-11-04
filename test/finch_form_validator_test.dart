import 'package:test/test.dart';
import 'package:finch/src/forms/form_validator.dart';

void main() {
  group('FieldValidateResult Tests', () {
    test('Create successful validation result', () {
      var result = FieldValidateResult(success: true);
      
      expect(result.success, true);
      expect(result.error, '');
      expect(result.errors, []);
    });

    test('Create failed validation result with single error', () {
      var result = FieldValidateResult(
        success: false,
        error: 'Invalid value',
      );
      
      expect(result.success, false);
      expect(result.error, 'Invalid value');
    });

    test('Create failed validation result with multiple errors', () {
      var result = FieldValidateResult(
        success: false,
        errors: ['Error 1', 'Error 2', 'Error 3'],
      );
      
      expect(result.success, false);
      expect(result.errors.length, 3);
      expect(result.errors, contains('Error 1'));
      expect(result.errors, contains('Error 2'));
      expect(result.errors, contains('Error 3'));
    });

    test('Failed result with both error and errors list', () {
      var result = FieldValidateResult(
        success: false,
        error: 'Main error',
        errors: ['Detail 1', 'Detail 2'],
      );
      
      expect(result.success, false);
      expect(result.error, 'Main error');
      expect(result.errors, contains('Detail 1'));
      expect(result.errors, contains('Detail 2'));
    });
  });

  group('FormValidator.extractValues Tests', () {
    test('Extract values from form structure', () {
      var form = {
        'name': {'value': 'John', 'success': true},
        'age': {'value': 30, 'success': true},
        'email': {'value': 'john@example.com', 'success': true},
      };
      
      var extracted = FormValidator.extractValues(form);
      
      expect(extracted['name'], 'John');
      expect(extracted['age'], 30);
      expect(extracted['email'], 'john@example.com');
    });

    test('Extract null values', () {
      var form = {
        'optional': {'value': null, 'success': true},
      };
      
      var extracted = FormValidator.extractValues(form);
      
      expect(extracted['optional'], isNull);
    });

    test('Extract from empty form', () {
      var form = <String, Object?>{};
      
      var extracted = FormValidator.extractValues(form);
      
      expect(extracted, {});
    });

    test('Extract mixed value types', () {
      var form = {
        'string': {'value': 'text'},
        'number': {'value': 42},
        'bool': {'value': true},
        'list': {'value': [1, 2, 3]},
        'map': {'value': {'nested': 'data'}},
      };
      
      var extracted = FormValidator.extractValues(form);
      
      expect(extracted['string'], 'text');
      expect(extracted['number'], 42);
      expect(extracted['bool'], true);
      expect(extracted['list'], [1, 2, 3]);
      expect(extracted['map'], {'nested': 'data'});
    });

    test('Ignore non-map values', () {
      var form = {
        'valid': {'value': 'test'},
        'invalid': 'not a map',
      };
      
      var extracted = FormValidator.extractValues(form);
      
      expect(extracted.containsKey('valid'), true);
      expect(extracted.containsKey('invalid'), false);
    });
  });

  group('FormValidator.extractString Tests', () {
    test('Extract string values', () {
      var form = {
        'name': {'value': 'John'},
        'city': {'value': 'New York'},
      };
      
      var extracted = FormValidator.extractString(form);
      
      expect(extracted['name'], 'John');
      expect(extracted['city'], 'New York');
    });

    test('Convert non-string values to strings', () {
      var form = {
        'age': {'value': 30},
        'active': {'value': true},
        'price': {'value': 19.99},
      };
      
      var extracted = FormValidator.extractString(form);
      
      expect(extracted['age'], '30');
      expect(extracted['active'], 'true');
      expect(extracted['price'], '19.99');
    });

    test('Skip empty values by default', () {
      var form = {
        'name': {'value': 'John'},
        'empty': {'value': ''},
        'nullValue': {'value': null},
      };
      
      var extracted = FormValidator.extractString(form);
      
      expect(extracted.containsKey('name'), true);
      expect(extracted.containsKey('empty'), false);
      expect(extracted.containsKey('nullValue'), false);
    });

    test('Include empty values when allowEmpty is true', () {
      var form = {
        'name': {'value': 'John'},
        'empty': {'value': ''},
        'nullValue': {'value': null},
      };
      
      var extracted = FormValidator.extractString(form, true);
      
      expect(extracted.containsKey('name'), true);
      expect(extracted.containsKey('empty'), true);
      expect(extracted.containsKey('nullValue'), true);
      expect(extracted['empty'], '');
      expect(extracted['nullValue'], '');
    });

    test('Extract from empty form', () {
      var form = <String, Object?>{};
      
      var extracted = FormValidator.extractString(form);
      
      expect(extracted, {});
    });

    test('Handle whitespace strings', () {
      var form = {
        'spaces': {'value': '   '},
        'tabs': {'value': '\t\t'},
      };
      
      // With allowEmpty false, whitespace-only strings are kept
      var extracted = FormValidator.extractString(form);
      expect(extracted['spaces'], '   ');
      expect(extracted['tabs'], '\t\t');
    });
  });

  group('SimpleValidatorEvent Extension Tests', () {
    test('Convert validator to simple function', () async {
      ValidatorEvent<String> validator = (value) async {
        if (value.isEmpty) {
          return FieldValidateResult(
            success: false,
            error: 'Field is required',
          );
        }
        return FieldValidateResult(success: true);
      };
      
      var simpleValidator = validator.toSimple();
      
      var result1 = await simpleValidator('test');
      expect(result1, '');
      
      var result2 = await simpleValidator('');
      expect(result2, 'Field is required');
    });

    test('Simple validator combines multiple errors', () async {
      ValidatorEvent<String> validator = (value) async {
        return FieldValidateResult(
          success: false,
          errors: ['Error 1', 'Error 2', 'Error 3'],
        );
      };
      
      var simpleValidator = validator.toSimple();
      var result = await simpleValidator('test');
      
      expect(result, 'Error 1,Error 2,Error 3');
    });

    test('Simple validator prefers error over errors list', () async {
      ValidatorEvent<String> validator = (value) async {
        return FieldValidateResult(
          success: false,
          error: 'Main error',
          errors: ['Detail 1', 'Detail 2'],
        );
      };
      
      var simpleValidator = validator.toSimple();
      var result = await simpleValidator('test');
      
      expect(result, 'Main error');
    });

    test('Simple validator returns empty on success', () async {
      ValidatorEvent<int> validator = (value) async {
        return FieldValidateResult(success: true);
      };
      
      var simpleValidator = validator.toSimple();
      var result = await simpleValidator(42);
      
      expect(result, '');
    });
  });

  group('Validator Edge Cases', () {
    test('Empty errors list in failed result', () {
      var result = FieldValidateResult(
        success: false,
        errors: [],
      );
      
      expect(result.success, false);
      expect(result.errors, []);
    });

    test('Extract from form with missing value key', () {
      var form = {
        'field1': {'success': true}, // No 'value' key
        'field2': {'value': 'test', 'success': true},
      };
      
      var extracted = FormValidator.extractValues(form);
      
      expect(extracted['field1'], isNull);
      expect(extracted['field2'], 'test');
    });

    test('Extract string with complex nested values', () {
      var form = {
        'simple': {'value': 'text'},
        'nested': {'value': {'inner': 'data'}},
        'list': {'value': [1, 2, 3]},
      };
      
      var extracted = FormValidator.extractString(form);
      
      expect(extracted['simple'], 'text');
      // Nested structures are converted to string representation
      expect(extracted['nested'], contains('inner'));
      expect(extracted['list'], contains('1'));
    });
  });
}