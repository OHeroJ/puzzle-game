class UploadEntry {
  final int id;
  final String title;
  final String category; // 默认：我的上传
  final String storageType; // file | base64
  final String pathOrData; // 文件绝对路径或 data:image/...;base64,xxx
  final String createdAt;

  UploadEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.storageType,
    required this.pathOrData,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'storageType': storageType,
        'pathOrData': pathOrData,
        'createdAt': createdAt,
      };

  factory UploadEntry.fromJson(Map<String, dynamic> json) => UploadEntry(
        id: json['id'] as int,
        title: (json['title'] ?? '') as String,
        category: (json['category'] ?? '我的上传') as String,
        storageType: json['storageType'] as String,
        pathOrData: json['pathOrData'] as String,
        createdAt: json['createdAt'] as String,
      );
}