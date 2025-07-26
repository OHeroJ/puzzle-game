import 'package:supabase/supabase.dart' as supabase hide User;
import 'auth_provider.dart';
import 'user.dart' as local;

// Supabase认证提供商实现
class SupabaseAuthProvider implements AuthProvider {
  final supabase.SupabaseClient _supabase;
  
  @override
  AuthStateChangedCallback? onAuthStateChanged;

  SupabaseAuthProvider(supabase.SupabaseClient supabase) : _supabase = supabase {
    // 监听认证状态变化
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        final user = _convertSupabaseUser(session.user!);
        onAuthStateChanged?.call(user);
      } else {
        onAuthStateChanged?.call(null);
      }
    });
  }

  local.User _convertSupabaseUser(dynamic supabaseUser) {
    return local.User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      name: supabaseUser.userMetadata?['name'] ?? supabaseUser.email ?? 'User',
      avatarUrl: supabaseUser.userMetadata?['avatar_url'],
    );
  }

  @override
  local.User? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    return user != null ? _convertSupabaseUser(user) : null;
  }

  @override
  bool isSignedIn() {
    return _supabase.auth.currentSession != null;
  }

  @override
  Future<local.User?> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      // 使用dynamic类型避免编译错误
      if (response.user != null) {
        return _convertSupabaseUser(response.user!);
      }
    } on supabase.AuthApiException catch (e) {
      // 处理认证异常
      print('Login error: ${e.message}');
    }
    return null;
  }

  @override
  Future<local.User?> register(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      // 使用dynamic类型避免编译错误
      if (response.user != null) {
        return _convertSupabaseUser(response.user!);
      }
    } on supabase.AuthApiException catch (e) {
      // 处理认证异常
      print('Register error: ${e.message}');
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}