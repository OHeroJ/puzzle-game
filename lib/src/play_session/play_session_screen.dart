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
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../games_services/score.dart';
import '../level_selection/jigsaw_info.dart';
import '../level_selection/jigsaw_service.dart';
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
  JigsawInfo? _jigsawInfo;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadJigsawInfo();
  }

  Future<void> _loadJigsawInfo() async {
    try {
      // 获取Supabase客户端
      final supabaseClient = supabase.Supabase.instance.client;
      
      // 创建拼图服务实例
      final jigsawService = JigsawService(supabaseClient);
      
      // 从Supabase获取拼图数据
      final jigsaws = await jigsawService.getJigsawInfos();
      
      // 查找匹配的拼图
      JigsawInfo? jigsawInfo;
      try {
        jigsawInfo = jigsaws.firstWhere(
          (jigsaw) => jigsaw.gridSize == widget.level,
        );
      } catch (e) {
        // 如果没有找到完全匹配的，使用第一个
        jigsawInfo = jigsaws.isNotEmpty ? jigsaws.first : null;
      }

      if (jigsawInfo != null) {
        setState(() {
          _jigsawInfo = jigsawInfo;
          _isLoading = false;
          if (jigsawInfo != null) {
            _game = JigsawGame(
              jigsawInfo!,
              true, // 默认开启音乐
              _onGameEnd, // 传递游戏结束回调
            );
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = '未找到对应的拼图数据';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '加载拼图数据失败: $e';
      });
    }
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
        '你完成了${_jigsawInfo?.name ?? '拼图'}!\n用时: ${score.formattedTime}',
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text(_errorMessage),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadJigsawInfo,
                child: const Text('重新加载'),
              ),
            ],
          ),
        ),
      );
    }

    if (_jigsawInfo == null) {
      return const Scaffold(
        body: Center(
          child: Text('未找到拼图数据'),
        ),
      );
    }

    return Scaffold(
      body: GameWidget(
        game: _game,
      ),
    );
  }
}