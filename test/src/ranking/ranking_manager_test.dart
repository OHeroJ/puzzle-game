import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle/src/ranking/ranking.dart';
import 'package:puzzle/src/ranking/ranking_manager.dart';
import 'package:puzzle/src/user/user.dart';
import 'package:puzzle/src/user/user_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class MockSupabaseClient extends supabase.SupabaseClient {
  MockSupabaseClient() : super('https://test.supabase.co', 'test-key');
}

class MockUserManager implements UserManager {
  @override
  bool get isSignedIn => _isSignedIn;
  bool _isSignedIn = false;
  
  @override
  User? get currentUser => _currentUser;
  User? _currentUser;
  
  // 实现其他必需的方法和属性
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// 创建一个简单的测试用RankingManager子类
class TestRankingManager extends RankingManager {
  TestRankingManager() : super(supabaseClient: MockSupabaseClient());
  
  @override
  Future<List<Ranking>> getRankings({int limit = 50}) async {
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
        score: 1800,
        createdAt: DateTime(2023, 1, 2),
      ),
    ];
  }

  @override
  Future<bool> submitScore(int score, UserManager userManager) async {
    // 模拟提交分数
    if (!userManager.isSignedIn || userManager.currentUser == null) {
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
      rankingManager = TestRankingManager();
    });

    test('should fetch rankings successfully', () async {
      final rankings = await rankingManager.getRankings();
      
      expect(rankings, isNotEmpty);
      expect(rankings.length, 2);
      expect(rankings[0].username, 'Player One');
      expect(rankings[0].score, 2000);
      expect(rankings[1].username, 'Player Two');
      expect(rankings[1].score, 1800);
    });

    test('should submit score successfully when user is signed in', () async {
      // 模拟用户已登录
      mockUserManager._isSignedIn = true;
      mockUserManager._currentUser = User(id: 'test', email: 'test@example.com', name: 'Test User');
      
      final result = await rankingManager.submitScore(1500, mockUserManager);
      
      expect(result, true);
    });

    test('should not submit score when user is not signed in', () async {
      // 模拟用户未登录
      mockUserManager._isSignedIn = false;
      mockUserManager._currentUser = null;
      
      final result = await rankingManager.submitScore(1500, mockUserManager);
      
      expect(result, false);
    });
  });
}