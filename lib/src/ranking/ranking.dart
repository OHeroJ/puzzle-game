// 排行榜数据模型类
import 'package:flutter/foundation.dart';

class Ranking {
  final String id;
  final String userId;
  final String username;
  final int score;
  final String? avatarUrl;
  final DateTime createdAt;

  Ranking({
    required this.id,
    required this.userId,
    required this.username,
    required this.score,
    this.avatarUrl,
    required this.createdAt,
  });

  // 从JSON创建Ranking实例
  factory Ranking.fromJson(Map<String, dynamic> json) {
    return Ranking(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      username: json['username'] as String,
      score: json['score'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  // 将Ranking实例转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'score': score,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 格式化创建时间显示
  String formatCreatedAt() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}
