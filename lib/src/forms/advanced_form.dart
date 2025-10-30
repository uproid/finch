import 'package:finch/finch_model_less.dart';
import 'package:finch/finch_route.dart';
import 'package:finch/finch_ui.dart';

abstract class AdvancedForm {
  Request get rq => Context.rq;

  String name = 'form';
  String csrfTokenName = 'token';
  String widget = 'forms/form.j2.html';
  Map<String, dynamic> initData = {};
  var _isChecked = false;
  bool get isChecked => _isChecked;
  Map? _checkedResult;
  Map<String, dynamic> options = {};
  List<Field> _fields = [];
  List<Field> fields();

  List<String> get methods => [
        Methods.POST,
        Methods.PUT,
      ];

  bool isSubmitted() {
    return methods.contains(rq.method);
  }

  AdvancedForm({this.initData = const {}}) {
    _fields = fields();
    for (var field in _fields) {
      if (initData.containsKey(field.name)) {
        field.initValue = initData[field.name] ?? field.initValue;
      }
      field._form = this;
    }
    _init();
  }

  Field getField(String name) {
    try {
      return _fields.firstWhere((field) => field.name == name);
    } catch (e) {
      throw Exception('Field $name not found in form ${this.name}');
    }
  }

  void _init() {
    var initializer = {
      'widget': widget,
      'name': name,
      'success': true,
    };

    for (var field in _fields) {
      initializer[field.name] = {
        'value': field.initValue,
        'errors': <String>[],
        'error': '',
        'success': true,
        'failed': false,
      };
    }
    rq.addParam(name, initializer);
  }

  Future<bool> fill(
    Map<String, dynamic>? fill, {
    Map<String, dynamic>? options,
  }) async {
    if (options != null) {
      this.options.addAll(options);
    }
    return check(
      fill: fill ?? {},
    );
  }

  Future<bool> check({
    Map fill = const {},
    Function(Map<String, dynamic>)? onValid,
    Function(Map<String, dynamic>)? onInvalid,
  }) async {
    var dataRequest = {
      ...rq.getAll(),
      ...fill,
    };

    var form = {
      'widget': widget,
      'name': name,
      'success': true,
    };

    var success = true;
    for (var field in _fields) {
      var value = _setValue(field, dataRequest[field.name]);
      var resField = await field.validate(value);
      success &= resField['success'];
      form[field.name] = resField;
    }
    form['success'] = success;
    rq.addParam(name, form);
    _isChecked = true;
    _checkedResult = form;

    if (success) {
      await onValid?.call(form);
    } else {
      await onInvalid?.call(form);
    }

    return success;
  }

  /// data is optional data that can be passed to the initOptions function
  Future<Map<String, dynamic>> checkAndData({
    bool fillEmpties = false,
  }) async {
    var res = <String, dynamic>{};
    if (await check()) {
      for (var field in _fields) {
        var value = _checkedResult![field.name]['value'];
        if (fillEmpties) {
          res[field.name] = _checkedResult![field.name]['value'];
        } else if (value != null && value.toString() != '') {
          res[field.name] = _checkedResult![field.name]['value'];
        }
      }
    }
    return res;
  }

  Future<AdvancedForm> initOptions({
    Map<String, dynamic> options = const {},
  }) async {
    this.options.addAll(options);
    var res = rq.getParam(name) as Map<String, dynamic>? ?? {};
    for (var field in _fields) {
      res[field.name]['options'] =
          field.initOptions != null ? await field.initOptions!(field) : [];
    }
    rq.addParam(name, res);
    return this;
  }

  dynamic _setValue(Field field, dynamic value) {
    if ((value == null || value.toString() == '') && field.type == bool) {
      return 'false';
    }
    var res = value ?? field.initValue;
    return res;
  }

  T get<T>(String key, {T? def}) {
    if (!_isChecked) {
      throw Exception('Form not checked yet. Call check() first.');
    }
    return ObjectDescovery.descovr(_checkedResult![key]['value'], T, def: def)
        as T;
  }

  List<String> get fieldKeys => _fields.map((field) => field.name).toList();

  Field csrf() {
    var nameCsrf = 'csrf_token_$name';
    var csrfToken = _generateCsrfToken(nameCsrf);
    return Field(
      csrfTokenName,
      validators: [
        FieldValidator.requiredField(),
        (value) async {
          if (!isSubmitted()) {
            return FieldValidateResult(
              success: true,
              error: '',
            );
          }
          var res = _checkCsrf(
            value: rq.get<String>(csrfTokenName, def: ''),
            name: nameCsrf,
          );
          return FieldValidateResult(
            success: res,
            error: res ? '' : 'Invalid CSRF token. Please try again.',
          );
        },
      ],
      initValue: csrfToken,
    );
  }

  /// Six hours for session validity
  bool _checkCsrf({
    required String name,
    required String? value,
    int diffDuration = 60 * 60 * 6,
  }) {
    if (value != null && value != '') {
      Map dataSession = rq.getSession(name, def: {}) as Map;
      if (value == dataSession['key']) {
        DateTime time = (dataSession['time'] ?? DateTime.now()) as DateTime;
        DateTime duration = DateTime.now();
        if (duration.difference(time).inSeconds <= diffDuration) {
          return true;
        }
      }
    }
    return false;
  }

  String _generateCsrfToken(String name) {
    var old = rq.getSession(name, def: {}) as Map;
    String key = '';
    DateTime time = DateTime.now();

    if (old.isEmpty) {
      key = rq.generateRandomString();
    } else {
      key = old['key'] ?? rq.generateRandomString();
      if (!_checkCsrf(value: key, name: name)) {
        key = rq.generateRandomString();
        time = DateTime.now();
      }
    }

    rq.addSession(name, {
      'key': key,
      'time': time,
    });

    return key;
  }
}

class Field {
  String name;
  List<ValidatorEvent> validators;
  Object? initValue;
  Type type = String;
  AdvancedForm? _form;

  /// `data` is optional data that can be passed to the initOptions function
  Function? initOptions = (
    field,
  ) async =>
      null;

  Field(
    this.name, {
    this.validators = const [],
    this.initValue,
    this.type = String,
    this.initOptions,
  });

  Future<Map<String, dynamic>> validate(dynamic value) async {
    var res = <String, dynamic>{
      'success': true,
      'errors': <String>[],
      'error': '',
      'value': value,
      'failed': false,
      'options': initOptions != null ? await initOptions!(this) : [],
    };
    var errors = <String>[];
    bool success = true;
    if (_form?.isSubmitted() == true) {
      for (var validator in validators) {
        var result = await validator(value);
        success &= result.success;
        errors.addAll(result.errors);
      }
    }

    res['errors'] = errors;
    res['error'] = errors.isNotEmpty ? errors.first : '';
    res['success'] = success;
    res['failed'] = !success;
    return res;
  }
}
