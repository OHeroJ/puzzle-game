import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../config/supabase_config.dart';
import 'auth_provider.dart';
import 'user.dart';
import 'supabase_auth_provider.dart';

class UserManager extends ChangeNotifier {
  AuthProvider? _authProvider;
  User? _currentUser;
  bool _isInitialized = false;

  /// 初始化认证提供商
  void initAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    _authProvider!.onAuthStateChanged = _handleAuthStateChange;

    // 初始化当前用户
    _currentUser = _authProvider!.getCurrentUser();
    _isInitialized = true;
    notifyListeners();
  }

  /// 处理认证状态变化
  void _handleAuthStateChange(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  /// 获取当前用户
  User? get currentUser => _currentUser;

  /// 检查用户是否已登录
  bool get isSignedIn => _authProvider?.isSignedIn() ?? false;

  /// 检查用户管理器是否已初始化
  bool get isInitialized => _isInitialized;

  /// 用户登录
  Future<bool> login(String email, String password) async {
    if (_authProvider == null) {
      return false;
    }

    try {
      final user = await _authProvider!.login(email, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  /// 用户注册
  Future<bool> register(String email, String password, String name) async {
    if (_authProvider == null) {
      return false;
    }

    try {
      final user = await _authProvider!.register(email, password, name);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  /// 用户登出
  Future<void> logout() async {
    if (_authProvider == null) {
      return;
    }

    try {
      await _authProvider!.logout();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('Logout error: $e');
    }
  }
}
