import 'package:puzzle/src/user/auth_provider.dart';
import 'package:puzzle/src/user/user.dart';

class MockAuthProvider implements AuthProvider {
  User? _currentUser;
  bool _isSignedIn = false;
  AuthStateChangedCallback? onAuthStateChanged;

  @override
  User? getCurrentUser() {
    return _currentUser;
  }

  @override
  bool isSignedIn() {
    return _isSignedIn;
  }

  @override
  Future<User?> login(String email, String password) async {
    if (email == 'test@example.com' && password == 'password123') {
      _currentUser = User(
        id: '123',
        email: email,
        name: 'Test User',
      );
      _isSignedIn = true;
      onAuthStateChanged?.call(_currentUser);
      return _currentUser;
    }
    return null;
  }

  @override
  Future<User?> register(String email, String password, String name) async {
    _currentUser = User(
      id: '124',
      email: email,
      name: name,
    );
    _isSignedIn = true;
    onAuthStateChanged?.call(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    _isSignedIn = false;
    onAuthStateChanged?.call(null);
  }
}