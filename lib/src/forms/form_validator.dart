import 'dart:convert';
import 'package:finch/finch_model_less.dart';
import 'package:finch/finch_mysql.dart';
import 'package:finch/finch_tools.dart';

import '../render/request.dart';
import '../core/context.dart';

typedef ValidatorEvent<T> = Future<FieldValidateResult> Function(T value);

extension SimpleValidatorEvent<T> on ValidatorEvent<T> {
  /// Converts the validator event to a `FieldValidator` instance.
  Future<String> Function(dynamic value) toSimple() {
    return (value) async {
      var res = await this(value);
      if (res.success) {
        return '';
      } else {
        return res.error.isNotEmpty ? res.error : res.errors.join(',');
      }
    };
  }
}

/// A class for validating form data using customizable field validators.
/// The `FormValidator` class allows defining validation rules for form fields
/// and then validating input data against those rules. It also handles error
/// reporting and formatting for easy form validation and feedback display.
class FormValidator {
  /// Gets the current WebRequest from the request context
  Request get rq => Context.rq;

  /// A map of field names to a list of validator events that will be applied to them.
  Map<String, List<ValidatorEvent>> fields;

  /// The value to indicate a field is valid.
  Object success;

  /// The value to indicate a field is invalid.
  Object failed;

  /// The name of the form or validation context. we will use this name in front-end and api key.
  String name;

  /// Additional data that can be used in validation, not coming directly from the request.
  Map<String, Object?> extraData;

  /// Constructor to initialize the `FormValidator`.
  ///
  /// Parameters:
  /// - [fields]: A map of fields to validate with their respective validation rules. (required)
  /// - [name]: The name of the form or validation context. (required)
  /// - [failed]: The value to mark a field as invalid. (optional, defaults to 'is-invalid')
  /// - [success]: The value to mark a field as valid. (optional, defaults to an empty string)
  /// - [extraData]: Additional data to be considered during validation. (optional, defaults to an empty map)
  FormValidator({
    required this.fields,
    required this.name,
    this.failed = 'is-invalid',
    this.success = '',
    this.extraData = const {},
  });

  /// Validates the form data and returns a boolean result.
  ///
  /// If [data] is provided, it will be used instead of loading data from the request.
  ///
  /// Returns `true` if all validations pass, otherwise `false`.
  Future<bool> validate({
    Map data = const {},
  }) async {
    var res = await validateAndForm(data: data);
    return res.result;
  }

  /// Validates the form data and returns both the result and the validated form structure.
  ///
  /// The validated form structure contains information about the validation results,
  /// including error messages, the validity state, and field values.
  ///
  /// If [data] is provided, it will be used instead of loading data from the request.
  ///
  /// Returns a tuple containing:
  /// - `result`: The overall validation result (true if all validations pass).
  /// - `form`: A map of the form structure containing field validation details.
  Future<({bool result, Map<String, dynamic> form})> validateAndForm({
    Map data = const {},
  }) async {
    bool result = true;
    var thisForm = <String, dynamic>{};

    for (var fieldName in fields.keys) {
      var fieldResult = <String, dynamic>{};
      Object? fieldValue;
      if (data.isEmpty && extraData.isEmpty) {
        fieldValue = rq.data(fieldName);
      } else {
        fieldValue = data[fieldName] ?? extraData[fieldName];
      }
      fieldResult["value"] = fieldValue;

      var fieldEvents = fields[fieldName] ?? [];

      var success = true;
      var errors = [];
      for (var validateField in fieldEvents) {
        FieldValidateResult check = await validateField(fieldValue);
        if (!check.success) {
          success = false;
        }

        errors.addAll(check.errors);
      }

      fieldResult['valid'] = success ? this.success : failed;
      fieldResult['error'] = errors.join(',');
      fieldResult['errorHtml'] = errors.join('<br/>');
      fieldResult['errors'] = errors;
      fieldResult['success'] = success;
      fieldResult['failed'] = !success;
      if (!success) {
        result = false;
      }

      thisForm[fieldName] = fieldResult;
    }

    extraData.forEach((key, value) {
      if (!thisForm.containsKey(key)) {
        thisForm[key] = {
          'success': true,
          'failed': false,
          'error': '',
          'errors': [],
          'errorHtml': '',
          'valid': success,
          'value': value,
        };
      }
    });

    rq.addValidator(name, thisForm);

    return (result: result, form: thisForm);
  }

  /// Creates and returns a `FormValidator` instance with empty validators for all fields in [data].
  ///
  /// Useful for initializing a validator instance without predefined validation rules.
  ///
  /// Parameters:
  /// - [name]: The name of the form or validation context. (required)
  /// - [data]: A map representing the fields to validate. (required)
  ///
  /// Returns a `FormValidator` instance.
  static Future<FormValidator> filling({
    required String name,
    required Map data,
  }) async {
    var fields = <String, List<ValidatorEvent>>{};
    for (var item in data.keys) {
      fields[item] = <ValidatorEvent>[];
    }

    final emptyValidator = FormValidator(fields: fields, name: name);
    await emptyValidator.validate(data: data);
    return emptyValidator;
  }

