import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle/src/settings/settings.dart';
import 'package:puzzle/src/settings/persistence/settings_persistence.dart';

class MockSettingsPersistence implements SettingsPersistence {
  bool musicOn = false;
  bool soundsOn = true;
  bool muted = false;
  String playerName = 'Player';

  @override
  Future<bool> getMusicOn() async => musicOn;

  @override
  Future<bool> getSoundsOn() async => soundsOn;

  @override
  Future<bool> getMuted({required bool defaultValue}) async => muted;

  @override
  Future<String> getPlayerName() async => playerName;

  @override
  Future<void> saveMusicOn(bool value) async {
    musicOn = value;
  }

  @override
  Future<void> saveSoundsOn(bool value) async {
    soundsOn = value;
  }

  @override
  Future<void> saveMuted(bool value) async {
    muted = value;
  }

  @override
  Future<void> savePlayerName(String value) async {
    playerName = value;
  }
}

void main() {
  group('SettingsController', () {
    late SettingsPersistence mockPersistence;
    late SettingsController settingsController;

    setUp(() {
      mockPersistence = MockSettingsPersistence();
      settingsController = SettingsController(persistence: mockPersistence);
    });

    tearDown(() {
      settingsController.dispose();
    });

    test('should initialize with default values', () async {
      // Wait for settings to load
      await Future.delayed(Duration.zero);
      
      expect(settingsController.musicOn.value, false);
      expect(settingsController.soundsOn.value, true);
      expect(settingsController.muted.value, false);
      expect(settingsController.playerName.value, 'Player');
    });

    test('should update player name', () async {
      // Wait for settings to load
      await Future.delayed(Duration.zero);
      
      settingsController.setPlayerName('NewPlayer');
      
      expect(settingsController.playerName.value, 'NewPlayer');
      expect((mockPersistence as MockSettingsPersistence).playerName, 'NewPlayer');
    });

    test('should toggle muted state', () async {
      // Wait for settings to load
      await Future.delayed(Duration.zero);
      
      final initialValue = settingsController.muted.value;
      settingsController.toggleMuted();
      
      expect(settingsController.muted.value, !initialValue);
      expect((mockPersistence as MockSettingsPersistence).muted, !initialValue);
    });

    test('should toggle music state', () async {
      // Wait for settings to load
      await Future.delayed(Duration.zero);
      
      final initialValue = settingsController.musicOn.value;
      settingsController.toggleMusicOn();
      
      expect(settingsController.musicOn.value, !initialValue);
      expect((mockPersistence as MockSettingsPersistence).musicOn, !initialValue);
    });

    test('should toggle sounds state', () async {
      // Wait for settings to load
      await Future.delayed(Duration.zero);
      
      final initialValue = settingsController.soundsOn.value;
      settingsController.toggleSoundsOn();
      
      expect(settingsController.soundsOn.value, !initialValue);
      expect((mockPersistence as MockSettingsPersistence).soundsOn, !initialValue);
    });
  });
}