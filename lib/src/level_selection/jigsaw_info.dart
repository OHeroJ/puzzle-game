import 'dart:convert';
import 'package:crypto/crypto.dart';

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

  late bool unlocked;

  JigsawInfo(
    this.image,
    this.smallimage,
    this.title, {
    this.unlocked = false,
  });

  JigsawInfo.fromJson(dynamic json) {
    id = json['id'];
    image = json['src']['large'];
    smallimage = json['src']['medium'];
    title = json['alt'];
    photographer = json['photographer'];
    unlocked = json['unlocked'] ?? false;
  }

  /// 使用本地资源构造一个拼图信息。
  /// [path] 为资源路径，如 `assets/images/xxx.png`。
  /// [title] 作为图片标题显示；[photographer] 可作为分类或作者名显示。
  JigsawInfo.fromAsset(String path,
      {String title = '', String photographer = ''}) {
    // 使用 MD5 的前 8 位生成稳定 ID，避免 hashCode 在不同运行环境下不稳定
    // 依赖 crypto 包
    // ignore: prefer_interpolation_to_compose_strings
    final _id = stableIdFromPath(path);
    id = _id;
    image = path;
    smallimage = path;
    this.title = title;
    this.photographer = photographer;
    gridSize = 4; // 默认值，实际由弹窗选择覆盖
    unlocked = false;
  }

  static int stableIdFromPath(String path) {
    // 延迟加载依赖，避免在未使用时增加开销
    // 直接计算 md5 并截取前 8 位作为 32 位 int
    // 说明：Web 环境下 int 精度限制，取 32 位可避免溢出问题
    final bytes = utf8.encode(path);
    final digest = md5.convert(bytes).toString();
    final hex8 = digest.substring(0, 8);
    return int.parse(hex8, radix: 16);
  }
}
