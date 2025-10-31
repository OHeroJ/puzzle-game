import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'dart:developer' as developer;

class TestSupabase {
  final supabase.SupabaseClient _supabaseClient;

  TestSupabase(this._supabaseClient);

  Future<void> testConnection() async {
    try {
      // 测试数据库连接
      developer.log('Testing Supabase connection...');

      // 尝试获取表信息
      final tablesResponse =
          await _supabaseClient.from('jigsaw_puzzles').select().limit(1);

      developer.log('Successfully connected to jigsaw_puzzles table');
      developer.log('Sample data: $tablesResponse');

      // 获取所有数据
      final allData = await _supabaseClient.from('jigsaw_puzzles').select();

      developer.log('Total records in jigsaw_puzzles: ${allData.length}');
      if (allData.isNotEmpty) {
        developer.log('First record: ${allData[0]}');
      }
    } on supabase.PostgrestException catch (e) {
      developer.log('PostgrestException: ${e.message}', error: e);
      developer.log('Error code: ${e.code}');
      developer.log('Error details: ${e.details}');
    } catch (e) {
      developer.log('General error: $e', error: e);
    }
  }

  Future<List<Map<String, dynamic>>?> getAllJigsawPuzzles() async {
    try {
      final response = await _supabaseClient.from('jigsaw_puzzles').select();

      developer.log('Retrieved ${response.length} jigsaw puzzles');
      return response;
    } on supabase.PostgrestException catch (e) {
      developer.log('Failed to fetch jigsaw puzzles: ${e.message}', error: e);
      return null;
    } catch (e) {
      developer.log('Unexpected error: $e', error: e);
      return null;
    }
  }
}
