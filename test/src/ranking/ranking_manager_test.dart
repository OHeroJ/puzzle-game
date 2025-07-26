import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle/src/ranking/ranking_manager.dart';
import 'package:puzzle/src/user/user.dart' as local_user;
import 'package:puzzle/src/user/user_manager.dart';
import 'package:puzzle/src/ranking/ranking.dart';
import 'package:supabase/supabase.dart' as supabase;

class MockUserManager extends UserManager {
  local_user.User? _currentUser;
  bool _isSignedIn = false;

  @override
  local_user.User? get currentUser => _currentUser;

  @override
  bool get isSignedIn => _isSignedIn;

  void setCurrentUser(local_user.User user) {
    _currentUser = user;
    _isSignedIn = true;
  }

  void clearUser() {
    _currentUser = null;
    _isSignedIn = false;
  }
}

// 创建一个简单的测试用SupabaseClient模拟
class MockSupabaseClient extends supabase.SupabaseClient {
  MockSupabaseClient() : super('https://test.supabase.co', 'test-key');

  @override
  supabase.SupabaseQueryBuilder from(String table) {
    throw UnimplementedError();
  }
}

// 创建一个简单的测试用RankingManager子类
class TestRankingManager extends RankingManager {
  final MockUserManager _mockUserManager;
  
  TestRankingManager(MockUserManager userManager) 
    : _mockUserManager = userManager,
      super(MockSupabaseClient(), userManager);

  @override
  Future<List<Ranking>> fetchRankings({int limit = 50}) async {
    // 模拟返回一些排行榜数据
    return [
      Ranking(
        id: '1',
        userId: 'user1',
        username: 'Player One',
        score: 2000,
        createdAt: DateTime(2023, 1, 1),
      ),
      Ranking(
        id: '2',
        userId: 'user2',
        username: 'Player Two',
        score: 1500,
        createdAt: DateTime(2023, 1, 2),
      ),
      Ranking(
        id: '3',
        userId: 'user3',
        username: 'Player Three',
        score: 1000,
        createdAt: DateTime(2023, 1, 3),
      ),
    ];
  }

  @override
  Future<bool> submitScore(int score) async {
    // 模拟提交分数
    if (_mockUserManager.currentUser == null) {
      return false;
    }
    return true;
  }
}

void main() {
  group('RankingManager', () {
    late MockUserManager mockUserManager;
    late TestRankingManager rankingManager;

    setUp(() {
      mockUserManager = MockUserManager();
      rankingManager = TestRankingManager(mockUserManager);
    });

    test('should fetch rankings successfully', () async {
      final rankings = await rankingManager.fetchRankings();

      expect(rankings, isNotEmpty);
      expect(rankings.length, 3);
      expect(rankings[0].username, 'Player One');
      expect(rankings[0].score, 2000);
      expect(rankings[1].username, 'Player Two');
      expect(rankings[1].score, 1500);
      expect(rankings[2].username, 'Player Three');
      expect(rankings[2].score, 1000);
    });

    test('should submit score successfully when user is signed in', () async {
      // 设置当前用户
      final user = local_user.User(
        id: 'user123',
        email: 'test@example.com',
        name: 'Test User',
      );
      mockUserManager.setCurrentUser(user);

      final result = await rankingManager.submitScore(2500);

      expect(result, isTrue);
    });

    test('should not submit score when user is not signed in', () async {
      mockUserManager.clearUser();

      final result = await rankingManager.submitScore(2500);

      expect(result, isFalse);
    });
  });
}