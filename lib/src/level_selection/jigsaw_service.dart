import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'jigsaw_info.dart';

/// 拼图服务类，用于从Supabase获取拼图数据
class JigsawService {
  final supabase.SupabaseClient _supabaseClient;

  JigsawService(this._supabaseClient);

  /// 从Supabase获取所有拼图数据
  Future<List<JigsawInfo>> getJigsawInfos() async {
    try {
      // 从Supabase获取拼图数据
      final response = await _supabaseClient
          .from('jigsaw_puzzles') // 假设表名为jigsaw_puzzles
          .select()
          .order('grid_size');

      // 将响应数据转换为JigsawInfo对象列表
      final List<JigsawInfo> jigsaws = response.map((data) {
        return JigsawInfo(
          data['image_url'], // 大图URL
          data['small_image_url'], // 小图URL
          data['title'], // 标题
          data['grid_size'], // 网格大小
          data['image_url'], // URL
        )
          ..id = data['id'] // 设置ID
          ..photographer = data['photographer'] ?? '' // 摄影师
          ..difficultyLevel = data['difficulty_level'] ?? data['grid_size']; // 难度等级
      }).toList();

      return jigsaws;
    } on supabase.PostgrestException catch (e) {
      // 处理数据库异常
      if (e.code == '42P01') {
        // 表不存在
        print('Database table "jigsaw_puzzles" does not exist: ${e.message}');
      } else {
        print('Failed to fetch jigsaw puzzles: ${e.message}');
      }
      // 返回默认数据作为后备
      return _getDefaultJigsaws();
    } catch (e) {
      // 处理其他异常
      print('Failed to fetch jigsaw puzzles: $e');
      // 返回默认数据作为后备
      return _getDefaultJigsaws();
    }
  }

  /// 获取默认拼图数据作为后备
  List<JigsawInfo> _getDefaultJigsaws() {
    return [
      JigsawInfo(
        'https://images.pexels.com/photos/1366957/pexels-photo-1366957.jpeg',
        'https://images.pexels.com/photos/1366957/pexels-photo-1366957.jpeg',
        'Mountain Landscape',
        3,
        'https://images.pexels.com/photos/1366957/pexels-photo-1366957.jpeg',
      )..id = 1,
      JigsawInfo(
        'https://images.pexels.com/photos/247599/pexels-photo-247599.jpeg',
        'https://images.pexels.com/photos/247599/pexels-photo-247599.jpeg',
        'Forest Path',
        4,
        'https://images.pexels.com/photos/247599/pexels-photo-247599.jpeg',
      )..id = 2,
    ];
  }
}