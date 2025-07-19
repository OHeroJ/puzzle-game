// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
        mainAreaProminence: 0.45,
        squarishMainArea: Column(
          children: [
            Expanded(
                child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Puzzle Game',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 60,
                      height: 1,
                      color: palette.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      launchUrlString('https://www.pexels.com');
                    },
                    child: Text(
                      'Photos provided by Pexels',
                      style:
                          TextStyle(color: palette.textColor.withOpacity(0.7)),
                    ),
                  ),
                ],
              ),
            )),
            _buildBAH(),
          ],
        ),
        rectangularMenuArea: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
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
              child: const Text('Play', style: TextStyle(fontSize: 20)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => GoRouter.of(context).push('/settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.secondaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Settings', style: TextStyle(fontSize: 20)),
            ),
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

  Widget _buildBAH() {
    if (kIsWeb)
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 30.h,
          ),
          GestureDetector(
            onTap: () {
              launchUrlString('https://beian.miit.gov.cn');
            },
            child: Text(
              '赣ICP备2021010021号-1',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              launchUrlString(
                  'https://www.beian.gov.cn/portal/registerSystemInfo?recordcode=36011102000528');
            },
            child: Row(
              children: [
                Image.asset(
                  "assets/images/beanh.png",
                  width: 12,
                  height: 12,
                ),
                Text(
                  '赣公网安备 36011102000528号',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                )
              ],
            ),
          )
        ],
      );
    else
      return SizedBox();
  }
}
