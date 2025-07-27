import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../settings.dart';
import 'settings_persistence.dart';

class SupabaseSettingsPersistence implements SettingsPersistence {
  final supabase.SupabaseClient _supabaseClient;
  final String userId;

  SupabaseSettingsPersistence({required supabase.SupabaseClient supabaseClient, required this.userId})
      : _supabaseClient = supabaseClient;

  @override
  Future<bool> getMusicOn() async {
    try {
      final response = await _supabaseClient
          .from('user_settings')
          .select('music_on')
          .eq('user_id', userId)
          .single();

      return response['music_on'] as bool? ?? SettingsController.defaultMusicOn;
    } on supabase.PostgrestException catch (e) {
      // 处理数据库异常
      if (e.code == '42P01') {
        // 表不存在
        print('Database table "user_settings" does not exist: ${e.message}');
      } else {
        print('Failed to get music setting: ${e.message}');
      }
      return SettingsController.defaultMusicOn;
    } catch (e) {
      // 处理其他异常
      print('Failed to get music setting: $e');
      return SettingsController.defaultMusicOn;
    }
  }

  @override
  Future<bool> getSoundsOn() async {
    try {
      final response = await _supabaseClient
          .from('user_settings')
          .select('sounds_on')
          .eq('user_id', userId)
          .single();

      return response['sounds_on'] as bool? ?? SettingsController.defaultSoundsOn;
    } on supabase.PostgrestException catch (e) {
      // 处理数据库异常
      if (e.code == '42P01') {
        // 表不存在
        print('Database table "user_settings" does not exist: ${e.message}');
      } else {
        print('Failed to get sounds setting: ${e.message}');
      }
      return SettingsController.defaultSoundsOn;
    } catch (e) {
      // 处理其他异常
      print('Failed to get sounds setting: $e');
      return SettingsController.defaultSoundsOn;
    }
  }

  @override
  Future<bool> getMuted({required bool defaultValue}) async {
    try {
      final response = await _supabaseClient
          .from('user_settings')
          .select('muted')
          .eq('user_id', userId)
          .single();

      return response['muted'] as bool? ?? defaultValue;
    } on supabase.PostgrestException catch (e) {
      // 处理数据库异常
      if (e.code == '42P01') {
        // 表不存在
        print('Database table "user_settings" does not exist: ${e.message}');
      } else {
        print('Failed to get muted setting: ${e.message}');
      }
      return defaultValue;
    } catch (e) {
      // 处理其他异常
      print('Failed to get muted setting: $e');
      return defaultValue;
    }
  }

  @override
  Future<String> getPlayerName() async {
    try {
      final response = await _supabaseClient
          .from('user_settings')
          .select('player_name')
          .eq('user_id', userId)
          .single();

      return response['player_name'] as String? ?? SettingsController.defaultPlayerName;
    } on supabase.PostgrestException catch (e) {
      // 处理数据库异常
      if (e.code == '42P01') {
        // 表不存在
        print('Database table "user_settings" does not exist: ${e.message}');
      } else {
        print('Failed to get player name setting: ${e.message}');
      }
      return SettingsController.defaultPlayerName;
    } catch (e) {
      // 处理其他异常
      print('Failed to get player name setting: $e');
      return SettingsController.defaultPlayerName;
    }
  }
  
  @override
  Future<AppTheme> getTheme() async {
    try {
      final response = await _supabaseClient
          .from('user_settings')
          .select('theme')
          .eq('user_id', userId)
          .single();

      final themeString = response['theme'] as String? ?? 'light';
      return themeString == 'dark' ? AppTheme.dark : AppTheme.light;
    } on supabase.PostgrestException catch (e) {
      // 处理数据库异常
      if (e.code == '42P01') {
        // 表不存在
        print('Database table "user_settings" does not exist: ${e.message}');
      } else {
        print('Failed to get theme setting: ${e.message}');
      }
      return SettingsController.defaultTheme;
    } catch (e) {
      // 处理其他异常
      print('Failed to get theme setting: $e');
      return SettingsController.defaultTheme;
    }
  }

  @override
  Future<void> saveMusicOn(bool value) async {
    try {
      await _supabaseClient.from('user_settings').upsert({
        'user_id': userId,
        'music_on': value,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } on supabase.PostgrestException catch (e) {
      // 处理数据库异常
      if (e.code == '42P01') {
        // 表不存在
        print('Database table "user_settings" does not exist: ${e.message}');
      } else {
        print('Failed to save music setting: ${e.message}');
      }
    } catch (e) {
      // 处理其他异常
      print('Failed to save music setting: $e');
    }
  }

  @override
  Future<void> saveSoundsOn(bool value) async {
    try {
      await _supabaseClient.from('user_settings').upsert({
        'user_id': userId,
        'sounds_on': value,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } on supabase.PostgrestException catch (e) {
      // 处理数据库异常
      if (e.code == '42P01') {
        // 表不存在
        print('Database table "user_settings" does not exist: ${e.message}');
      } else {
        print('Failed to save sounds setting: ${e.message}');
      }
    } catch (e) {
      // 处理其他异常
      print('Failed to save sounds setting: $e');
    }
  }

  @override
  Future<void> saveMuted(bool value) async {
    try {
      await _supabaseClient.from('user_settings').upsert({
        'user_id': userId,
        'muted': value,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } on supabase.PostgrestException catch (e) {
      // 处理数据库异常
      if (e.code == '42P01') {
        // 表不存在
        print('Database table "user_settings" does not exist: ${e.message}');
      } else {
        print('Failed to save muted setting: ${e.message}');
      }
    } catch (e) {
      // 处理其他异常
      print('Failed to save muted setting: $e');
    }
  }

  @override
  Future<void> savePlayerName(String value) async {
    try {
      await _supabaseClient.from('user_settings').upsert({
        'user_id': userId,
        'player_name': value,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } on supabase.PostgrestException catch (e) {
      // 处理数据库异常
      if (e.code == '42P01') {
        // 表不存在
        print('Database table "user_settings" does not exist: ${e.message}');
      } else {
        print('Failed to save player name setting: ${e.message}');
      }
    } catch (e) {
      // 处理其他异常
      print('Failed to save player name setting: $e');
    }
  }
  
  @override
  Future<void> saveTheme(AppTheme theme) async {
    try {
      await _supabaseClient.from('user_settings').upsert({
        'user_id': userId,
        'theme': theme == AppTheme.dark ? 'dark' : 'light',
        'updated_at': DateTime.now().toIso8601String(),
      });
    } on supabase.PostgrestException catch (e) {
      // 处理数据库异常
      if (e.code == '42P01') {
        // 表不存在
        print('Database table "user_settings" does not exist: ${e.message}');
      } else {
        print('Failed to save theme setting: ${e.message}');
      }
    } catch (e) {
      // 处理其他异常
      print('Failed to save theme setting: $e');
    }
  }
}