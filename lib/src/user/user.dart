// 用户模型类
class User {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
  });

  // 从JSON创建User实例
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  // 将User实例转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
    };
  }
}