// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flame/game.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../games_services/score.dart';
import '../level_selection/jigsaw_info.dart';
import '../settings/settings.dart';
import '../style/palette.dart';
import 'jigsaw/jigsaw_game.dart';

class PlaySessionScreen extends StatefulWidget {
  final int level;

  const PlaySessionScreen({required this.level, super.key});

  @override
  State<PlaySessionScreen> createState() => _PlaySessionScreenState();
}

class _PlaySessionScreenState extends State<PlaySessionScreen> {
  late JigsawGame _game;

  @override
  void initState() {
    super.initState();
    final jigsawInfo = JigsawInfo.getJigsawInfo(widget.level.toString());
    _game = JigsawGame(
      jigsawInfo,
      true, // 默认开启音乐
      _onGameEnd, // 传递游戏结束回调
    );
  }

  void _onGameEnd(dynamic score) {
    final audioController = context.read<AudioController>();
    final settings = context.read<SettingsController>();
    final palette = context.read<Palette>();

    audioController.playSfx(SfxType.victory);

    // 显示游戏结束对话框
    showDialog(
      context: context,
      builder: (context) => _buildGameEndDialog(score as Score, palette),
    );
  }

  Widget _buildGameEndDialog(Score score, Palette palette) {
    final jigsawInfo = JigsawInfo.getJigsawInfo(widget.level.toString());
    
    return AlertDialog(
      backgroundColor: palette.backgroundMain,
      title: Text(
        '恭喜!',
        style: TextStyle(color: palette.textColor),
      ),
      content: Text(
        '你完成了${jigsawInfo.name}拼图!\n用时: ${score.formattedTime}',
        style: TextStyle(color: palette.textColor),
      ),
      actions: [
        TextButton(
          onPressed: () {
            GoRouter.of(context).pop(); // 关闭对话框
            setState(() {
              final jigsawInfo = JigsawInfo.getJigsawInfo(widget.level.toString());
              _game = JigsawGame(
                jigsawInfo,
                true, // 默认开启音乐
                _onGameEnd, // 传递游戏结束回调
              );
            });
          },
          child: Text('再来一次', style: TextStyle(color: palette.primaryColor)),
        ),
        TextButton(
          onPressed: () {
            GoRouter.of(context).pop(); // 关闭对话框
            GoRouter.of(context).go('/'); // 返回主菜单
          },
          child: Text('返回主菜单', style: TextStyle(color: palette.primaryColor)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: _game,
      ),
    );
  }
}