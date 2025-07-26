import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle/src/ranking/ranking.dart';

void main() {
  group('Ranking', () {
    test('should create ranking with required fields', () {
      final now = DateTime.now();
      final ranking = Ranking(
        id: '123',
        userId: '456',
        username: 'Test User',
        score: 1000,
        createdAt: now,
      );

      expect(ranking.id, '123');
      expect(ranking.userId, '456');
      expect(ranking.username, 'Test User');
      expect(ranking.score, 1000);
      expect(ranking.createdAt, now);
      expect(ranking.avatarUrl, null);
    });

    test('should create ranking with avatar url', () {
      final now = DateTime.now();
      final ranking = Ranking(
        id: '123',
        userId: '456',
        username: 'Test User',
        score: 1000,
        createdAt: now,
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      expect(ranking.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('should convert ranking to JSON', () {
      final now = DateTime(2023, 1, 1);
      final ranking = Ranking(
        id: '123',
        userId: '456',
        username: 'Test User',
        score: 1000,
        createdAt: now,
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      final json = ranking.toJson();
      expect(json['id'], '123');
      expect(json['user_id'], '456');
      expect(json['username'], 'Test User');
      expect(json['score'], 1000);
      expect(json['created_at'], '2023-01-01T00:00:00.000');
      expect(json['avatar_url'], 'https://example.com/avatar.jpg');
    });

    test('should create ranking from JSON', () {
      final json = {
        'id': '123',
        'user_id': '456',
        'username': 'Test User',
        'score': 1000,
        'created_at': '2023-01-01T00:00:00.000',
        'avatar_url': 'https://example.com/avatar.jpg',
      };

      final ranking = Ranking.fromJson(json);
      expect(ranking.id, '123');
      expect(ranking.userId, '456');
      expect(ranking.username, 'Test User');
      expect(ranking.score, 1000);
      expect(ranking.createdAt, DateTime(2023, 1, 1));
      expect(ranking.avatarUrl, 'https://example.com/avatar.jpg');
    });
  });
}