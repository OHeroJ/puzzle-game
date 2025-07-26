// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

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
  static const primary = Color(0xFF673AB7);
  static const secondary = Color(0xFFE91E63);
  static const background = Color(0xFF212121);
  static const backgroundMainColor = Color(0xFF303030);
  static const backgroundMenuColor = Color(0xFF424242);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const transparent = Color(0x00000000);
  static const lightGray = Color(0xFF9E9E9E); // 添加lightGray颜色

  /// The primary color of the game.
  Color get primaryColor => primary;

  /// The secondary color of the game.
  Color get secondaryColor => secondary;

  /// The background color of the game.
  Color get backgroundColor => background;

  /// The main background color of the game.
  Color get backgroundMain => backgroundMainColor;

  /// The menu background color of the game.
  Color get backgroundMenu => backgroundMenuColor;

  /// The white color of the game.
  Color get whiteColor => white;

  /// The black color of the game.
  Color get blackColor => black;

  /// The transparent color of the game.
  Color get transparentColor => transparent;

  /// The light gray color of the game.
  Color get lightGrayColor => lightGray;

  /// The text color of the game.
  Color get textColor => white;
}