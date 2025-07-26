import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle/src/user/user.dart';

void main() {
  group('User', () {
    test('should create user with required fields', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
      );

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.avatarUrl, null);
    });

    test('should create user with avatar url', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('should convert user to JSON', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      final json = user.toJson();
      expect(json['id'], '123');
      expect(json['email'], 'test@example.com');
      expect(json['name'], 'Test User');
      expect(json['avatar_url'], 'https://example.com/avatar.jpg');
    });

    test('should create user from JSON', () {
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'name': 'Test User',
        'avatar_url': 'https://example.com/avatar.jpg',
      };

      final user = User.fromJson(json);
      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
    });
  });
}