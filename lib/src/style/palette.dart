// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// A palette of colors to be used in the game.
///
/// The reason we're not going with something like Material Design's
/// `Theme` is simply that this is simpler to work with and yet gives
/// us everything we need for a game.
///
/// Games generally have more radical color palettes than apps. For example,
/// every level of a game can have radically different colors.
/// At the same time, games rarely support dark mode.
///
/// Colors taken from this fun palette:
/// https://lospec.com/palette-list/crayola84
///
/// Colors here are implemented as getters so that hot reloading works.
/// In practice, we could just as easily implement the colors
/// as `static const`. But this way the palette is more malleable:
/// we could allow players to customize colors, for example,
/// or even get the colors from the network.
class Palette {
  Color get backgroundMain => const Color(0xFFF0F2F5); // Light background
  Color get textColor => const Color(0xFF333333); // Dark text
  Color get primaryColor => const Color(0xFF4CAF50); // Vibrant green
  Color get secondaryColor => const Color(0xFF2196F3); // Complementary blue
  Color get accentColor => const Color(0xFFFFC107); // Accent amber
  Color get lightGray => const Color(0xFFE0E0E0); // Light gray for subtle elements
}