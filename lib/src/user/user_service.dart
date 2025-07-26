import 'package:supabase/supabase.dart' as supabase hide User;
import 'user.dart' as local;

// 用户服务类，用于处理用户相关的操作
class UserService {
  final supabase.SupabaseClient _supabase = supabase.SupabaseClient(
    'YOUR_SUPABASE_URL',
    'YOUR_SUPABASE_ANON_KEY',
  );

  // 检查用户是否已登录
  bool isUserLoggedIn() {
    return _supabase.auth.currentSession != null;
  }

  // 用户登录
  Future<bool> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user != null;
    } on supabase.AuthApiException catch (e) {
      print('Login error: ${e.message}');
      return false;
    }
  }

  // 用户注册
  Future<bool> register(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response.user != null;
    } on supabase.AuthApiException catch (e) {
      print('Register error: ${e.message}');
      return false;
    }
  }

  // 用户登出
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // 获取当前用户信息
  local.User? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      return local.User(
        id: user.id,
        email: user.email ?? '',
        name: user.userMetadata?['name'] ?? user.email ?? 'User',
        avatarUrl: user.userMetadata?['avatar_url'],
      );
    }
    return null;
  }
}