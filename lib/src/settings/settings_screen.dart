// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../style/palette.dart';
import 'settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _gap = SizedBox(height: 30);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final palette = context.watch<Palette>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: palette.backgroundMain,
        title: Text(
          '设置',
          style:
              TextStyle(color: palette.textColor, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: palette.backgroundMain,
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        children: [
          SizedBox(height: 20),
          ValueListenableBuilder<bool>(
            valueListenable: settings.soundsOn,
            builder: (context, soundsOn, child) => _SettingsLine(
              '音效',
              Switch(
                value: soundsOn,
                onChanged: (bool value) {
                  settings.toggleSoundsOn();
                },
                activeColor: palette.primaryColor,
              ), // Icon(soundsOn ? Icons.volume_up : Icons.volume_off),
              onSelected: () => settings.toggleSoundsOn(),
            ),
          ),
          _SettingsLine(
            '隐私政策',
            Icon(Icons.policy, color: palette.textColor),
            onSelected: () {
              _launchInBrowser(
                  Uri.parse("https://oldbird.run/puzzle-sec-hw.html"));
            },
          ),
          _SettingsLine(
            '关于',
            Icon(Icons.info, color: palette.textColor),
            onSelected: () {
              GoRouter.of(context).push('/settings/about');
            },
          ),
          SizedBox(height: 20),
          Text(
            '拼图背景色',
            style: TextStyle(
              color: palette.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          ValueListenableBuilder<Color>(
            valueListenable: settings.gameBackgroundColor,
            builder: (context, current, _) {
              final options = <Color>[
                const Color(0xFFF0F2F5), // 默认浅灰
                Colors.white,
                Colors.black12,
                const Color(0xFFE3F2FD), // 淡蓝
                const Color(0xFFFFF3E0), // 淡橙
                const Color(0xFFE8F5E9), // 淡绿
              ];
              return Wrap(
                spacing: 10.w,
                runSpacing: 8.h,
                children: options.map((c) {
                  final selected = c.value == current.value;
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
                    onSelected: (_) => settings.setGameBackgroundColor(c),
                  );
                }).toList(),
              );
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

Future<void> _launchInBrowser(Uri url) async {
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    throw Exception('无法打开 $url');
  }
}

class _SettingsLine extends StatelessWidget {
  final String title;

  final Widget trailing;

  final VoidCallback? onSelected;

  const _SettingsLine(this.title, this.trailing, {this.onSelected});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: palette.textColor),
      ),
      trailing: trailing,
      onTap: onSelected,
      contentPadding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 8.w),
    );
  }
}
