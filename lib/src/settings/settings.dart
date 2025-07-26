// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'persistence/settings_persistence.dart';

/// An class that holds the settings of the game, and persists them
/// to and from [SettingsPersistence].
///
/// This class is designed to be used with [ChangeNotifierProvider] to make
/// the settings available throughout the widget tree. For example:
///
/// ```dart
/// ChangeNotifierProvider(
///   create: (context) => SettingsController(
///     persistence: LocalStorageSettingsPersistence(),
///   ),
///   child: MyApp(),
/// )
/// ```
///
/// Then, in any widget down the tree:
///
/// ```dart
/// final settings = context.watch<SettingsController>();
/// ```
class SettingsController extends ChangeNotifier {
  final SettingsPersistence _persistence;

  /// Controls whether music is played during a game.
  final ValueNotifier<bool> musicOn = ValueNotifier(true);

  /// Controls whether sound effects are played during a game.
  final ValueNotifier<bool> soundsOn = ValueNotifier(true);
  
  /// Whether or not the sound is on at all. This overrides both music
  /// and sound.
  final ValueNotifier<bool> muted = ValueNotifier(false);

  /// The player's name.
  final ValueNotifier<String> playerName = ValueNotifier('Player');

  SettingsController({required SettingsPersistence persistence})
      : _persistence = persistence {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await Future.wait([
      _persistence
          // On the web, sound can only start after user interaction, so
          // we start muted there.
          // On any other platform, we start unmuted.
          .getMuted(defaultValue: kIsWeb)
          .then((value) => muted.value = value),
      _persistence.getSoundsOn().then((value) => soundsOn.value = value),
      _persistence.getMusicOn().then((value) => musicOn.value = value),
      _persistence.getPlayerName().then((value) => playerName.value = value),
    ]);
    
    notifyListeners();
  }

  @override
  void dispose() {
    musicOn.dispose();
    soundsOn.dispose();
    muted.dispose();
    playerName.dispose();
    super.dispose();
  }

  void setPlayerName(String name) {
    playerName.value = name;
    _persistence.savePlayerName(playerName.value);
    notifyListeners();
  }

  void toggleMuted() {
    muted.value = !muted.value;
    _persistence.saveMuted(muted.value);
    notifyListeners();
  }

  void toggleMusicOn() {
    musicOn.value = !musicOn.value;
    _persistence.saveMusicOn(musicOn.value);
    notifyListeners();
  }

  void toggleSoundsOn() {
    soundsOn.value = !soundsOn.value;
    _persistence.saveSoundsOn(soundsOn.value);
    notifyListeners();
  }
}
