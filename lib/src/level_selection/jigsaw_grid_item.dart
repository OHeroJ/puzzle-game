import 'dart:ui' as ui;
import 'package:flutter/material.dart';
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
  }) : super(key: key);
  final JigsawInfo info;
  final GestureTapCallback? onTap;
  final bool locked;
  final bool showDelete;
  final VoidCallback? onDelete;

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
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(
                child: locked
                    ? ImageFiltered(
                        imageFilter:
                            ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: PieceImage(pictureUrl: info.smallimage),
                      )
                    : PieceImage(pictureUrl: info.smallimage),
              ),
              if (locked) ...[
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
              ],
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
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                  child: Text(
                    '@${info.photographer}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
