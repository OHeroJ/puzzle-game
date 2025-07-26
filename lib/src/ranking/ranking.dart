// 排行榜数据模型类
class Ranking {
  final String id;
  final String userId;
  final String username;
  final int score;
  final DateTime createdAt;
  final String? avatarUrl;

  Ranking({
    required this.id,
    required this.userId,
    required this.username,
    required this.score,
    required this.createdAt,
    this.avatarUrl,
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
      'created_at': createdAt.toIso8601String(),
      'avatar_url': avatarUrl,
    };
  }
}