// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../style/palette.dart';
import 'jigsaw_info.dart';

class JigsawGridItem extends StatelessWidget {
  final JigsawInfo jigsaw;

  const JigsawGridItem({required this.jigsaw, super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return GestureDetector(
      onTap: () {
        // 使用jigsaw的gridSize作为ID传递
        context.push('/play/level/${jigsaw.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: palette.backgroundMenu.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: palette.primaryColor,
            width: 2.w,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 显示网格大小
            Text(
              '${jigsaw.gridSize}x${jigsaw.gridSize}',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: palette.textColor,
              ),
            ),
            SizedBox(height: 10.h),
            // 显示难度级别
            Text(
              '难度: ${jigsaw.difficulty}',
              style: TextStyle(
                fontSize: 16.sp,
                color: palette.textColor,
              ),
            ),
            SizedBox(height: 10.h),
            // 显示图片预览
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: palette.primaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.image,
                color: palette.textColor,
                size: 30.w,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
      case 2:
      case 3:
        return Colors.green;
      case 4:
      case 5:
        return Colors.orange;
      case 6:
      case 7:
        return Colors.red;
      default:
        return Colors.purple;
    }
  }
}