  static Map<String, Object?> extractValues(
    Map<String, Object?> form,
  ) {
    var extraData = <String, Object?>{};
    form.forEach((key, value) {
      if (value is Map<String, Object?>) {
        extraData[key] = value['value'];
      }
    });
    return extraData;
  }

  static Map<String, String> extractString(Map<String, Object?> form,
      [bool allowEmpty = false]) {
    var extraData = <String, String>{};
    form.forEach((key, value) {
      if (value is Map<String, Object?>) {
        if (!allowEmpty && (value['value'] == null || value['value'] == '')) {
          return;
        }
        extraData[key] = value['value']?.toString() ?? '';
      }
    });
    return extraData;
  }
}

/// A class representing the result of a field validation.
/// The `FieldValidateResult` contains information about whether a field is valid,
/// any error messages, and a combined error message for easy access.
class FieldValidateResult {
  /// Whether the validation was successful.
  bool success;

  /// A list of error messages returned from the validation.
  List<String> errors;

  /// A combined error message, usually representing the first error.
  String error;

  /// Constructor for `FieldValidateResult`.
  ///
  /// If [error] is provided and not empty, it is added to the [errors] list automatically.
  FieldValidateResult({
    this.success = false,
    this.errors = const [],
    this.error = '',
  }) {
    if (error.isNotEmpty) {
      errors = [...errors, error];
    }
  }
}

/// A utility class providing common field validators.
/// The `FieldValidator` class contains static methods for common validation tasks,
/// such as checking if a field is required, validating the length of a string,
/// or ensuring a field is a number or an email address.
class FieldValidator {
  /// Validator to check if a field is required (non-null and non-empty).
  static ValidatorEvent requiredField() => (value) async {
        var res = (value != null && value.toString().trim().isNotEmpty);
        return FieldValidateResult(
          success: res,
          error: res ? '' : 'error.field.required',
        );
      };

  /// Validator to check if a field is required in multiple languages.
  ///
  /// This validator expects a JSON object with language keys and checks if at least
  /// one value is non-null and non-empty.
  static ValidatorEvent requiredFieldMultiLanguage() {
    return (value) async {
      var res = (value != null && value.toString().trim().isNotEmpty);

      if (!res) {
        return FieldValidateResult(
          success: res,
          error: res ? '' : 'error.field.required',
        );
      }

      Map<String, String> resMap = {};

      try {
        var json = jsonDecode(value.toString());
        for (var key in json.keys) {
          if (json[key] != null && json[key]!.trim().isNotEmpty) {
            resMap[key] = json[key]!.trim();
          }
        }
      } catch (e) {
        resMap = {};
      }

      return FieldValidateResult(
        success: resMap.isNotEmpty,
        error: resMap.isNotEmpty ? '' : 'error.field.required',
      );
    };
  }

  /// Validator to check if a field's length falls within a specified range.
  ///
  /// - [max]: The maximum allowed length.
  /// - [min]: The minimum allowed length.
  static ValidatorEvent fieldLength({
    int? max,
    int? min,
  }) {
    return (value) async {
      var res = true;
      var error = <String>[];

      if (max != null) {
        if (value.toString().length > max) {
          res = false;
          error.add('error.field.max#{$max}');
        }
      }

      if (min != null) {
        if (value.toString().length < min) {
          res = false;
          error.add('error.field.min#{$min}');
        }
      }

      return FieldValidateResult(
        success: res,
        error: res ? '' : 'error.field',
        errors: error,
      );
    };
  }

  /// Validator to check if a field is a valid number within optional bounds.
  ///
  /// - [max]: The maximum allowed value.
  /// - [min]: The minimum allowed value.
  /// - [isRequired]: Whether the field is required (non-null). Defaults to `false`.
  static ValidatorEvent isNumberField({
    int? max,
    int? min,
    bool isRequired = false,
  }) {
    return (value) async {
      var res = true;
      var error = <String>[];

      if (value.toString().trim().isEmpty) {
        value = null;
      }

      if (value != null) {
        if (!value.toString().isInt) {
          res = false;
          error.add('error.field.numeric');
        } else {
          if (max != null) {
            if (value.toString().toInt() > max) {
              res = false;
              error.add('error.field.max#{$max}');
            }
          }

          if (min != null) {
            if (value.toString().toInt() < min) {
              res = false;
              error.add('error.field.min#{$min}');
            }
          }
        }
      } else if (isRequired) {
        res = false;
        error.add('error.field.required');
      }

      return FieldValidateResult(
        success: res,
        error: res ? '' : 'error.field',
        errors: error,
      );
    };
  }

