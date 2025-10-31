// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../style/palette.dart';
import '../user/user_manager.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final audioController = context.watch<AudioController>();
    final userManager = context.watch<UserManager>();

    return Scaffold(
      backgroundColor: palette.backgroundMain,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 根据屏幕宽度调整整体布局
          final isLargeScreen = constraints.maxWidth > 600;

          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 80.w : 30.w,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: isLargeScreen ? 150.w : 120.w,
                      height: isLargeScreen ? 150.h : 120.h,
                      decoration: BoxDecoration(
                        color: palette.primaryColor.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.extension,
                        color: palette.textColor,
                        size: isLargeScreen ? 80.w : 60.w,
                      ),
                    ),
                    SizedBox(height: isLargeScreen ? 50.h : 30.h),

                    // 游戏标题
                    Text(
                      '拼图游戏',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 36.sp : 28.sp,
                        fontWeight: FontWeight.bold,
                        color: palette.textColor,
                      ),
                    ),
                    SizedBox(height: isLargeScreen ? 60.h : 40.h),

                    // 开始游戏按钮
                    Container(
                      width: isLargeScreen ? 200.w : 150.w,
                      height: isLargeScreen ? 60.h : 45.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            palette.primaryColor,
                            palette.secondaryColor,
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(isLargeScreen ? 30.r : 22.r),
                        boxShadow: [
                          BoxShadow(
                            color: palette.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          audioController.playSfx(SfxType.buttonTap);
                          context.push('/play/level');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                isLargeScreen ? 30.r : 22.r),
                          ),
                        ),
                        child: Text(
                          '开始游戏',
                          style: TextStyle(
                            fontSize: isLargeScreen ? 20.sp : 16.sp,
                            fontWeight: FontWeight.bold,
                            color: palette.backgroundMain,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isLargeScreen ? 30.h : 20.h),

                    // 排行榜按钮
                    Container(
                      width: isLargeScreen ? 200.w : 150.w,
                      height: isLargeScreen ? 50.h : 40.h,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: palette.primaryColor, width: 2.w),
                        borderRadius:
                            BorderRadius.circular(isLargeScreen ? 25.r : 20.r),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          audioController.playSfx(SfxType.buttonTap);
                          context.push('/ranking');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                isLargeScreen ? 25.r : 20.r),
                          ),
                        ),
                        child: Text(
                          '排行榜',
                          style: TextStyle(
                            fontSize: isLargeScreen ? 18.sp : 14.sp,
                            fontWeight: FontWeight.bold,
                            color: palette.textColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isLargeScreen ? 30.h : 20.h),

                    // 设置按钮
                    Container(
                      width: isLargeScreen ? 200.w : 150.w,
                      height: isLargeScreen ? 50.h : 40.h,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: palette.primaryColor, width: 2.w),
                        borderRadius:
                            BorderRadius.circular(isLargeScreen ? 25.r : 20.r),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          audioController.playSfx(SfxType.buttonTap);
                          context.push('/settings');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                isLargeScreen ? 25.r : 20.r),
                          ),
                        ),
                        child: Text(
                          '设置',
                          style: TextStyle(
                            fontSize: isLargeScreen ? 18.sp : 14.sp,
                            fontWeight: FontWeight.bold,
                            color: palette.textColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isLargeScreen ? 30.h : 20.h),

                    // 用户信息区域
                    if (userManager.isSignedIn &&
                        userManager.currentUser != null)
                      Container(
                        width: isLargeScreen ? 200.w : 150.w,
                        padding: EdgeInsets.all(isLargeScreen ? 15.w : 10.w),
                        decoration: BoxDecoration(
                          color: palette.backgroundMenu.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(
                              isLargeScreen ? 20.r : 15.r),
                        ),
                        child: Column(
                          children: [
                            Text(
                              userManager.currentUser!.name,
                              style: TextStyle(
                                fontSize: isLargeScreen ? 16.sp : 14.sp,
                                fontWeight: FontWeight.bold,
                                color: palette.textColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        width: isLargeScreen ? 200.w : 150.w,
                        padding: EdgeInsets.all(isLargeScreen ? 15.w : 10.w),
                        decoration: BoxDecoration(
                          color: palette.backgroundMenu.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(
                              isLargeScreen ? 20.r : 15.r),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '未登录',
                              style: TextStyle(
                                fontSize: isLargeScreen ? 16.sp : 14.sp,
                                fontWeight: FontWeight.bold,
                                color: palette.textColor,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              '登录后可保存游戏记录',
                              style: TextStyle(
                                fontSize: isLargeScreen ? 12.sp : 10.sp,
                                color: palette.textColor,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            // 添加登录按钮
                            Container(
                              width: double.infinity,
                              height: isLargeScreen ? 40.h : 35.h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    palette.primaryColor,
                                    palette.secondaryColor,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                    isLargeScreen ? 20.r : 17.r),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  audioController.playSfx(SfxType.buttonTap);
                                  context.push('/login');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        isLargeScreen ? 20.r : 17.r),
                                  ),
                                ),
                                child: Text(
                                  '立即登录',
                                  style: TextStyle(
                                    fontSize: isLargeScreen ? 14.sp : 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: palette.backgroundMain,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
