import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../style/palette.dart';
import 'jigsaw_grid_item.dart';
import 'jigsaw_info.dart';

class JigsawGrid extends StatelessWidget {
  final List<JigsawInfo> jigsaws;

  const JigsawGrid({super.key, required this.jigsaws});

  @override
  Widget build(BuildContext context) {
    // 修复未使用变量警告
    // final palette = context.watch<Palette>();

    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.8,
      ),
      itemCount: jigsaws.length,
      itemBuilder: (context, index) {
        return JigsawGridItem(jigsaw: jigsaws[index]);
      },
    );
  }
}
