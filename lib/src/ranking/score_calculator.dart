// 积分计算器
class ScoreCalculator {
  // 基础分数
  static const int baseScore = 1000;

  // 根据时间和步数计算分数
  static int calculateScore({
    required Duration time,
    required int moves,
    required int difficulty, // 难度等级，例如 3 表示 3x3
  }) {
    // 时间分数 (时间越短分数越高)
    final timeBonus = _calculateTimeBonus(time, difficulty);

    // 步数分数 (步数越少分数越高)
    final movesBonus = _calculateMovesBonus(moves, difficulty);

    // 难度倍率 (难度越高倍率越大)
    final difficultyMultiplier = _getDifficultyMultiplier(difficulty);

    // 总分数 = (基础分数 + 时间奖励 + 步数奖励) * 难度倍率
    final totalScore =
        (baseScore + timeBonus + movesBonus) * difficultyMultiplier;

    // 确保分数不为负数
    return (totalScore > 0 ? totalScore : 0).toInt();
  }

  // 计算时间奖励
  static int _calculateTimeBonus(Duration time, int difficulty) {
    // 基准时间（根据难度确定）
    final baseTime = _getBaseTimeForDifficulty(difficulty);

    // 如果实际时间小于基准时间，给予奖励；否则给予惩罚
    final timeDiff = baseTime.inSeconds - time.inSeconds;

    // 每秒奖励10分
    return timeDiff * 10;
  }

  // 计算步数奖励
  static int _calculateMovesBonus(int moves, int difficulty) {
    // 基准步数（根据难度确定）
    final baseMoves = _getBaseMovesForDifficulty(difficulty);

    // 如果实际步数小于基准步数，给予奖励；否则给予惩罚
    final movesDiff = baseMoves - moves;

    // 每少一步奖励5分
    return movesDiff * 5;
  }

  // 获取难度倍率
  static double _getDifficultyMultiplier(int difficulty) {
    switch (difficulty) {
      case 3:
        return 1.0; // 3x3
      case 4:
        return 1.5; // 4x4
      case 5:
        return 2.0; // 5x5
      case 6:
        return 3.0; // 6x6
      default:
        return 1.0;
    }
  }

  // 获取指定难度的基准时间
  static Duration _getBaseTimeForDifficulty(int difficulty) {
    switch (difficulty) {
      case 3:
        return const Duration(seconds: 60); // 3x3: 60秒
      case 4:
        return const Duration(seconds: 120); // 4x4: 120秒
      case 5:
        return const Duration(seconds: 300); // 5x5: 300秒
      case 6:
        return const Duration(seconds: 600); // 6x6: 600秒
      default:
        return const Duration(seconds: 60);
    }
  }

  // 获取指定难度的基准步数
  static int _getBaseMovesForDifficulty(int difficulty) {
    switch (difficulty) {
      case 3:
        return 50; // 3x3: 50步
      case 4:
        return 100; // 4x4: 100步
      case 5:
        return 200; // 5x5: 200步
      case 6:
        return 400; // 6x6: 400步
      default:
        return 50;
    }
  }
}
