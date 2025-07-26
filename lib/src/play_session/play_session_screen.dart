// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
import 'package:url_launcher/url_launcher_string.dart';

import '../games_services/score.dart';
import '../settings/settings.dart';
import '../style/palette.dart';
import '../ranking/score_calculator.dart';
import '../ranking/ranking_manager.dart';
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

  late DateTime _startOfPlay;

  @override
  void initState() {
    super.initState();
    _startOfPlay = DateTime.now();
  }

  void playerWon() async {
    final gameDuration = DateTime.now().difference(_startOfPlay);
    
    // 获取游戏步数
    final gameWidget = context.read<GameWidget>();
    final jigsawGame = gameWidget.game as JigsawGame;
    final moves = jigsawGame.moves;
    
    // 计算分数
    final score = ScoreCalculator.calculateScore(
      time: gameDuration,
      moves: moves,
      difficulty: widget.level.gridSize, // 修复：使用gridSize而不是level
    );

    final settingsController = context.read<SettingsController>();
    if (settingsController.soundsOn.value) {
      jigsawGame.toggleMusic();
    }

    setState(() {
      _duringCelebration = true;
    });

    // 显示庆祝动画
    await Future.delayed(_preCelebrationDuration);
    // 修复：正确使用Lottie动画
    final lottieWidget = Lottie.asset('assets/lottie/win.json');
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: Container(
          width: 300.w,
          height: 300.h,
          child: lottieWidget,
        ),
      ),
    );

    // 提交分数到排行榜
    final rankingManager = context.read<RankingManager>();
    final success = await rankingManager.submitScore(score);
    
    if (!success) {
      _log.warning('Failed to submit score to ranking');
    }

    // 显示游戏结果
    if (mounted) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: 'Congratulations',
        desc: 'You solved the puzzle in ${Score(gameDuration).formattedTime} with $moves moves\nScore: $score',
        btnCancelOnPress: () {
          GoRouter.of(context).pop();
        },
        btnOkOnPress: () {
          GoRouter.of(context).pop();
        },
      ).show();
    }

    await Future.delayed(_celebrationDuration);
    if (mounted) {
      setState(() {
        _duringCelebration = false;
      });
    }
  }

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
            'Puzzle',
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
                    ),
                    isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: palette.primaryColor,
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showReset() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.scale,
      title: '重新开始',
      desc: '确定要重新开始吗？',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        // 修复：正确调用重置游戏方法
        final gameWidget = context.read<GameWidget>();
        final jigsawGame = gameWidget.game as JigsawGame;
        jigsawGame.resetGame();
        setState(() {
          _startOfPlay = DateTime.now();
        });
      },
    ).show();
  }

  showImage() async {
    final info = widget.level;
    final file = await DefaultCacheManager().getSingleFile(info.url);
    final image = Image.file(
      file as File,
      fit: BoxFit.contain,
    );
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: Container(
          width: 300.w,
          height: 300.h,
          child: image,
        ),
      ),
    );
  }
}