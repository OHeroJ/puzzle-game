import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle/src/ranking/score_calculator.dart';

void main() {
  group('ScoreCalculator', () {
    test('should calculate score correctly for 3x3 puzzle', () {
      final time = Duration(seconds: 30); // 30秒完成，基准60秒
      final moves = 40; // 40步完成，基准50步
      final difficulty = 3; // 3x3难度

      final score = ScoreCalculator.calculateScore(
        time: time,
        moves: moves,
        difficulty: difficulty,
      );

      // 基础分数: 1000
      // 时间奖励: (60-30) * 10 = 300
      // 步数奖励: (50-40) * 5 = 50
      // 难度倍率: 1.0
      // 总分: (1000 + 300 + 50) * 1.0 = 1350
      expect(score, 1350);
    });

    test('should calculate score correctly for 4x4 puzzle', () {
      final time = Duration(seconds: 90); // 90秒完成，基准120秒
      final moves = 90; // 90步完成，基准100步
      final difficulty = 4; // 4x4难度

      final score = ScoreCalculator.calculateScore(
        time: time,
        moves: moves,
        difficulty: difficulty,
      );

      // 基础分数: 1000
      // 时间奖励: (120-90) * 10 = 300
      // 步数奖励: (100-90) * 5 = 50
      // 难度倍率: 1.5
      // 总分: (1000 + 300 + 50) * 1.5 = 2025
      expect(score, 2025);
    });

    test('should calculate score correctly for 5x5 puzzle', () {
      final time = Duration(seconds: 200); // 200秒完成，基准300秒
      final moves = 180; // 180步完成，基准200步
      final difficulty = 5; // 5x5难度

      final score = ScoreCalculator.calculateScore(
        time: time,
        moves: moves,
        difficulty: difficulty,
      );

      // 基础分数: 1000
      // 时间奖励: (300-200) * 10 = 1000
      // 步数奖励: (200-180) * 5 = 100
      // 难度倍率: 2.0
      // 总分: (1000 + 1000 + 100) * 2.0 = 4200
      expect(score, 4200);
    });

    test('should handle negative score and return zero', () {
      final time = Duration(seconds: 600); // 时间很长，远超基准
      final moves = 500; // 步数很多，远超基准
      final difficulty = 3; // 3x3难度

      final score = ScoreCalculator.calculateScore(
        time: time,
        moves: moves,
        difficulty: difficulty,
      );

      // 基础分数: 1000
      // 时间奖励: (60-600) * 10 = -5400
      // 步数奖励: (50-500) * 5 = -2250
      // 难度倍率: 1.0
      // 总分: (1000 - 5400 - 2250) * 1.0 = -6650
      // 由于分数不能为负数，应该返回0
      expect(score, 0);
    });

    test('should calculate score with perfect performance', () {
      final time = Duration.zero; // 瞬间完成
      final moves = 0; // 0步完成
      final difficulty = 6; // 最高难度6x6

      final score = ScoreCalculator.calculateScore(
        time: time,
        moves: moves,
        difficulty: difficulty,
      );

      // 基础分数: 1000
      // 时间奖励: (600-0) * 10 = 6000
      // 步数奖励: (400-0) * 5 = 2000
      // 难度倍率: 3.0
      // 总分: (1000 + 6000 + 2000) * 3.0 = 27000
      expect(score, 27000);
    });
  });
}