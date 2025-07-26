import 'package:flutter/foundation.dart';
import 'package:supabase/supabase.dart' as supabase;

import '../user/user_manager.dart';
import 'ranking.dart';

// 排行榜管理器
class RankingManager with ChangeNotifier {
  final supabase.SupabaseClient _supabaseClient;
  final UserManager _userManager;

  List<Ranking> _rankings = [];
  bool _isLoading = false;

  RankingManager(this._supabaseClient, this._userManager);

  // 获取排行榜数据
  Future<List<Ranking>> fetchRankings({int limit = 50}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabaseClient
          .from('rankings')
          .select()
          .order('score', ascending: false)
          .limit(limit);
      _rankings = response.map((data) => Ranking.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Failed to fetch rankings: $e');
      _rankings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _rankings;
  }

  // 提交用户分数
  Future<bool> submitScore(int score) async {
    if (!_userManager.isSignedIn || _userManager.currentUser == null) {
      return false;
    }

    try {
      final userId = _userManager.currentUser!.id;
      final username = _userManager.currentUser!.name;
      final avatarUrl = _userManager.currentUser!.avatarUrl;

      await _supabaseClient.from('rankings').insert([
        {
          'user_id': userId,
          'username': username,
          'score': score,
          'avatar_url': avatarUrl,
          'created_at': DateTime.now().toIso8601String(),
        }
      ]);

      // 重新获取排行榜数据
      await fetchRankings();
      return true;
    } catch (e) {
      debugPrint('Failed to submit score: $e');
      return false;
    }
  }

  // 获取当前排行榜数据
  List<Ranking> get rankings => _rankings;

  // 检查是否正在加载数据
  bool get isLoading => _isLoading;
}