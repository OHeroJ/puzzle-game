// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../style/palette.dart';
import '../user/user_manager.dart' show UserManager;
import 'settings.dart';
import '../ranking/ranking_manager.dart' show RankingManager;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _gap = SizedBox(height: 30);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final palette = context.watch<Palette>();
    final userManager = context.watch<UserManager>();
    final rankingManager = context.watch<RankingManager>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            GoRouter.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        centerTitle: true,
        backgroundColor: palette.backgroundMain,
        title: Text(
          'Settings',
          style: TextStyle(
              fontSize: 28.sp,
              color: palette.textColor,
              fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: palette.backgroundMain,
      body: ListView(
        children: [
          SizedBox(height: 20),
          // 用户信息区域
          Container(
            padding: EdgeInsets.all(20.w),
            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: palette.secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: userManager.isSignedIn
                ? Row(
                    children: [
                      CircleAvatar(
                        radius: 25.r,
                        backgroundColor: palette.primaryColor,
                        child: Text(
                          userManager.currentUser?.name.substring(0, 1) ?? 'U',
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userManager.currentUser?.name ?? 'User',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: palette.textColor,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              userManager.currentUser?.email ?? '',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: palette.textColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          userManager.logout();
                        },
                        child: Text(
                          '登出',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: palette.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          GoRouter.of(context).push('/login');
                        },
                        child: Text(
                          '登录',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: palette.primaryColor,
                          ),
                        ),
                      ),
                      Text(
                        '|',
                        style: TextStyle(
                          color: palette.textColor.withOpacity(0.5),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          GoRouter.of(context).push('/register');
                        },
                        child: Text(
                          '注册',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: palette.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          _gap,
          // 排行榜入口
          ListTile(
            title: Text(
              '排行榜',
              style: TextStyle(
                fontSize: 18.sp,
                color: palette.textColor,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: palette.textColor.withOpacity(0.7),
            ),
            onTap: () {
              GoRouter.of(context).push('/ranking');
            },
          ),
          _gap,
          SwitchListTile(
            value: settings.soundsOn.value,
            onChanged: (value) {
              settings.soundsOn.value = value;
            },
            title: Text(
              'Sound',
              style: TextStyle(
                fontSize: 18.sp,
                color: palette.textColor,
              ),
            ),
            activeColor: palette.primaryColor,
            inactiveThumbColor: palette.secondaryColor,
          ),
          _SettingsLine(
            'Policy',
            Icon(Icons.policy, color: palette.textColor),
            onSelected: () {
              _launchInBrowser(
                  Uri.parse("https://oldbird.run/puzzle-sec.html"));
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
