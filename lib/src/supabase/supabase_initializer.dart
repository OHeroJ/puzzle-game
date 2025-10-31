import 'package:supabase/supabase.dart' as supabase;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../config/supabase_config.dart';

class SupabaseInitializer {
  final supabase.SupabaseClient _supabaseClient;

  SupabaseInitializer() : _supabaseClient = supabase.Supabase.instance.client;

  /// 初始化Supabase客户端
  Future<void> initialize() async {
    try {
      // Supabase已经在main.dart中初始化，这里可以进行额外的设置
      print('Supabase client initialized successfully');
    } catch (e) {
      print('Failed to initialize Supabase client: $e');
    }
  }

  /// 获取创建表的SQL语句
  String getCreateTablesSQL() {
    return '''
-- 创建用户设置表
CREATE TABLE IF NOT EXISTS user_settings (
  user_id TEXT PRIMARY KEY,
  player_name TEXT DEFAULT 'Player',
  music_on BOOLEAN DEFAULT true,
  sounds_on BOOLEAN DEFAULT true,
  muted BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 创建排行榜表
CREATE TABLE IF NOT EXISTS rankings (
  id SERIAL PRIMARY KEY,
  user_id TEXT NOT NULL,
  username TEXT NOT NULL,
  score INTEGER NOT NULL,
  avatar_url TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 创建关卡进度表
CREATE TABLE IF NOT EXISTS level_progress (
  id SERIAL PRIMARY KEY,
  user_id TEXT NOT NULL,
  level INTEGER NOT NULL,
  moves INTEGER NOT NULL,
  time INTEGER NOT NULL,
  score INTEGER NOT NULL,
  completed_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, level)
);

-- 为排行榜表创建索引
CREATE INDEX IF NOT EXISTS idx_rankings_score ON rankings(score DESC);
CREATE INDEX IF NOT EXISTS idx_rankings_user_id ON rankings(user_id);
CREATE INDEX IF NOT EXISTS idx_level_progress_user_id ON level_progress(user_id);
''';
  }
}
