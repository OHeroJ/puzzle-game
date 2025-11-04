import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:puzzle/src/level_selection/jigsaw_info.dart';
import 'package:puzzle/src/level_selection/piece_image.dart';
import 'package:provider/provider.dart';

import '../style/palette.dart';

class JigsawGridItem extends StatelessWidget {
  const JigsawGridItem({
    required this.info,
    Key? key,
    this.onTap,
    this.locked = false,
    this.showDelete = false,
    this.onDelete,
    this.onViewHistory,
  }) : super(key: key);
  final JigsawInfo info;
  final GestureTapCallback? onTap;
  final bool locked;
  final bool showDelete;
  final VoidCallback? onDelete;
  final VoidCallback? onViewHistory;

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 顶部大图，参考历史页使用 16:9 比例
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: PieceImage(
                      pictureUrl: info.smallimage,
                      unlocked: !locked,
                    ),
                  ),
                  if (onViewHistory != null)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onViewHistory,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.history,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (locked)
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: true,
                        child: Center(
                          child: Icon(
                            Icons.lock,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  if (showDelete)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onDelete,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.delete,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // 底部信息与按钮区
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 不显示图片名称
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 8.w,
                      children: [
                        Chip(
                          label: Text(
                            info.photographer.isNotEmpty
                                ? info.photographer
                                : '未知分类',
                            style: TextStyle(color: palette.textColor),
                          ),
                          backgroundColor: palette.lightGray,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        Chip(
                          label: Text(
                            '${info.gridSize}×${info.gridSize}',
                            style: TextStyle(color: palette.textColor),
                          ),
                          backgroundColor: palette.lightGray,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        if (locked)
                          Chip(
                            label: Text(
                              '未解锁',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor:
                                Colors.orange.withValues(alpha: 0.1),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: palette.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: const Text('开始'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
