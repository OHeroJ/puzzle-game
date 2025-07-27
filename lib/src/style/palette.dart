// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../settings/settings.dart';

/// A palette of colors and other visual constants used in the game.
///
/// This class is designed to be used with [Provider] to make the palette
/// available throughout the widget tree. For example:
///
/// ```dart
/// ChangeNotifierProvider(
///   create: (context) => Palette(),
///   child: MyApp(),
/// )
/// ```
///
/// Then, in any widget down the tree:
///
/// ```dart
/// final palette = context.watch<Palette>();
/// ```
class Palette extends ChangeNotifier {
  // 暗色主题颜色
  static const darkPrimary = Color(0xFF673AB7);
  static const darkSecondary = Color(0xFFE91E63);
  static const darkBackground = Color(0xFF212121);
  static const darkBackgroundMainColor = Color(0xFF303030);
  static const darkBackgroundMenuColor = Color(0xFF424242);
  static const darkTextColor = Color(0xFFFFFFFF);
  
  // 亮色主题颜色
  static const lightPrimary = Color(0xFF673AB7);
  static const lightSecondary = Color(0xFFE91E63);
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightBackgroundMainColor = Color(0xFFF5F5F5);
  static const lightBackgroundMenuColor = Color(0xFFE0E0E0);
  static const lightTextColor = Color(0xFF212121);
  
  // 当前主题颜色（默认为亮色主题）
  late Color backgroundMain;
  late Color backgroundLevel1;
  late Color backgroundLevel2;
  late Color backgroundLevel3;
  late Color textColor;
  late Color darkPen;
  late Color primaryColor;
  late Color secondaryColor;
  late Color backgroundMenu;
  
  Palette(AppTheme theme) {
    _updateColors(theme);
  }
  
  void setTheme(AppTheme theme) {
    _updateColors(theme);
    notifyListeners();
  }
  
  void _updateColors(AppTheme theme) {
    if (theme == AppTheme.dark) {
      // 暗色主题
      backgroundMain = darkBackground;
      backgroundLevel1 = const Color(0xFF303030);
      backgroundLevel2 = const Color(0xFF424242);
      backgroundLevel3 = const Color(0xFF616161);
      textColor = darkTextColor;
      darkPen = const Color(0xFF616161);
      primaryColor = darkPrimary;
      secondaryColor = darkSecondary;
      backgroundMenu = darkBackgroundMenuColor;
    } else {
      // 亮色主题
      backgroundMain = lightBackgroundMainColor;
      backgroundLevel1 = const Color(0xFFEEEEEE);
      backgroundLevel2 = const Color(0xFFE0E0E0);
      backgroundLevel3 = const Color(0xFFBDBDBD);
      textColor = lightTextColor;
      darkPen = const Color(0xFF757575);
      primaryColor = lightPrimary;
      secondaryColor = lightSecondary;
      backgroundMenu = lightBackgroundMenuColor;
    }
  }
}