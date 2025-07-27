import 'user.dart';

/// 认证状态变化回调
typedef AuthStateChangedCallback = void Function(User? user);

/// 认证提供商接口
abstract class AuthProvider {
  /// 认证状态变化回调
  AuthStateChangedCallback? onAuthStateChanged;

  /// 获取当前用户
  User? getCurrentUser();

  /// 检查用户是否已登录
  bool isSignedIn();

  /// 用户登录
  Future<User?> login(String email, String password);

  /// 用户注册
  Future<User?> register(String email, String password, String name);

  /// 用户登出
  Future<void> logout();
}