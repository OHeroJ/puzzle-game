import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle/src/audio/audio_controller.dart';

void main() {
  group('AudioController', () {
    test('should throw assertion error for invalid polyphony', () {
      expect(() => AudioController(polyphony: 0), throwsAssertionError);
      expect(() => AudioController(polyphony: -1), throwsAssertionError);
    });

  });
}