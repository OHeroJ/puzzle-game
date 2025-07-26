import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle/src/games_services/score.dart';

void main() {
  group('Score', () {
    test('should format time correctly for seconds only', () {
      final score = Score(Duration(seconds: 30));
      expect(score.formattedTime, '00:30');
    });

    test('should format time correctly for minutes and seconds', () {
      final score = Score(Duration(minutes: 2, seconds: 15));
      expect(score.formattedTime, '02:15');
    });

    test('should format time correctly for hours, minutes and seconds', () {
      final score = Score(Duration(hours: 1, minutes: 5, seconds: 30));
      expect(score.formattedTime, '1:05:30');
    });

    test('should format time correctly for single digit minutes', () {
      final score = Score(Duration(minutes: 5, seconds: 5));
      expect(score.formattedTime, '05:05');
    });

    test('should format time correctly for single digit seconds', () {
      final score = Score(Duration(minutes: 1, seconds: 5));
      expect(score.formattedTime, '01:05');
    });

    test('should format time correctly for zero values', () {
      final score = Score(Duration.zero);
      expect(score.formattedTime, '00:00');
    });
  });
}