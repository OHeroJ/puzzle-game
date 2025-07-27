/// id : ""
/// difficulty : ""
/// pictureUrl : ""
/// title : ""
/// type : ""

class JigsawInfo {
  late int id;
  late int gridSize;
  late String image;
  late String smallimage;
  late String title;
  late String photographer;
  late String url; // 添加url属性
  late int difficultyLevel; // 添加difficultyLevel属性

  // 添加缺失的getter方法
  String get imageUrl => image;
  String get name => title;
  int get difficulty => difficultyLevel;
  int get rows => gridSize;
  int get columns => gridSize;
  String get levelId => '$gridSize'; // 添加levelId getter，使用gridSize作为ID

  JigsawInfo(
    this.image,
    this.smallimage,
    this.title,
    this.gridSize,
    this.url, // 添加url参数
  ) {
    difficultyLevel = gridSize; // 初始化difficultyLevel为gridSize
    id = gridSize; // 初始化id为gridSize
  }

  JigsawInfo.fromJson(dynamic json, int gridSize) {
    id = json['id'];
    image = json['src']['large'];
    smallimage = json['src']['medium'];
    title = json['alt'];
    photographer = json['photographer'];
    url = json['src']['large']; // 设置url属性
    this.gridSize = gridSize; // 设置gridSize属性
    difficultyLevel = gridSize; // 初始化difficultyLevel为gridSize
  }
  
  // 添加一个静态方法来根据ID获取拼图信息
  static JigsawInfo getJigsawInfo(String levelId) {
    // 根据levelId返回对应的JigsawInfo对象
    int gridSize = int.tryParse(levelId) ?? 3; // 默认3x3网格
    return JigsawInfo(
      'https://images.pexels.com/photos/1366957/pexels-photo-1366957.jpeg',
      'https://images.pexels.com/photos/1366957/pexels-photo-1366957.jpeg',
      'Default Puzzle',
      gridSize,
      'https://images.pexels.com/photos/1366957/pexels-photo-1366957.jpeg', // url参数
    );
  }
  
  // 修复setter方法
  set setId(int value) {
    id = value;
  }
  
  set setPhotographer(String value) {
    photographer = value;
  }
  
  set setDifficultyLevel(int value) {
    difficultyLevel = value;
  }
}