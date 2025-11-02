import 'dart:convert';
import 'dart:io' show File;
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../style/palette.dart';

typedef DoubleCallback = void Function(double? p);

class PieceImage extends StatelessWidget {
  const PieceImage({
    super.key,
    required this.pictureUrl,
    this.progress,
    this.progressIndicatorBuilder,
    this.unlocked = true,
  });

  final bool unlocked;
  final String pictureUrl;
  final Function? progress;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    // 如果是本地资源路径，使用 AssetImage 加载
    if (pictureUrl.startsWith('assets/')) {
      progress?.call();
      return _buildResult(Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage(pictureUrl),
            fit: BoxFit.cover,
          ),
        ),
      ));
    }

    // data URI (base64)
    if (pictureUrl.startsWith('data:image/')) {
      try {
        final base64Part = pictureUrl.split(',').last;
        final bytes = base64Decode(base64Part);
        progress?.call();
        return _buildResult(Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image:
                DecorationImage(image: MemoryImage(bytes), fit: BoxFit.cover),
          ),
        ));
      } catch (_) {
        return _buildResult(Icon(Icons.error));
      }
    }

    // 本地文件路径（绝对路径或 file://）
    if (pictureUrl.startsWith('file://') || pictureUrl.startsWith('/')) {
      final path = pictureUrl.startsWith('file://')
          ? pictureUrl.replaceFirst('file://', '')
          : pictureUrl;
      final file = File(path);
      if (file.existsSync()) {
        progress?.call();
        return _buildResult(Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
          ),
        ));
      } else {
        return _buildResult(Icon(Icons.error));
      }
    }

    // 默认使用网络图片加载
    return _buildResult(
      CachedNetworkImage(
      imageUrl: pictureUrl,
      imageBuilder: (context, imageProvider) {
        progress?.call();
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        );
      },
      progressIndicatorBuilder: progressIndicatorBuilder ??
          (context, url, downloadProgress) {
            return Center(
                child: CircularProgressIndicator(
              color: palette.textColor,
              value: downloadProgress.progress,
            ));
          },
      errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }

  Widget _buildResult(Widget result) {
    if (unlocked) {
      return result;
    }
    return Stack(
      children: [
        result,
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30), // 模糊程度（值越大越模糊）
            child: Container(
              color: Colors.black12, // 可选：增加蒙版颜色叠加
            ),
          ),
        )
      ],
    );
  }
}
