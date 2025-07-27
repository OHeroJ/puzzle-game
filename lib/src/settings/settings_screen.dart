// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../style/palette.dart';
import '../user/user_manager.dart';
import 'settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 初始化时设置用户名
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsController>();
      _nameController.text = settings.playerName.value;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final settings = context.watch<SettingsController>();
    final userManager = context.watch<UserManager>();

    return Scaffold(
      backgroundColor: palette.backgroundMain,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 返回按钮
              IconButton(
                icon: Icon(Icons.arrow_back, color: palette.textColor),
                onPressed: () => context.pop(),
              ),
              SizedBox(height: 20.h),
              
              // 标题
              Text(
                '设置',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: palette.textColor,
                ),
              ),
              SizedBox(height: 30.h),
              
              // 用户名设置
              Text(
                '用户名',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: palette.textColor,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                decoration: BoxDecoration(
                  color: palette.backgroundMenu.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: TextField(
                  controller: _nameController,
                  style: TextStyle(color: palette.textColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '请输入用户名',
                    hintStyle: TextStyle(color: palette.textColor.withValues(alpha: 0.5)),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      settings.setPlayerName(value.trim());
                    }
                  },
                ),
              ),
              SizedBox(height: 20.h),
              
              // 音效设置
              Text(
                '音效设置',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: palette.textColor,
                ),
              ),
              SizedBox(height: 15.h),
              _buildSwitchSetting(
                context,
                '音乐',
                settings.musicOn.value,
                (value) => settings.toggleMusicOn(),
              ),
              SizedBox(height: 10.h),
              _buildSwitchSetting(
                context,
                '音效',
                settings.soundsOn.value,
                (value) => settings.toggleSoundsOn(),
              ),
              SizedBox(height: 10.h),
              _buildSwitchSetting(
                context,
                '静音',
                settings.muted.value,
                (value) => settings.toggleMuted(),
              ),
              SizedBox(height: 20.h),
              
              // 主题设置
              Text(
                '主题设置',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: palette.textColor,
                ),
              ),
              SizedBox(height: 15.h),
              _buildThemeSetting(context, settings),
              SizedBox(height: 20.h),
              
              // 用户登录状态提示
              if (!userManager.isSignedIn)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(
                    color: palette.backgroundMenu.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '提示',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: palette.textColor,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        '登录后设置将保存到云端，可在不同设备间同步。\n点击右上角的个人头像登录。',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: palette.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 20.h),
              
              // 关于按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/settings/about');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    '关于',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: palette.backgroundMain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchSetting(BuildContext context, String title, bool value, Function(bool) onChanged) {
    final palette = context.watch<Palette>();
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: palette.backgroundMenu.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              color: palette.textColor,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: palette.primaryColor,
          ),
        ],
      ),
    );
  }
  
  Widget _buildThemeSetting(BuildContext context, SettingsController settings) {
    final palette = context.watch<Palette>();
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: palette.backgroundMenu.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择主题',
            style: TextStyle(
              fontSize: 16.sp,
              color: palette.textColor,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  context,
                  '亮色',
                  AppTheme.light,
                  settings.theme.value == AppTheme.light,
                  () => settings.setTheme(AppTheme.light),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildThemeOption(
                  context,
                  '暗色',
                  AppTheme.dark,
                  settings.theme.value == AppTheme.dark,
                  () => settings.setTheme(AppTheme.dark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildThemeOption(BuildContext context, String title, AppTheme theme, bool isSelected, VoidCallback onTap) {
    final palette = context.watch<Palette>();
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? palette.primaryColor : palette.backgroundLevel3,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: isSelected ? palette.backgroundMain : palette.textColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}