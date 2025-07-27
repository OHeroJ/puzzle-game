// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../style/palette.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Scaffold(
      backgroundColor: palette.backgroundMain,
      appBar: AppBar(
        backgroundColor: palette.backgroundMenu.withOpacity(0.8),
        title: Text(
          '关于',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: palette.textColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: palette.textColor,
            size: 18.sp,
          ),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final packageInfo = snapshot.data!;
            return _buildContent(context, palette, packageInfo);
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                '加载失败',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: palette.textColor,
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, Palette palette, PackageInfo packageInfo) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo区域
          Center(
            child: Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                color: palette.primaryColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.extension,
                color: palette.textColor,
                size: 50.sp,
              ),
            ),
          ),
          SizedBox(height: 30.h),
          // 应用信息
          _buildInfoItem(
            context,
            palette,
            '应用名称',
            packageInfo.appName,
          ),
          SizedBox(height: 15.h),
          _buildInfoItem(
            context,
            palette,
            '版本号',
            packageInfo.version,
          ),
          SizedBox(height: 15.h),
          _buildInfoItem(
            context,
            palette,
            '构建号',
            packageInfo.buildNumber,
          ),
          SizedBox(height: 30.h),
          // 功能介绍
          Text(
            '功能介绍',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: palette.textColor,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            '这是一款拼图游戏应用，提供多种难度级别的拼图挑战。'
            '玩家可以通过完成拼图来获得积分，并在全球排行榜上与其他玩家竞争。',
            style: TextStyle(
              fontSize: 14.sp,
              color: palette.textColor.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 30.h),
          // 联系我们
          Text(
            '联系我们',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: palette.textColor,
            ),
          ),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: () => _launchInBrowser('https://github.com/flutter/flutter'),
            child: Text(
              '官方网站',
              style: TextStyle(
                fontSize: 14.sp,
                color: palette.primaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    Palette palette,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: palette.textColor,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: palette.textColor.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchInBrowser(String url) async {
    try {
      await launchUrlString(url);
    } catch (e) {
      // 忽略错误
    }
  }
}