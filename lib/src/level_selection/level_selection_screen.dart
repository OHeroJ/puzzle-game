// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../style/palette.dart';
import 'jigsaw_grid.dart';
import 'jigsaw_info.dart';
import 'jigsaw_service.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  List<JigsawInfo> jigsaws = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadJigsaws();
  }

  Future<void> _loadJigsaws() async {
    try {
      // 获取Supabase客户端
      final supabaseClient = supabase.Supabase.instance.client;
      
      // 创建拼图服务实例
      final jigsawService = JigsawService(supabaseClient);
      
      // 从Supabase获取拼图数据
      final loadedJigsaws = await jigsawService.getJigsawInfos();

      setState(() {
        jigsaws = loadedJigsaws;
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '加载拼图数据失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '选择关卡',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: palette.textColor,
          ),
        ),
        backgroundColor: palette.backgroundMain,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: palette.textColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // 顶部说明文字
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '选择一个拼图',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: palette.textColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '挑战不同难度的拼图游戏',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: palette.textColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          // 关卡选择区域
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        SizedBox(height: 16.h),
                        Text(
                          '正在加载拼图...',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: palette.textColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: palette.textColor,
                              size: 48.w,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              _errorMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: palette.textColor,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: _loadJigsaws,
                              child: Text(
                                '重新加载',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: palette.backgroundMain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : jigsaws.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.hourglass_empty,
                                  color: palette.textColor,
                                  size: 48.w,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  '暂无拼图数据',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: palette.textColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : JigsawGrid(
                            jigsaws: jigsaws,
                          ),
          ),
        ],
      ),
    );
  }
}