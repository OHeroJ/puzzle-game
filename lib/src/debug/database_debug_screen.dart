import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

import '../style/palette.dart';

class DatabaseDebugScreen extends StatefulWidget {
  const DatabaseDebugScreen({super.key});

  @override
  State<DatabaseDebugScreen> createState() => _DatabaseDebugScreenState();
}

class _DatabaseDebugScreenState extends State<DatabaseDebugScreen> {
  String _debugOutput = '点击"检查数据库"按钮开始调试';
  bool _isLoading = false;

  Future<void> _checkDatabaseStructure() async {
    setState(() {
      _isLoading = true;
      _debugOutput = '正在检查数据库结构...';
    });

    try {
      final supabaseClient = supabase.Supabase.instance.client;
      
      // 1. 检查用户认证状态
      final currentUser = supabaseClient.auth.currentUser;
      String authInfo = '用户认证状态: ${currentUser != null ? "已登录 (ID: ${currentUser.id})" : "未登录"}\n\n';
      
      // 2. 检查表是否存在
      String tableCheck = '检查表是否存在:\n';
      try {
        final tableResponse = await supabaseClient
            .from('jigsaw_puzzles')
            .select()
            .limit(1);
        tableCheck += '✓ jigsaw_puzzles 表存在\n';
      } on supabase.PostgrestException catch (e) {
        tableCheck += '✗ jigsaw_puzzles 表不存在或无法访问: ${e.message}\n';
        if (e.code != null) {
          tableCheck += '  错误代码: ${e.code}\n';
        }
      }
      
      // 3. 尝试获取表结构信息
      String tableInfo = '\n表数据详情:\n';
      try {
        final dataResponse = await supabaseClient
            .from('jigsaw_puzzles')
            .select()
            .limit(5);
        
        tableInfo += '成功获取到 ${dataResponse.length} 条记录\n';
        if (dataResponse.isNotEmpty) {
          tableInfo += '第一条记录: ${dataResponse[0]}\n';
          
          // 检查字段
          final firstRecord = dataResponse[0];
          tableInfo += '\n字段检查:\n';
          tableInfo += '- id: ${firstRecord['id'] ?? '缺失'}\n';
          tableInfo += '- title: ${firstRecord['title'] ?? '缺失'}\n';
          tableInfo += '- image_url: ${firstRecord['image_url'] ?? '缺失'}\n';
          tableInfo += '- small_image_url: ${firstRecord['small_image_url'] ?? '缺失'}\n';
          tableInfo += '- grid_size: ${firstRecord['grid_size'] ?? '缺失'}\n';
          tableInfo += '- difficulty_level: ${firstRecord['difficulty_level'] ?? '缺失'}\n';
          tableInfo += '- photographer: ${firstRecord['photographer'] ?? '缺失'}\n';
        }
      } on supabase.PostgrestException catch (e) {
        tableInfo += '获取表数据失败: ${e.message}\n';
        if (e.code != null) {
          tableInfo += '  错误代码: ${e.code}\n';
        }
      }
      
      // 4. 检查其他可能的表
      String otherTables = '\n检查其他可能的表:\n';
      List<String> possibleTables = ['puzzles', 'jigsaw', 'games'];
      for (String tableName in possibleTables) {
        try {
          final response = await supabaseClient
              .from(tableName)
              .select()
              .limit(1);
          otherTables += '✓ $tableName 表存在 (${response.length} 条记录)\n';
        } on supabase.PostgrestException catch (e) {
          if (e.code == '42P01') {
            otherTables += '✗ $tableName 表不存在\n';
          } else {
            otherTables += '✗ $tableName 表访问失败: ${e.message}\n';
          }
        }
      }
      
      setState(() {
        _debugOutput = authInfo + tableCheck + tableInfo + otherTables;
        _isLoading = false;
      });
      
    } catch (e, stackTrace) {
      developer.log('Database debug error', error: e, stackTrace: stackTrace);
      setState(() {
        _debugOutput = '调试过程中发生错误: $e\n\n$stackTrace';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '数据库调试工具',
          style: TextStyle(color: palette.textColor),
        ),
        backgroundColor: palette.backgroundMain,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _checkDatabaseStructure,
              child: _isLoading 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2)
                  )
                : const Text('检查数据库'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: palette.backgroundMenu.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _debugOutput,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: palette.textColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}