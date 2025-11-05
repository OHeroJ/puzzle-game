import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../level_selection/jigsaw_info.dart';
import '../level_selection/piece_image.dart';

class LoadingSelectionScreen extends StatefulWidget {
  final JigsawInfo level;

  const LoadingSelectionScreen({super.key, required this.level});

  @override
  State<LoadingSelectionScreen> createState() => _LoadingSelectionScreenState();
}

//GoRouter.of(context).go('/play/loading/', extra: item);
class _LoadingSelectionScreenState extends State<LoadingSelectionScreen> {
  double p = 0;
  int date = 0;
  bool _unlocked = true; // 是否已通关（用于决定是否显示蒙版）
  GoRouter? _router; // 缓存路由器，避免在 dispose 后通过 context 查找

  @override
  void initState() {
    super.initState();
    _unlocked = widget.level.unlocked;
    date = DateTime.now().microsecondsSinceEpoch;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // 在进入 PlaySessionScreen 前的加载页即切换为横屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在依赖变更时缓存 GoRouter 引用，避免在组件已被 dispose 时再通过 context 查找
    _router = GoRouter.maybeOf(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 1.sw,
        height: 1.sh,
        child: Stack(children: [
          PieceImage(
            pictureUrl: widget.level.smallimage,
            unlocked: _unlocked,
          ),

          PieceImage(
            unlocked: _unlocked,
            pictureUrl: widget.level.image,
            progressIndicatorBuilder: (context, url, downloadProgress) {
              return Container();
            },
            progress: () {
              print("complete: $p");
              int now = DateTime.now().microsecondsSinceEpoch;
              print('now $now');
              print('date $date');
              print('diff ${now - date}');
              print("complete: 22");
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Future.delayed(const Duration(milliseconds: 1500), () async {
                  if (!mounted) return; // 如果组件已销毁则不再执行导航
                  _router?.pushReplacement('/play/session/', extra: widget.level);
                });
              });
            },
          ),
          // if (adsControllerAvailable) ...[
          //   Container(
          //     height: 80.h,
          //     color: Colors.white,
          //     child: Center(child: BannerAdWidget()),
          //   )
          // ],
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: 0.1.sh),
              width: 0.9.sw,
              child: Stack(alignment: Alignment.center, children: [
                Container(
                  height: 30.h,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                  ),
                ),
                Text(
                  "加载中...",
                )
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