  /// Validator to check if a field is a valid number within optional bounds.
  ///
  /// - [max]: The maximum allowed value.
  /// - [min]: The minimum allowed value.
  /// - [isRequired]: Whether the field is required (non-null). Defaults to `false`.
  static ValidatorEvent isNumberDoubleField({
    double? max,
    double? min,
    bool isRequired = false,
  }) {
    return (value) async {
      var res = true;
      var error = <String>[];

      if (value != null) {
        if (!value.toString().isDouble) {
          res = false;
          error.add('error.field.numeric');
        } else {
          if (max != null) {
            if (value.toString().asDouble(def: 0) > max) {
              res = false;
              error.add('error.field.max#{$max}');
            }
          }

          if (min != null) {
            if (value.toString().asDouble(def: 0) < min) {
              res = false;
              error.add('error.field.min#{$min}');
            }
          }
        }
      } else if (isRequired) {
        res = false;
        error.add('error.field.required');
      }

      return FieldValidateResult(
        success: res,
        error: res ? '' : 'error.field',
        errors: error,
      );
    };
  }

  /// Validator to check if a field contains a valid email address.
  ///
  /// The validator checks whether the provided value is non-null, is a non-empty
  /// string, and matches the format of an email address. If the validation fails,
  /// an error message `'error.field.email'` is returned.
  ///
  /// Returns:
  /// - `FieldValidateResult`: A result indicating whether the validation passed or failed,
  ///    including any associated error messages.
  static ValidatorEvent isEmailField() => (value) async {
        var res = (value != null && value.toString().trim().isEmail);
        return FieldValidateResult(
          success: res,
          error: res ? '' : 'error.field.email',
        );
      };

  /// Validator to check if a field contains a valid password.
  /// The password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, one number, and one special character.
  /// The validator checks whether the provided value is non-null, is a non-empty
  /// string, and matches the format of a password. If the validation fails,
  /// an error message `'error.field.password'` is returned.
  static ValidatorEvent isPasswordField() => (value) async {
        var res = (value != null && value.toString().trim().isPassword);
        return FieldValidateResult(
          success: res,
          error: res ? '' : 'error.field.password',
        );
      };

  /// Validator to check if a field contains a valid color code.
  /// The color code must be a valid hexadecimal color code.
  /// The validator checks whether the provided value is non-null, is a non-empty
  /// string, and matches the format of a color code. If the validation fails,
  /// an error message `'error.field.color'` is returned.
  static ValidatorEvent isColorField() => (value) async {
        var colorRegexp = RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$');
        var res = value != null &&
            value.toString().trim().isNotEmpty &&
            colorRegexp.hasMatch(value.toString());

        return FieldValidateResult(
          success: res,
          error: res ? '' : 'error.field.color',
        );
      };

  /// Validator to check if a field contains a valid select field.
  /// The select field must be a valid value from the list of options.
  /// The validator checks whether the provided value is non-null, is a non-empty
  /// string, and matches the format of a select field. If the validation fails,
  /// an error message `'error.field.select'` is returned.
  static ValidatorEvent isSelectField(List options) => (value) async {
        var res = options.contains(value);
        return FieldValidateResult(
          success: res,
          error: res ? '' : 'error.field.select',
        );
      };

  static ValidatorEvent hasRelation({
    required DBCollectionFree collectionModel,
    String relationField = '_id',
    bool isRequired = true,
  }) {
    return (value) async {
      if ((value == null || value.toString().isEmpty) && isRequired) {
        return FieldValidateResult(
          success: false,
          error: 'error.field.required',
        );
      }

      if (!isRequired) {
        return FieldValidateResult(success: true);
      }

      var res = await collectionModel.existOid(value);
      return FieldValidateResult(
        success: res,
        error: res ? '' : 'error.field.relation',
      );
    };
  }

  static ValidatorEvent contains(List values, {bool isRequired = true}) {
    return (value) async {
      if ((value == null || value.toString().isEmpty) && isRequired) {
        return FieldValidateResult(
          success: false,
          error: 'error.field.required',
        );
      }

      if ((value == null || value.toString().isEmpty) && !isRequired) {
        return FieldValidateResult(success: true);
      }

      var res = values.contains(value);
      return FieldValidateResult(
        success: res,
        error: res ? '' : 'error.field.contains',
      );
    };
  }

  static ValidatorEvent isDateField({
    bool isRequired = true,
    bool checkUtc = false,
  }) {
    return (value) async {
      if ((value == null || value.toString().isEmpty)) {
        return FieldValidateResult(
          success: !isRequired,
          error: isRequired ? 'error.field.required' : '',
        );
      }

      var date = DateTime.tryParse(value.toString());
      if (date == null || date.year.toString().length != 4) {
        return FieldValidateResult(
          success: false,
          error: 'error.field.date',
        );
      }

      if (checkUtc && !date.isUtc) {
        return FieldValidateResult(
          success: false,
          error: 'error.field.date',
        );
      }

      return FieldValidateResult(success: true);
    };
  }

