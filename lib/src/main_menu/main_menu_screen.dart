// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../settings/settings.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final settingsController = context.watch<SettingsController>();

    return Scaffold(
      backgroundColor: palette.backgroundMain,
      body: ResponsiveScreen(
        mainAreaProminence: 0.55,
        squarishMainArea: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '有趣拼图',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 60,
                  height: 1,
                  color: palette.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 25),
              ElevatedButton.icon(
                icon:
                    const Icon(Icons.play_arrow, color: Colors.white, size: 24),
                onPressed: () {
                  GoRouter.of(context).push('/play');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                label: const Text('开始', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
        rectangularMenuArea: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => GoRouter.of(context).push('/history'),
              icon: const Icon(Icons.history, size: 24),
            ),
            SizedBox(height: 20),
            IconButton(
                onPressed: () => GoRouter.of(context).push('/settings'),
                icon: const Icon(Icons.settings, size: 24)),
            SizedBox(height: 30),
            ValueListenableBuilder<bool>(
              valueListenable: settingsController.muted,
              builder: (context, muted, child) {
                return IconButton(
                  onPressed: () => settingsController.toggleSoundsOn(),
                  icon: Icon(muted ? Icons.volume_off : Icons.volume_up,
                      size: 30, color: palette.textColor),
                );
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
