import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../games_services/score.dart';
import 'user_manager.dart';

class UserProgressManager extends ChangeNotifier {
  final supabase.SupabaseClient _supabaseClient;

  UserProgressManager({required supabase.SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  /// 保存用户游戏进度
  Future<bool> saveProgress(int level, Score score, UserManager userManager) async {
    try {
      // 检查用户是否已登录
      if (!userManager.isSignedIn || userManager.currentUser == null) {
        return false;
      }

      final user = userManager.currentUser!;
      
      // 保存关卡进度
      await _supabaseClient.from('level_progress').upsert({
        'user_id': user.id,
        'level': level,
        'moves': 0, // Score类中没有moves字段，暂时设置为0
        'time': score.duration.inSeconds, // 使用duration.inSeconds
        'score': 0, // Score类中没有score字段，暂时设置为0
        'completed_at': DateTime.now().toIso8601String(),
      });

      return true;
    } on supabase.PostgrestException catch (e) {
      // 处理数据库异常
      if (e.code == '42P01') {
        // 表不存在
        print('Database table "level_progress" does not exist: ${e.message}');
      } else {
        print('Failed to save progress: ${e.message}');
      }
      return false;
    } catch (e) {
      // 处理其他异常
      print('Failed to save progress: $e');
      return false;
    }
  }

  /// 获取用户特定关卡的进度
  Future<Score?> getLevelProgress(int level, UserManager userManager) async {
    try {
      // 检查用户是否已登录
      if (!userManager.isSignedIn || userManager.currentUser == null) {
        return null;
      }

      final user = userManager.currentUser!;
      
      // 获取关卡进度
      final response = await _supabaseClient
          .from('level_progress')
          .select('time')
          .eq('user_id', user.id)
          .eq('level', level)
          .single();
          
      // 创建Score对象
      return Score(
        Duration(seconds: response['time'] as int),
      );
    } on supabase.PostgrestException catch (e) {
      // 处理数据库异常
      if (e.code == '42P01') {
        // 表不存在
        print('Database table "level_progress" does not exist: ${e.message}');
      } else {
        print('Failed to get level progress: ${e.message}');
      }
      return null;
    } catch (e) {
      // 处理其他异常
      print('Failed to get level progress: $e');
      return null;
    }
  }

  /// 获取用户所有关卡的进度
  Future<List<Map<String, dynamic>>> getAllProgress(UserManager userManager) async {
    try {
      // 检查用户是否已登录
      if (!userManager.isSignedIn || userManager.currentUser == null) {
        return [];
      }

      final user = userManager.currentUser!;
      
      // 获取所有关卡进度
      final response = await _supabaseClient
          .from('level_progress')
          .select()
          .eq('user_id', user.id);
          
      return response;
    } on supabase.PostgrestException catch (e) {
      // 处理数据库异常
      if (e.code == '42P01') {
        // 表不存在
        print('Database table "level_progress" does not exist: ${e.message}');
      } else {
        print('Failed to get all progress: ${e.message}');
      }
      return [];
    } catch (e) {
      // 处理其他异常
      print('Failed to get all progress: $e');
      return [];
    }
  }
}