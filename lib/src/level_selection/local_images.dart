/// 本地图片分类数据。键为分类名，值为该分类下的图片资源路径列表。
/// 目前使用占位图片 `assets/images/ic_launcher.png`，后续可替换为真实图片。
const Map<String, List<String>> kLocalImageCategories = {
  '动物': [
    'assets/images/ic_launcher.png',
    'assets/images/ic_launcher.png',
    'assets/images/ic_launcher.png',
    'assets/images/ic_launcher.png',
  ],
  '风景': [
    'assets/images/ic_launcher.png',
    'assets/images/ic_launcher.png',
    'assets/images/ic_launcher.png',
    'assets/images/ic_launcher.png',
  ],
  '人物': [
    'assets/images/ic_launcher.png',
    'assets/images/ic_launcher.png',
    'assets/images/ic_launcher.png',
    'assets/images/ic_launcher.png',
  ],
  '汽车': [
    'assets/images/ic_launcher.png',
    'assets/images/ic_launcher.png',
    'assets/images/ic_launcher.png',
    'assets/images/ic_launcher.png',
  ],
  '美女': [
    'assets/images/ic_launcher.png',
    'assets/images/ic_launcher.png',
    'assets/images/ic_launcher.png',
    'assets/images/ic_launcher.png',
  ],
  '建筑': [
    'assets/images/ic_launcher.png',
    'assets/images/ic_launcher.png',
    'assets/images/ic_launcher.png',
    'assets/images/ic_launcher.png',
  ],
};

/// 获取某个分类下的所有图片资源路径。如果分类不存在，返回空列表。
List<String> getAssetsByCategory(String category) {
  return List<String>.from(kLocalImageCategories[category] ?? const []);
}

/// 获取所有分类下的图片资源路径聚合列表。
List<String> getAllAssets() {
  final result = <String>[];
  kLocalImageCategories.values.forEach(result.addAll);
  return result;
}
