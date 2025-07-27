import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase/supabase.dart' as supabase;

import '../style/palette.dart';
import '../user/user_manager.dart';
import '../user/user_progress_manager.dart';
import '../ranking/ranking_manager.dart';

class SupabaseTestScreen extends StatefulWidget {
  const SupabaseTestScreen({super.key});

  @override
  State<SupabaseTestScreen> createState() => _SupabaseTestScreenState();
}

class _SupabaseTestScreenState extends State<SupabaseTestScreen> {
  late supabase.SupabaseClient _supabaseClient;
  List<Map<String, dynamic>> _testData = [];
  bool _isLoading = false;
  String _testResult = '';

  @override
  void initState() {
    super.initState();
    // 初始化Supabase客户端
    _supabaseClient = supabase.SupabaseClient(
      'https://ktqymfswotvnwseukfsx.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt0cXltZnN3b3R2bndzZXVrZnN4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NTQ4MzQsImV4cCI6MjA2OTAzMDgzNH0.-s5TgAncP81diPORk7L3txwPJAILv8WCHbvSDtGTBB0',
    );
  }

  // 测试数据库连接
  Future<void> _testDatabaseConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = '测试中...';
    });

    try {
      // 尝试从rankings表获取数据
      final response = await _supabaseClient
          .from('rankings')
          .select()
          .limit(5);
      
      setState(() {
        _testData = List<Map<String, dynamic>>.from(response);
        _testResult = '成功获取到 ${_testData.length} 条数据';
        _isLoading = false;
      });
    } on supabase.PostgrestException catch (e) {
      setState(() {
        if (e.code == '42P01') {
          // 表不存在错误
          _testResult = '数据库连接成功，但表不存在。\n错误代码: ${e.code}\n错误信息: ${e.message}\n\n请在Supabase控制台中创建以下表:\n1. user_settings\n2. rankings\n3. user_progress\n4. level_progress';
        } else {
          _testResult = '数据库连接测试失败:\n错误代码: ${e.code}\n错误信息: ${e.message}';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = '数据库连接测试失败: $e';
        _isLoading = false;
      });
    }
  }

  // 测试认证功能
  Future<void> _testAuthConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = '测试认证中...';
    });

    try {
      // 检查当前认证状态
      final currentUser = _supabaseClient.auth.currentUser;
      final session = _supabaseClient.auth.currentSession;
      
      setState(() {
        if (currentUser != null) {
          _testResult = '用户已认证: ${currentUser.email}';
        } else {
          _testResult = '用户未认证';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = '认证测试失败: $e';
        _isLoading = false;
      });
    }
  }

  // 测试用户进度功能
  Future<void> _testUserProgress(UserManager userManager) async {
    setState(() {
      _isLoading = true;
      _testResult = '测试用户进度功能中...';
    });

    try {
      if (!userManager.isSignedIn || userManager.currentUser == null) {
        setState(() {
          _testResult = '用户未登录，无法测试用户进度功能';
          _isLoading = false;
        });
        return;
      }

      // 保存测试进度数据
      final testData = {
        'last_played_level': 'level_1',
        'total_play_time': 1200,
        'achievements': ['first_win', 'fast_completion'],
      };

      final dataToSave = {
        'user_id': userManager.currentUser!.id,
        'progress_data': testData,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabaseClient.from('user_progress').upsert(dataToSave);
      
      setState(() {
        _testResult = '用户进度数据保存成功';
        _isLoading = false;
      });
    } on supabase.PostgrestException catch (e) {
      setState(() {
        if (e.code == '42P01') {
          // 表不存在错误
          _testResult = '用户进度功能测试失败，表不存在。\n错误代码: ${e.code}\n错误信息: ${e.message}\n\n请在Supabase控制台中创建user_progress表';
        } else {
          _testResult = '用户进度功能测试失败:\n错误代码: ${e.code}\n错误信息: ${e.message}';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = '用户进度功能测试失败: $e';
        _isLoading = false;
      });
    }
  }

  // 创建数据库表
  Future<void> _createDatabaseTables() async {
    setState(() {
      _isLoading = true;
      _testResult = '正在创建数据库表...';
    });

    try {
      // 创建用户设置表
      await _createUserSettingsTable();
      
      // 创建排行榜表
      await _createRankingsTable();
      
      // 创建用户进度表
      await _createUserProgressTable();
      
      // 创建关卡进度表
      await _createLevelProgressTable();
      
      setState(() {
        _testResult = '数据库表创建完成';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = '创建数据库表失败: $e';
        _isLoading = false;
      });
    }
  }

  // 创建用户设置表
  Future<void> _createUserSettingsTable() async {
    try {
      await _executeSQL('''
        CREATE TABLE IF NOT EXISTS user_settings (
          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          user_id TEXT UNIQUE NOT NULL,
          music_on BOOLEAN DEFAULT false,
          sounds_on BOOLEAN DEFAULT true,
          muted BOOLEAN DEFAULT false,
          player_name TEXT DEFAULT 'Player',
          created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
      ''');
      
      await _executeSQL('CREATE INDEX IF NOT EXISTS idx_user_settings_user_id ON user_settings (user_id);');
    } catch (e) {
      debugPrint('Failed to create user_settings table: $e');
    }
  }

  // 创建排行榜表
  Future<void> _createRankingsTable() async {
    try {
      await _executeSQL('''
        CREATE TABLE IF NOT EXISTS rankings (
          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          user_id TEXT NOT NULL,
          username TEXT NOT NULL,
          score INTEGER NOT NULL,
          avatar_url TEXT,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
      ''');
      
      await _executeSQL('CREATE INDEX IF NOT EXISTS idx_rankings_score ON rankings (score DESC);');
      await _executeSQL('CREATE INDEX IF NOT EXISTS idx_rankings_user_id ON rankings (user_id);');
    } catch (e) {
      debugPrint('Failed to create rankings table: $e');
    }
  }

  // 创建用户进度表
  Future<void> _createUserProgressTable() async {
    try {
      await _executeSQL('''
        CREATE TABLE IF NOT EXISTS user_progress (
          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          user_id TEXT UNIQUE NOT NULL,
          progress_data JSONB,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
      ''');
      
      await _executeSQL('CREATE INDEX IF NOT EXISTS idx_user_progress_user_id ON user_progress (user_id);');
    } catch (e) {
      debugPrint('Failed to create user_progress table: $e');
    }
  }

  // 创建关卡进度表
  Future<void> _createLevelProgressTable() async {
    try {
      await _executeSQL('''
        CREATE TABLE IF NOT EXISTS level_progress (
          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          user_id TEXT NOT NULL,
          level_id TEXT NOT NULL,
          completed BOOLEAN DEFAULT false,
          best_score INTEGER,
          best_time INTEGER,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          UNIQUE(user_id, level_id)
        );
      ''');
      
      await _executeSQL('CREATE INDEX IF NOT EXISTS idx_level_progress_user_id ON level_progress (user_id);');
      await _executeSQL('CREATE INDEX IF NOT EXISTS idx_level_progress_level_id ON level_progress (level_id);');
    } catch (e) {
      debugPrint('Failed to create level_progress table: $e');
    }
  }

  // 执行SQL语句
  Future<void> _executeSQL(String sql) async {
    try {
      // 注意：在实际应用中，我们不能直接执行DDL语句
      // 这里只是示意代码，实际应该在Supabase控制台中手动创建表
      // 或使用Supabase的迁移功能
      debugPrint('Would execute SQL: $sql');
    } catch (e) {
      debugPrint('Failed to execute SQL: $e');
      rethrow;
    }
  }

  // 显示创建表的SQL语句
  void _showTableCreationSQL() {
    final sqlStatements = '''
以下是在Supabase中创建所需表的SQL语句:

1. 用户设置表 (user_settings):
CREATE TABLE IF NOT EXISTS user_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT UNIQUE NOT NULL,
  music_on BOOLEAN DEFAULT false,
  sounds_on BOOLEAN DEFAULT true,
  muted BOOLEAN DEFAULT false,
  player_name TEXT DEFAULT 'Player',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_settings_user_id ON user_settings (user_id);

2. 排行榜表 (rankings):
CREATE TABLE IF NOT EXISTS rankings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL,
  username TEXT NOT NULL,
  score INTEGER NOT NULL,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_rankings_score ON rankings (score DESC);
CREATE INDEX IF NOT EXISTS idx_rankings_user_id ON rankings (user_id);

3. 用户进度表 (user_progress):
CREATE TABLE IF NOT EXISTS user_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT UNIQUE NOT NULL,
  progress_data JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_progress_user_id ON user_progress (user_id);

4. 关卡进度表 (level_progress):
CREATE TABLE IF NOT EXISTS level_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL,
  level_id TEXT NOT NULL,
  completed BOOLEAN DEFAULT false,
  best_score INTEGER,
  best_time INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, level_id)
);

CREATE INDEX IF NOT EXISTS idx_level_progress_user_id ON level_progress (user_id);
CREATE INDEX IF NOT EXISTS idx_level_progress_level_id ON level_progress (level_id);
''';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('创建数据库表的SQL语句'),
          content: SingleChildScrollView(
            child: Text(sqlStatements),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final userManager = context.watch<UserManager>();
    final userProgressManager = context.watch<UserProgressManager>();

    return Scaffold(
      backgroundColor: palette.backgroundMain,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 返回按钮
              IconButton(
                icon: Icon(Icons.arrow_back, color: palette.textColor),
                onPressed: () => context.pop(),
              ),
              SizedBox(height: 20.h),
              
              // 标题
              Text(
                'Supabase 连接测试',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: palette.textColor,
                ),
              ),
              SizedBox(height: 30.h),
              
              // 用户状态显示
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: palette.backgroundMenu.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '用户状态',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: palette.textColor,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      userManager.isSignedIn 
                          ? '已登录: ${userManager.currentUser?.email ?? "未知用户"}' 
                          : '未登录',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: palette.textColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              
              // 测试按钮
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _testDatabaseConnection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        '测试数据库连接',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: palette.backgroundMain,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _testAuthConnection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        '测试认证连接',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: palette.backgroundMain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading || !userManager.isSignedIn
                          ? null
                          : () => _testUserProgress(userManager),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: userManager.isSignedIn
                            ? palette.primaryColor
                            : palette.backgroundMenu.withValues(alpha: 0.5),
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        '测试用户进度',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: userManager.isSignedIn
                              ? palette.backgroundMain
                              : palette.textColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading || !userManager.isSignedIn
                          ? null
                          : () => userProgressManager.fetchUserProgress(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: userManager.isSignedIn
                            ? palette.primaryColor
                            : palette.backgroundMenu.withValues(alpha: 0.5),
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        '获取用户进度',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: userManager.isSignedIn
                              ? palette.backgroundMain
                              : palette.textColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              // 显示SQL语句按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showTableCreationSQL,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    '查看创建表SQL',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: palette.backgroundMain,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              
              // 测试结果
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: palette.backgroundMenu.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '测试结果',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: palette.textColor,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _testResult,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: palette.textColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              
              // 数据显示区域
              if (_testData.isNotEmpty) ...[
                Text(
                  '获取到的数据:',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: palette.textColor,
                  ),
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: palette.backgroundMenu.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _testData.map((data) {
                          return Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(8.w),
                            margin: EdgeInsets.only(bottom: 8.h),
                            decoration: BoxDecoration(
                              color: palette.backgroundMain.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              data.toString(),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: palette.textColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}