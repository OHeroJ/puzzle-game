import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'dart:developer' as developer;

import 'jigsaw_info.dart';

/// 拼图服务类，用于从Supabase获取拼图数据
class JigsawService {
  final supabase.SupabaseClient? _supabaseClient;

  JigsawService(this._supabaseClient);

  /// 从Supabase获取所有拼图数据
  Future<List<JigsawInfo>> getJigsawInfos() async {
    // 如果没有提供客户端，则返回默认数据
    if (_supabaseClient == null) {
      return getDefaultJigsaws();
    }

    try {
      developer.log('Attempting to fetch jigsaw puzzles from Supabase');

      // 从Supabase获取拼图数据
      final response = await _supabaseClient!
          .from('jigsaw_puzzles') // 假设表名为jigsaw_puzzles
          .select()
          .order('grid_size');

      developer.log('Raw response from jigsaw_puzzles table: $response');
      developer.log('Number of records retrieved: ${response.length}');

      // 将响应数据转换为JigsawInfo对象列表
      final List<JigsawInfo> jigsaws = response.map((data) {
        developer.log('Processing data record: $data');

        // 检查必要的字段是否存在
        if (data['image_url'] == null) {
          developer.log('Warning: image_url is null for record: $data');
        }

        if (data['title'] == null) {
          developer.log('Warning: title is null for record: $data');
        }

        if (data['grid_size'] == null) {
          developer.log('Warning: grid_size is null for record: $data');
        }

        final jigsaw = JigsawInfo(
          data['image_url'] ?? '', // 大图URL
          data['small_image_url'] ?? data['image_url'] ?? '', // 小图URL
          data['title'] ?? 'Unknown', // 标题
          data['grid_size'] ?? 3, // 网格大小
          data['image_url'] ?? '', // URL
        )
          ..setId = data['id'] ?? 0 // 设置ID
          ..setPhotographer = data['photographer'] ?? '' // 摄影师
          ..setDifficultyLevel =
              data['difficulty_level'] ?? (data['grid_size'] ?? 3); // 难度等级

        return jigsaw;
      }).toList();

      developer.log('Successfully converted ${jigsaws.length} jigsaw puzzles');
      return jigsaws;
    } on supabase.PostgrestException catch (e) {
      // 处理数据库异常
      developer.log('PostgrestException while fetching jigsaw puzzles',
          error: e);
      if (e.code == '42P01') {
        // 表不存在
        developer.log(
            'Database table "jigsaw_puzzles" does not exist: ${e.message}');
        print('Database table "jigsaw_puzzles" does not exist: ${e.message}');
      } else {
        developer.log('Failed to fetch jigsaw puzzles: ${e.message}');
        print('Failed to fetch jigsaw puzzles: ${e.message}');
      }
      // 返回默认数据作为后备
      return getDefaultJigsaws();
    } catch (e, stackTrace) {
      // 处理其他异常
      developer.log('Unexpected error while fetching jigsaw puzzles',
          error: e, stackTrace: stackTrace);
      print('Failed to fetch jigsaw puzzles: $e');
      // 返回默认数据作为后备
      return getDefaultJigsaws();
    }
  }

  /// 根据ID从Supabase获取单个拼图数据
  Future<JigsawInfo?> getJigsawInfoById(int id) async {
    // 如果没有提供客户端，则返回null
    if (_supabaseClient == null) {
      return null;
    }

    try {
      developer
          .log('Attempting to fetch jigsaw puzzle with ID: $id from Supabase');

      // 从Supabase获取指定ID的拼图数据
      final response = await _supabaseClient!
          .from('jigsaw_puzzles')
          .select()
          .eq('id', id)
          .limit(1)
          .single();

      developer.log('Raw response for jigsaw puzzle with ID $id: $response');

      // 检查必要的字段是否存在
      if (response['image_url'] == null) {
        developer.log('Warning: image_url is null for record: $response');
      }

      if (response['title'] == null) {
        developer.log('Warning: title is null for record: $response');
      }

      if (response['grid_size'] == null) {
        developer.log('Warning: grid_size is null for record: $response');
      }

      final jigsaw = JigsawInfo(
        response['image_url'] ?? '', // 大图URL
        response['small_image_url'] ?? response['image_url'] ?? '', // 小图URL
        response['title'] ?? 'Unknown', // 标题
        response['grid_size'] ?? 3, // 网格大小
        response['image_url'] ?? '', // URL
      )
        ..setId = response['id'] ?? 0 // 设置ID
        ..setPhotographer = response['photographer'] ?? '' // 摄影师
        ..setDifficultyLevel = response['difficulty_level'] ??
            (response['grid_size'] ?? 3); // 难度等级

      developer
          .log('Successfully converted jigsaw puzzle with ID: ${jigsaw.id}');
      return jigsaw;
    } on supabase.PostgrestException catch (e) {
      // 处理数据库异常
      developer.log(
          'PostgrestException while fetching jigsaw puzzle with ID: $id',
          error: e);
      if (e.code == '42P01') {
        // 表不存在
        developer.log(
            'Database table "jigsaw_puzzles" does not exist: ${e.message}');
        print('Database table "jigsaw_puzzles" does not exist: ${e.message}');
      } else if (e.code == 'PGRST116') {
        // 未找到记录
        developer.log('Jigsaw puzzle with ID: $id not found');
        print('Jigsaw puzzle with ID: $id not found');
      } else {
        developer.log(
            'Failed to fetch jigsaw puzzle with ID: $id, error: ${e.message}');
        print(
            'Failed to fetch jigsaw puzzle with ID: $id, error: ${e.message}');
      }
      return null;
    } catch (e, stackTrace) {
      // 处理其他异常
      developer.log(
          'Unexpected error while fetching jigsaw puzzle with ID: $id',
          error: e,
          stackTrace: stackTrace);
      print('Failed to fetch jigsaw puzzle with ID: $id, error: $e');
      return null;
    }
  }

  /// 获取默认拼图数据作为后备
  List<JigsawInfo> getDefaultJigsaws() {
    developer.log('Returning default jigsaw puzzles');
    return [
      JigsawInfo(
        'https://images.pexels.com/photos/1366957/pexels-photo-1366957.jpeg',
        'https://images.pexels.com/photos/1366957/pexels-photo-1366957.jpeg',
        'Mountain Landscape',
        3,
        'https://images.pexels.com/photos/1366957/pexels-photo-1366957.jpeg',
      )..setId = 1,
      JigsawInfo(
        'https://images.pexels.com/photos/247599/pexels-photo-247599.jpeg',
        'https://images.pexels.com/photos/247599/pexels-photo-247599.jpeg',
        'Forest Path',
        4,
        'https://images.pexels.com/photos/247599/pexels-photo-247599.jpeg',
      )..setId = 2,
    ];
  }
}