  /// Validator to check if a field value is unique in a SQL database table.
  /// The validator checks whether the provided value already exists in the specified table and field.
  /// If the value exists, an error message `'error.field.unique'` is returned.
  /// Parameters:
  /// - [db]: The MySQLConnection instance to use for the database query. (required)
  /// - [table]: The name of the database table to check. (required)
  /// - [field]: The name of the field/column to check for uniqueness. (required)
  /// - [operator]: The comparison operator to use in the query. Defaults to `QO.EQ`.
  /// - [where]: An optional additional `Where` clause to further filter the query.
  /// Returns:
  /// - `ValidatorEvent`: A validator event function that can be used in the `FormValidator`.
  static ValidatorEvent isUniqueSQLField({
    required DatabaseDriver db,
    required String table,
    required String field,
    QO operator = QO.EQ,
    Where? where,
  }) {
    return (v) async {
      Sqler sqler = Sqler();
      sqler.from(QField(table));
      sqler.addSelect(SQL.count(QField(field, as: 'count_of_field')));
      sqler.where(WhereOne(QField(field), operator, QVar(v)));
      if (where != null) {
        sqler.where(where);
      }
      var res = await db.execute(sqler);
      if (res.rows.isNotEmpty) {
        var count = res.rows.first.assoc()['count_of_field'] ?? '0';
        if (count.toString().toInt(def: 10) == 0) {
          return FieldValidateResult(success: true);
        }
      }

      return FieldValidateResult(success: false, error: 'error.field.unique');
    };
  }

  /// Validator to check if a field value has a relation in a SQL database table.
  /// The validator checks whether the provided value exists in the specified table and field.
  /// If the value does not exist, an error message `'error.field.relation'` is returned.
  /// Parameters:
  /// - [db]: The MySQLConnection instance to use for the database query. (required)
  /// - [table]: The name of the database table to check. (required)
  /// - [field]: The name of the field/column to check for relation. (required)
  /// - [operator]: The comparison operator to use in the query. Defaults to `QO.EQ`.
  /// - [where]: An optional additional `Where` clause to further filter the query.
  /// Returns:
  /// - `ValidatorEvent`: A validator event function that can be used in the `FormValidator`.
  static ValidatorEvent hasSqlRelation({
    required DatabaseDriver db,
    required String table,
    required String field,
    bool isRequired = true,
    QO operator = QO.EQ,
    Where? where,
  }) {
    return (v) async {
      if (!isRequired && (v == null || v.toString().isEmpty)) {
        return FieldValidateResult(success: true);
      }
      Sqler sqler = Sqler();
      sqler.from(QField(table));
      sqler.addSelect(SQL.count(QField(field, as: 'count_of_field')));
      sqler.where(WhereOne(QField(field), operator, QVar(v)));
      if (where != null) {
        sqler.where(where);
      }
      var res = await db.execute(sqler);
      if (res.rows.isNotEmpty) {
        var count = res.assocFirst?['count_of_field'] ?? '0';
        if (count.toString().toInt(def: 10) > 0) {
          return FieldValidateResult(success: true);
        }
      }
      return FieldValidateResult(success: false, error: 'error.field.relation');
    };
  }

  /// Validator to check if a field matches a given regular expression pattern.
  /// The validator checks whether the provided value matches the specified regex pattern.
  /// If the value does not match the pattern, an error message `'error.field.regex'` is returned.
  /// Parameters:
  /// - [pattern]: The regular expression pattern to match against. (required)
  /// - [isRequired]: Whether the field is required (non-null). Defaults to `true`.
  /// Returns:
  /// - `ValidatorEvent`: A validator event function that can be used in the `FormValidator`.
  static ValidatorEvent checkByRegexp(
    RegExp pattern, {
    bool isRequired = true,
  }) {
    return (value) async {
      if ((value == null || value.toString().isEmpty) && isRequired) {
        return FieldValidateResult(
          success: false,
          error: 'error.field.required',
        );
      }

      if ((value == null || value.toString().isEmpty) && !isRequired) {
        return FieldValidateResult(success: true);
      }

      if (!pattern.hasMatch(value.toString())) {
        return FieldValidateResult(
          success: false,
          error: 'error.field.regex',
        );
      }

      return FieldValidateResult(success: true);
    };
  }
}

class FormResult {
  Map<String, dynamic> form;
  bool result;
  var errors = <String>[];

  FormResult({
    required this.form,
    required this.result,
  });

  String get json => FinchJson.jsonEncoder(form);
}
