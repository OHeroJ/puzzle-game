import 'package:flutter/material.dart';
import 'package:flutter_jigsaw_puzzle/src/level_selection/jigsaw_info.dart';
import 'package:flutter_jigsaw_puzzle/src/level_selection/piece_image.dart';
import 'package:provider/provider.dart';

import '../style/palette.dart';

class JigsawGridItem extends StatelessWidget {
  const JigsawGridItem({
    required this.info,
    Key? key,
    this.onTap,
  }) : super(key: key);
  final JigsawInfo info;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                child: PieceImage(pictureUrl: info.smallimage),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: Text(
                    '@${info.photographer}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
