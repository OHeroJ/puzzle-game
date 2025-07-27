import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../user/user.dart';
import '../user/user_manager.dart';
import 'ranking.dart';
import 'score_calculator.dart';

class RankingManager {
  final supabase.SupabaseClient supabaseClient;
  bool _isLoading = false;
  List<Ranking> _rankings = [];

  RankingManager({required this.supabaseClient});

  bool get isLoading => _isLoading;
  List<Ranking> get rankings => _rankings;

  /// 获取排行榜
  Future<List<Ranking>> getRankings({int limit = 50}) async {
    try {
      _isLoading = true;
      
      final response = await supabaseClient
          .from('rankings')
          .select()
          .order('score', ascending: false)
          .limit(limit);

      _rankings = response.map((data) => Ranking.fromJson(data)).toList();
      return _rankings;
    } on supabase.PostgrestException catch (e) {
      // 处理数据库异常
      if (e.code == '42P01') {
        // 表不存在
        print('Database table "rankings" does not exist: ${e.message}');
      } else {
        print('Failed to fetch rankings: ${e.message}');
      }
      return [];
    } catch (e) {
      // 处理其他异常
      print('Failed to fetch rankings: $e');
      return [];
    } finally {
      _isLoading = false;
    }
  }

  /// 提交分数
  Future<bool> submitScore(int score, UserManager userManager) async {
    try {
      // 检查用户是否已登录
      if (!userManager.isSignedIn || userManager.currentUser == null) {
        return false;
      }

      final user = userManager.currentUser!;
      
      // 保存分数到排行榜
      await supabaseClient.from('rankings').insert({
        'user_id': user.id,
        'username': user.name,
        'score': score,
        'avatar_url': '', // 可以根据需要添加头像URL
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } on supabase.PostgrestException catch (e) {
      // 处理数据库异常
      if (e.code == '42P01') {
        // 表不存在
        print('Database table "rankings" does not exist: ${e.message}');
      } else {
        print('Failed to submit score: ${e.message}');
      }
      return false;
    } catch (e) {
      // 处理其他异常
      print('Failed to submit score: $e');
      return false;
    }
  }
}