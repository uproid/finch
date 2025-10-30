import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:finch/src/forms/form_validator.dart';
import 'package:finch/finch_model_less.dart';

class DBFormFree {
  var fields = <String, DBFieldFree>{};

  DBFormFree({required this.fields});

  Future<FormResultFree> validate(
    Map<String, Object?> data, {
    List<String> onlyCheckKeys = const [],
  }) async {
    var formResult = FormResultFree(this);

    for (var key in fields.keys) {
      if (onlyCheckKeys.isNotEmpty && !onlyCheckKeys.contains(key)) {
        continue;
      }

      final field = fields[key]!;
      var value = ObjectDescovery.descovr(
        data[key],
        field.type,
        def: field.defaultValue?.call(),
      );

      final resultFieldValidate = await field.validate(value);
      formResult.success &= resultFieldValidate.success;
      formResult.formResult[key] = resultFieldValidate;
    }

    return formResult;
  }
}

class FormResultFree {
  DBFormFree form;
  bool success = true;
  Map<String, FieldResultFree> formResult = {};

  Map<String, Object?> formValues({List<String>? selectedFields}) {
    if (selectedFields != null && selectedFields.isNotEmpty) {
      var res = <String, Object?>{};
      for (var key in selectedFields) {
        res[key] = formResult[key]?.parsedValue;
      }
      return res;
    }
    return formResult.map((key, value) => MapEntry(key, value.parsedValue));
  }

  void updateValues(Map<String, Object?> values) {
    for (var key in formResult.keys) {
      final parsed = ObjectDescovery.descovr(
        values[key],
        formResult[key]!.field.type,
        def: formResult[key]!.field.defaultValue?.call(),
      );
      formResult[key]!.value = parsed;
      formResult[key]!.parsedValue = parsed;
    }
  }

  void updateErrors(Map<String, List<String>> errors) {
    for (var key in formResult.keys) {
      if (errors.containsKey(key)) {
        formResult[key]!.errors = errors[key] ?? [];
        formResult[key]!.success = false;
        formResult[key]!.failed = true;
        formResult[key]!.error = formResult[key]!.errors.join(',');
        formResult[key]!.errorHtml = formResult[key]!.errors.join('<br/>');
        formResult[key]!.valid = 'is-invalid';
        success = false;
      }
    }
  }

  void updateFromMongoResponse(List<Map<String, Object?>> response) {
    final res = MongoErrorResponse.discoverError(response);
    updateErrors(res);
  }

  FormResultFree(
    this.form, {
    this.success = true,
    Map<String, FieldResultFree>? formResult,
  }) {
    this.formResult = formResult ?? {};
  }

  Map<String, Object?> toJson() {
    var res = <String, Object?>{};
    formResult.forEach((key, element) {
      if (!element.field.hideJson) {
        res[key] = element.toJson();
      }
    });

    return res;
  }
}

class FieldResultFree<T> {
  DBFieldFree field;
  var success = true;
  var failed = false;
  var error = '';
  var errors = [];
  var errorHtml = '';
  var valid = '';
  T? value;
  T? parsedValue;

  FieldResultFree(
    this.field, {
    this.success = true,
    this.failed = false,
    this.error = '',
    List? errors,
    this.errorHtml = '',
    this.valid = '',
    this.value,
    this.parsedValue,
  }) {
    this.errors = errors ?? [];
  }

  Map<String, Object?> toJson() {
    return {
      'success': success,
      'failed': failed,
      'error': error,
      'errors': errors,
      'errorHtml': errorHtml,
      'valid': valid,
      'value': value,
      'parsedValue': parsedValue,
    };
  }
}

class DBFieldFree<T> {
  List<ValidatorEvent> validators = [];
  Type get type => T;
  T Function()? defaultValue;
  bool readonly = true;
  bool hideJson = false;
  bool searchable = true;
  bool filterable = false;

  T? Function<R>(R? value)? fix;

  DBFieldFree({
    this.defaultValue,
    this.validators = const [],
    this.readonly = false,
    this.hideJson = false,
    this.searchable = true,
    this.filterable = false,
    this.fix,
  });

  Future<FieldResultFree> validate(Object? fieldValue) async {
    var fieldResult = FieldResultFree(this);
    var value = ObjectDescovery.descovr(
      fieldValue,
      type,
      def: defaultValue?.call(),
    );

    if (fix != null) {
      value = fix?.call(value);
    }

    if (validators.isEmpty || readonly) {
      fieldResult.success &= true;
      fieldResult.failed = false;
      fieldResult.errors = [];
      fieldResult.error = '';
      fieldResult.errorHtml = '';
      fieldResult.valid = 'is-valid';
      fieldResult.value = value;
      fieldResult.parsedValue = value;
    } else {
      for (var validator in validators) {
        FieldValidateResult result = await validator(value);
        fieldResult.success &= result.success;
        fieldResult.failed = !fieldResult.success;
        if (!result.success) {
          fieldResult.errors.addAll(result.errors);
        }
        fieldResult.error = fieldResult.errors.join(',');
        fieldResult.errorHtml = fieldResult.errors.join('<br/>');
        fieldResult.valid = fieldResult.success ? 'is-valid' : 'is-invalid';
        fieldResult.value = fieldValue;
        fieldResult.parsedValue = value;
      }
    }
    return fieldResult;
  }
}

class ObjectDescovery {
  static Object? descovr(Object? value, Type type, {Object? def}) {
    // if (value == null && def == null) {
    //   return null;
    // }
    switch (type.toString()) {
      case 'int':
        return value.asInt(def: (def ?? 0) as int?);
      case 'double':
        return value.asDouble(def: (def ?? 0.0) as double);
      case 'bool':
        return value.asBool(def: (def ?? false) as bool);
      case 'DateTime':
        return value.asDateTime(def: (def ?? DateTime.utc(1977)) as DateTime);
      case 'String':
        return value.asString(def: (def ?? '') as String);
      case 'num':
        return value.asNum(def: (def ?? 0) as num);
      case 'ObjectId':
        return value.asObjectId(
            def: (def ?? mongo.ObjectId()) as mongo.ObjectId);
      case 'List<String>':
        return value.asList<String>(def: (def ?? <String>[]) as List<String>);
      case 'List<ObjectId>':
        return value.asList<mongo.ObjectId>(
            def: (def ?? <mongo.ObjectId>[]) as List<mongo.ObjectId>);

      /// Nulables
      case 'int?':
        if (value == null) return def;
        return value.asInt(def: def as int?);
      case 'double?':
        if (value == null) return def;
        return value.asDouble(def: def as double?);
      case 'bool?':
        if (value == null && def == null) return null;
        return value.asBool(def: def as bool?);
      case 'DateTime?':
        if (value == null) return def;
        return value.asDateTime(def: def as DateTime?);
      case 'String?':
        if (value == null) return def;
        return value.asString(def: def as String?);
      case 'num?':
        if (value == null) return def;
        return value.asNum(def: def as num?);
      case 'ObjectId?':
        if (value == null) return def;
        return value.asObjectId(def: def as mongo.ObjectId?);
      case 'List<String>?':
        if (value == null) return def;
        return value.asList<String>(def: def as List<String>?);
      case 'List<ObjectId>?':
        if (value == null) return def;
        return value.asList<mongo.ObjectId>(def: def as List<mongo.ObjectId>?);
    }

    return (value ?? def);
  }
}
