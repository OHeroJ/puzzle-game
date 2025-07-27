// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../style/palette.dart';
import 'jigsaw_grid.dart';
import 'jigsaw_info.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  List<JigsawInfo> jigsaws = [];

  @override
  void initState() {
    super.initState();
    _loadJigsaws();
  }

  Future<void> _loadJigsaws() async {
    // 模拟加载拼图数据
    final List<JigsawInfo> loadedJigsaws = [
      JigsawInfo(
        'https://images.pexels.com/photos/1366957/pexels-photo-1366957.jpeg',
        'https://images.pexels.com/photos/1366957/pexels-photo-1366957.jpeg',
        'Mountain Landscape',
        3,
        'https://images.pexels.com/photos/1366957/pexels-photo-1366957.jpeg',
      ),
      JigsawInfo(
        'https://images.pexels.com/photos/247599/pexels-photo-247599.jpeg',
        'https://images.pexels.com/photos/247599/pexels-photo-247599.jpeg',
        'Forest Path',
        4,
        'https://images.pexels.com/photos/247599/pexels-photo-247599.jpeg',
      ),
    ];

    setState(() {
      jigsaws = loadedJigsaws;
    });
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
            child: JigsawGrid(
              jigsaws: jigsaws,
            ),
          ),
        ],
      ),
    );
  }
}