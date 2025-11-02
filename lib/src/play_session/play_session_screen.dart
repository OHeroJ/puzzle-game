// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ui' as ui;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:file/file.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:puzzle/src/level_selection/jigsaw_info.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

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

  static const _celebrationDuration = Duration(milliseconds: 2000);

  static const _preCelebrationDuration = Duration(milliseconds: 500);

  bool _duringCelebration = false;
  bool isLoading = true;
  bool _sessionCompleted = false;

  late DateTime _startOfPlay;

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
              fontSize: 28.sp,
              color: palette.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
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
        body: Column(
          children: [
            Expanded(
              child: Container(
                child: Stack(
                  children: [
                    GameWidget(
                      loadingBuilder: (context) => Center(
                        child: CircularProgressIndicator(
                          color: palette.primaryColor,
                        ),
                      ),
                      game: JigsawGame(
                        widget.level,
                        settingsController.soundsOn.value,
                        () {
                          playerWon();
                        },
                      ),
                      backgroundBuilder: (context) =>
                          Container(color: palette.backgroundMain),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _startOfPlay = DateTime.now();

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

  void showImage() async {
    File file = await DefaultCacheManager().getSingleFile(widget.level.image);
    final locked = !_sessionCompleted;
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
                child: locked
                    ? ImageFiltered(
                        imageFilter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Image.file(file, fit: BoxFit.contain),
                      )
                    : Image.file(file, fit: BoxFit.contain),
              ),
              if (locked)
                Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.85)),
                ),
              if (locked)
                Center(
                  child: Icon(
                    Icons.lock,
                    size: 64.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
            ],
          ),
        ),
      ),
    ).show();
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

    // 标记本次会话完成，用于去掉原图蒙层
    setState(() {
      _sessionCompleted = true;
    });

    // 持久化通关历史（用时等）
    final elapsedMs = DateTime.now().difference(_startOfPlay).inMilliseconds;
    await PuzzleHistoryStore().completePuzzle(
      widget.level.id,
      elapsedMs: elapsedMs,
    );

    // GoRouter.of(context).go('/play/won', extra: {'score': score});
  }

  Future<File> _getImage() async {
    File file = await DefaultCacheManager().getSingleFile(widget.level.image);
    return file;
  }
}
