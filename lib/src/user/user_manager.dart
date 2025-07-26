import 'package:flutter/foundation.dart';
import 'package:supabase/supabase.dart' as supabase;
import 'auth_provider.dart';
import 'supabase_auth_provider.dart';
import 'user.dart' as local;

// 用户系统管理器
class UserManager with ChangeNotifier {
  AuthProvider? _authProvider;
  local.User? _currentUser;

  UserManager() {
    // 初始化Supabase认证提供商
    try {
      final supabaseClient = supabase.SupabaseClient(
        'YOUR_SUPABASE_URL',
        'YOUR_SUPABASE_ANON_KEY',
      );
      _authProvider = SupabaseAuthProvider(supabaseClient);
      _authProvider!.onAuthStateChanged = _onAuthStateChanged;
      _currentUser = _authProvider!.getCurrentUser();
    } catch (e) {
      debugPrint('Failed to initialize Supabase auth provider: $e');
    }
  }

  // 初始化认证提供商（用于测试）
  void initAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    _authProvider!.onAuthStateChanged = _onAuthStateChanged;
    _currentUser = _authProvider!.getCurrentUser();
  }

  // 认证状态变化处理
  void _onAuthStateChanged(local.User? user) {
    _currentUser = user;
    notifyListeners();
  }

  // 获取当前用户
  local.User? get currentUser => _currentUser;

  // 检查用户是否已登录
  bool get isSignedIn => _authProvider?.isSignedIn() ?? false;

  // 用户登录
  Future<bool> login(String email, String password) async {
    if (_authProvider == null) return false;

    try {
      final user = await _authProvider!.login(email, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }
    return false;
  }

  // 用户注册
  Future<bool> register(String email, String password) async {
    if (_authProvider == null) return false;

    try {
      final user = await _authProvider!.register(email, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Register error: $e');
    }
    return false;
  }

  // 用户登出
  Future<void> logout() async {
    if (_authProvider == null) return;

    try {
      await _authProvider!.logout();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }
}