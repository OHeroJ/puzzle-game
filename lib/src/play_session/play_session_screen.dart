// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
// import 'dart:ui' as ui;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:puzzle/src/level_selection/jigsaw_info.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'jigsaw/grid_painter.dart';

import '../games_services/score.dart';
import '../history/puzzle_history.dart';
import '../settings/settings.dart';
import '../style/palette.dart';
import 'jigsaw/jigsaw_game.dart';

class PlaySessionScreen extends StatefulWidget {
  final JigsawInfo level;

  const PlaySessionScreen(this.level, {super.key});

  @override
  State<PlaySessionScreen> createState() => _PlaySessionScreenState();
}

class _PlaySessionScreenState extends State<PlaySessionScreen> {
  static final _log = Logger('PlaySessionScreen');

  bool _duringCelebration = false;
  bool isLoading = true;
  bool _showGrid = false;

  late DateTime _startOfPlay;
  late final JigsawGame _game;

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final settingsController = context.watch<SettingsController>();
    return IgnorePointer(
      ignoring: _duringCelebration,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: BackButton(
            onPressed: () {
              GoRouter.of(context).pop();
            },
          ),
          centerTitle: true,
          backgroundColor: palette.backgroundMain,
          title: Text(
            '拼图',
            style: TextStyle(
              fontSize: 28,
              color: palette.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() => _showGrid = !_showGrid);
              },
              icon: Icon(
                _showGrid ? Icons.grid_on : Icons.grid_off,
                size: 26,
                color: palette.textColor,
              ),
              tooltip: _showGrid ? '隐藏网格' : '显示网格',
            ),
            IconButton(
              onPressed: () {
                _showBackgroundPicker(settingsController, palette);
              },
              icon:
                  Icon(Icons.color_lens, size: 28.sp, color: palette.textColor),
              tooltip: '拼图背景色',
            ),
            IconButton(
              onPressed: () {
                showReset();
              },
              icon: Icon(Icons.refresh, size: 30.sp, color: palette.textColor),
            ),
            IconButton(
              onPressed: () {
                showImage();
              },
              icon: Icon(Icons.image, size: 30.sp, color: palette.textColor),
            ),
            SizedBox(width: 16.w),
          ],
        ),
        body: ValueListenableBuilder<Color>(
                valueListenable: settingsController.gameBackgroundColor,
                builder: (context, bg, _) => GameWidget(
                  loadingBuilder: (context) => Center(
                    child: CircularProgressIndicator(
                color: palette.primaryColor,
                    ),
                  ),
                  game: _game,
            backgroundBuilder: (context) => _showGrid
                ? CustomPaint(
                    painter: JigsawGridPainter(
                      backgroundColor: bg,
                      gridSize: widget.level.gridSize,
                      lineColor: palette.textColor,
                    ),
                    size: Size.infinite,
                    isComplex: true,
                  )
                : Container(color: bg),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // 游戏页进入时隐藏状态栏与导航栏，沉浸式体验
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _startOfPlay = DateTime.now();

    // 保持 Game 实例稳定，避免因界面重建而重置拼图进度
    final settingsController =
        Provider.of<SettingsController>(context, listen: false);
    _game = JigsawGame(
      widget.level,
      settingsController.soundsOn.value,
      () {
        playerWon();
      },
    );

    // 记录开始一局拼图到历史
    PuzzleHistoryStore().startPuzzle(
      widget.level,
      gridSize: widget.level.gridSize,
      startedAt: _startOfPlay,
    );

    // Preload ad for the win screen.
    // final adsRemoved =
    //     context.read<InAppPurchaseController?>()?.adRemoval.active ?? false;
    // if (!adsRemoved) {
    //   final adsController = context.read<AdsController?>();
    //   adsController?.preloadAd();
    // }
  }

  @override
  void dispose() {
    // 退出游戏页时恢复显示状态栏与导航栏
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  void showReset() async {
    AwesomeDialog(
      width: 400.h,
      dialogBackgroundColor: Palette().backgroundMain,
      btnOkColor: Palette().primaryColor,
      context: context,
      animType: AnimType.scale,
      dialogType: DialogType.info,
      headerAnimationLoop: false,
      title: '重置拼图？',
      btnOkText: '重置',
      btnCancelText: '取消',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        setState(() {});
      },
    ).show();
  }

  Future<void> showImage() async {
    final imageProvider = await _getImage(widget.level.image);
    if (imageProvider == null) return;

    // final locked = !_sessionCompleted;
    AwesomeDialog(
      width: 400.h,
      context: context,
      animType: AnimType.scale,
      headerAnimationLoop: false,
      dialogType: DialogType.noHeader,
      body: Center(
        child: Container(
          width: 400.h,
          height: 300.h,
          padding: EdgeInsets.all(20.h),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r)),
          child: Stack(
            children: [
              Positioned.fill(
                  child: Image(image: imageProvider, fit: BoxFit.contain)),
            ],
          ),
        ),
      ),
    ).show();
  }

  /// 根据路径格式返回对应的 ImageProvider：
  /// - `assets/` 开头：`AssetImage`
  /// - `http` 或 `https` 开头：`NetworkImage`（通过缓存）
  /// - 其他：`FileImage`（用于本地文件）
  Future<ImageProvider?> _getImage(String path) async {
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else if (path.startsWith('http')) {
      // 网络图片使用缓存，避免重复下载
      final file = await DefaultCacheManager().getSingleFile(path);
      return FileImage(file);
    } else {
      // 默认按本地文件处理
      final file = File(path);
      if (await file.exists()) {
        return FileImage(file);
      } else {
        _log.warning('本地图片不存在: $path');
        return null;
      }
    }
  }

  void _showBackgroundPicker(SettingsController settings, Palette palette) {
    final options = <Color>[
      const Color(0xFFF0F2F5), // 默认浅灰
      Colors.white,
      Colors.black12,
      const Color(0xFFE3F2FD), // 淡蓝
      const Color(0xFFFFF3E0), // 淡橙
      const Color(0xFFE8F5E9), // 淡绿
    ];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: palette.backgroundMain,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '选择拼图背景色',
                style: TextStyle(
                  color: palette.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: options.map((c) {
                  final selected = c == settings.gameBackgroundColor.value;
                  return ChoiceChip(
                    label: Container(
                      width: 24,
                      height: 16,
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black12),
                      ),
                    ),
                    selected: selected,
                    selectedColor: c,
                    backgroundColor: c,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onSelected: (_) {
                      settings.setGameBackgroundColor(c);
                      Navigator.of(ctx).pop();
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> playerWon() async {
    //   _log.info('Level ${widget.level.number} won');
    //
    final score = Score(DateTime.now().difference(_startOfPlay));
    AwesomeDialog(
      width: 400.h,
      bodyHeaderDistance: 0,
      padding: const EdgeInsets.all(0),
      dismissOnTouchOutside: false,
      context: context,
      animType: AnimType.scale,
      headerAnimationLoop: false,
      dialogType: DialogType.success,
      body: Container(
        width: 400.h,
        height: 0.3.sh,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 0.2.sh,
              child: Center(child: Lottie.asset('assets/lottie/win.json')),
            ),
            Text(
              '用时：${score.formattedTime}',
              style: TextStyle(
                fontSize: 16.sp,
                color: Palette().textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      dialogBackgroundColor: Palette().backgroundMain,
      btnOkColor: Palette().primaryColor,
      btnOkText: "继续",
      btnOkOnPress: () {
        GoRouter.of(context).pop();
      },
    ).show();

    // 持久化通关历史（用时等）
    final elapsedMs = DateTime.now().difference(_startOfPlay).inMilliseconds;
    await PuzzleHistoryStore().completePuzzle(
      widget.level.id,
      elapsedMs: elapsedMs,
    );
  }
}
