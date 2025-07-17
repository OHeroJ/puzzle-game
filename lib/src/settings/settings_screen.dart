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
        leading: IconButton(
          onPressed: () => GoRouter.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        centerTitle: true,
        backgroundColor: palette.backgroundMain,
        title: Text(
          'Settings',
          style: TextStyle(fontSize: 28.sp, color: palette.textColor, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: palette.backgroundMain,
      body: ListView(
        children: [
          SizedBox(height: 20),
          ValueListenableBuilder<bool>(
            valueListenable: settings.soundsOn,
            builder: (context, soundsOn, child) => _SettingsLine(
              'Voice',
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
            'Policy',
            Icon(Icons.policy, color: palette.textColor),
            onSelected: () {
              _launchInBrowser(Uri.parse(
                  "https://puzzle.xfans.me/puzzle/html/app-privacy-policy.html"));
            },
          ),
          _SettingsLine(
            'About',
            Icon(Icons.info, color: palette.textColor),
            onSelected: () {
              GoRouter.of(context).push('/settings/about');
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
    throw Exception('Could not launch $url');
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
        style: TextStyle(fontSize: 18.sp, color: palette.textColor),
      ),
      trailing: trailing,
      onTap: onSelected,
      contentPadding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 8.w),
    );
  }
}
