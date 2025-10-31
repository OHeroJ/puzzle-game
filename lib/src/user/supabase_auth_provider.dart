import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../config/supabase_config.dart';
import 'auth_provider.dart';
import 'user.dart';

class SupabaseAuthProvider implements AuthProvider {
  final supabase.SupabaseClient _supabaseClient;
  AuthStateChangedCallback? _onAuthStateChanged;

  SupabaseAuthProvider({required supabase.SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient {
    // 监听认证状态变化
    _supabaseClient.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session == null) {
        _onAuthStateChanged?.call(null);
      } else {
        final user = User(
          id: session.user.id,
          email: session.user.email ?? '',
          name: session.user.userMetadata?['name'] as String? ??
              session.user.email ??
              '',
        );
        _onAuthStateChanged?.call(user);
      }
    });
  }

  @override
  User? getCurrentUser() {
    final supabaseUser = _supabaseClient.auth.currentUser;
    if (supabaseUser == null) {
      return null;
    }

    return User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      name: supabaseUser.userMetadata?['name'] as String? ??
          supabaseUser.email ??
          '',
    );
  }

  @override
  bool isSignedIn() {
    return _supabaseClient.auth.currentSession != null;
  }

  @override
  Future<User?> login(String email, String password) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          name: response.user!.userMetadata?['name'] as String? ??
              response.user!.email ??
              '',
        );
      }
      return null;
    } on supabase.AuthException catch (e) {
      // 处理认证异常
      print('Login failed: ${e.message}');
      return null;
    } catch (e) {
      // 处理其他异常
      print('Login failed: $e');
      return null;
    }
  }

  @override
  Future<User?> register(String email, String password, String name) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
        },
      );

      if (response.user != null) {
        return User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          name: name,
        );
      }
      return null;
    } on supabase.AuthException catch (e) {
      // 处理认证异常
      print('Registration failed: ${e.message}');
      return null;
    } catch (e) {
      // 处理其他异常
      print('Registration failed: $e');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      print('Logout failed: $e');
    }
  }

  @override
  set onAuthStateChanged(AuthStateChangedCallback? callback) {
    _onAuthStateChanged = callback;
  }

  @override
  AuthStateChangedCallback? get onAuthStateChanged => _onAuthStateChanged;
}
