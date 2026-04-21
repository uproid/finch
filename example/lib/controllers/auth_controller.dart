import '../forms/login_form.dart';
import '../route/web_route.dart';
import 'package:finch/finch_route.dart';
import 'package:finch/finch_tools.dart';
import '../models/mock_user_model.dart';

class AppAuthController extends AuthController<MockUserModel> {
  AppAuthController();
  MockUserModel? userLogined;

  @override
  Future<bool> auth() async {
    var res = await checkLogin();
    if (!res.success) {
      if (rq.isApiEndpoint) {
        await rq.renderError(
          403,
          toData: true,
          params: {
            'message': 'Please login.',
            'success': false,
          },
        );
      } else {
        await rq.redirect('/example/form');
      }
      return false;
    }
    updateAuth(res.user!.email, res.user!.password, res.user!);
    return true;
  }

  @override
  Future<bool> authApi() async {
    var auth = rq.authorization;
    var mockUser = MockUserModel();

    if (auth.type == AuthType.basic) {
      String email = auth.getBasicUsername();
      String password = auth.getBasicPassword();
      var result = email == mockUser.email && password == mockUser.password;
      if (!result) {
        return false;
      }
    } else if (auth.type == AuthType.bearer) {
      if (auth.value == '${mockUser.email} ${mockUser.password}') {
        return true;
      }
    }
    return false;
  }

  @override
  Future<
      ({
        bool success,
        String message,
        MockUserModel? user,
      })> checkLogin() async {
    var mockUser = MockUserModel();
    var userSession = rq.getSession('user', def: '');

    if (userSession == mockUser.email) {
      return (
        success: true,
        message: 'Success login.',
        user: mockUser,
      );
    } else {
      return (
        success: false,
        message: 'Please login.',
        user: mockUser,
      );
    }
  }

  @override
  Future<bool> checkPermission() async {
    if (rq.route == null) {
      return false;
    }

    if (userLogined == null) {
      return false;
    }

    var permission = userLogined!.permission;
    if (rq.route!.permissions.isNotEmpty &&
        !rq.route!.permissions.contains(permission)) {
      return false;
    }

    return true;
  }

  @override
  Future<String> loginPost() async {
    var formLogin = LoginForm();

    await formLogin.check(
      onInvalid: (p0) {},
      onValid: (p0) {
        var mockUser = MockUserModel();
        var email = formLogin.get<String>('email', def: '');
        var password = formLogin.get<String>('password', def: '');
        if (email == mockUser.email && password == mockUser.password) {
          updateAuth(email, password, mockUser);
        } else {
          rq.addParam('errorLogin', 'form.validation.loginError'.tr);
        }
      },
    );

    return homeController.renderTemplate('example/form');
  }

  @override
  Future<String> logout() {
    removeAuth();
    return rq.redirect('/example/form');
  }

  @override
  Future<String> newUser() {
    throw UnimplementedError();
  }

  @override
  Future<String> register() {
    throw UnimplementedError();
  }

  @override
  void removeAuth() {
    rq.session.remove('user');
    rq.removeCookie('user');
    userLogined = null;
  }

  @override
  void updateAuth(String email, String password, user) {
    userLogined = user;
    rq.addSession('user', email);
  }
}
