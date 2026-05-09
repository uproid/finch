import 'package:finch/finch_route.dart';
import '../models/mock_user_model.dart';

class McpAuthController extends AuthController<String> {
  McpAuthController();
  List<String> allowedApiKeys = ['1234567890abcdef', 'abcdef1234567890'];
  String? logedInApiKey;

  @override
  Future<bool> auth() async {
    var res = await checkLogin();
    if (!res.success) {
      rq.addParams({
        'url': rq.url('/mcp/books'),
        'type': 'http',
        'apikey': 'Bearer ${allowedApiKeys.first}',
      });
      rq.renderView(path: '/example/mcp');
      return false;
    }
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
        String? user,
      })> checkLogin() async {
    var type = rq.authorization.type;
    var apikey = rq.authorization.value;

    if (type == AuthType.bearer && allowedApiKeys.contains(apikey)) {
      return (
        success: true,
        message: 'API key is valid.',
        user: apikey,
      );
    }

    return (
      success: false,
      message: 'Not logged in.',
      user: null,
    );
  }

  @override
  Future<bool> checkPermission() async {
    if (logedInApiKey != null) {
      return false;
    }

    return true;
  }

  @override
  Future<String> loginPost() async {
    throw UnimplementedError();
  }

  @override
  Future<String> logout() {
    throw UnimplementedError();
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
    logedInApiKey = null;
  }

  @override
  void updateAuth(String email, String password, user) {}
}
