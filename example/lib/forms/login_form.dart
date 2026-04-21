import 'package:finch/finch_ui.dart';

class LoginForm extends AdvancedForm {
  @override
  String get widget => 'example/forms/form_login.j2.html';

  @override
  String get name => 'form_login';
  LoginForm();

  @override
  List<Field> fields() {
    return [
      csrf(),
      Field(
        'email',
        // initValue: 'example@uproid.com',
        validators: [
          FieldValidator.requiredField(),
          FieldValidator.isEmailField(),
        ],
      ),
      Field(
        'password',
        // initValue: '@Test123',
        validators: [
          FieldValidator.requiredField(),
          FieldValidator.isPasswordField(),
        ],
      ),
    ];
  }
}
