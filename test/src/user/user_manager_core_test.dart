import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle/src/user/user_manager.dart';
import 'mock_auth_provider.dart';

void main() {
  group('UserManager Core Functionality', () {
    late UserManager userManager;
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      userManager = UserManager();
      mockAuthProvider = MockAuthProvider();
    });

    test('should initialize with no current user', () {
      // 由于Supabase初始化可能失败，这里我们只测试初始状态
      expect(userManager.currentUser, null);
    });

    test('should work with mock auth provider', () async {
      // 使用mock provider测试核心功能
      userManager.initAuthProvider(mockAuthProvider);
      
      expect(userManager.isSignedIn, false);
      
      // 测试登录
      final loginResult = await userManager.login('test@example.com', 'password123');
      expect(loginResult, true);
      expect(userManager.currentUser, isNotNull);
      expect(userManager.isSignedIn, true);
      
      // 测试登出
      await userManager.logout();
      expect(userManager.currentUser, null);
      expect(userManager.isSignedIn, false);
      
      // 测试注册
      final registerResult = await userManager.register('newuser@example.com', 'password123');
      expect(registerResult, true);
      expect(userManager.currentUser, isNotNull);
      expect(userManager.isSignedIn, true);
    });
  });
}