import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle/src/user/user_manager.dart';
import 'mock_auth_provider.dart';

void main() {
  group('UserManager', () {
    late UserManager userManager;
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      userManager = UserManager();
      mockAuthProvider = MockAuthProvider();
    });

    test('should initialize with no current user', () {
      expect(userManager.currentUser, null);
      expect(userManager.isSignedIn, false);
    });

    test('should login successfully with valid credentials', () async {
      userManager.initAuthProvider(mockAuthProvider);
      
      final result = await userManager.login('test@example.com', 'password123');
      
      expect(result, true);
      expect(userManager.currentUser, isNotNull);
      expect(userManager.currentUser!.email, 'test@example.com');
      expect(userManager.isSignedIn, true);
    });

    test('should fail to login with invalid credentials', () async {
      userManager.initAuthProvider(mockAuthProvider);
      
      final result = await userManager.login('test@example.com', 'wrongpassword');
      
      expect(result, false);
      expect(userManager.currentUser, null);
      expect(userManager.isSignedIn, false);
    });

    test('should register successfully', () async {
      userManager.initAuthProvider(mockAuthProvider);
      
      final result = await userManager.register('newuser@example.com', 'password123', 'New User');
      
      expect(result, true);
      expect(userManager.currentUser, isNotNull);
      expect(userManager.currentUser!.email, 'newuser@example.com');
      expect(userManager.isSignedIn, true);
    });

    test('should logout successfully', () async {
      userManager.initAuthProvider(mockAuthProvider);
      
      // First login
      await userManager.login('test@example.com', 'password123');
      expect(userManager.isSignedIn, true);
      
      // Then logout
      await userManager.logout();
      
      expect(userManager.currentUser, null);
      expect(userManager.isSignedIn, false);
    });
  });
}