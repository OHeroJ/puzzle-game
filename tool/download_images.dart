import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

// 每类目标数量
const int kImagesPerCategory = 50;

// 横屏目标尺寸（16:9），默认 1280x720；如需更高清可改为 1920x1080
const int kTargetWidthLandscape = 1280;
const int kTargetHeightLandscape = 720;

// 是否允许自动填充（Unsplash/Picsum）以补足外部数据源未提供的数量。
// 若希望严格由外部 JSON 控制分类内容，请改为 false。
const bool kAllowAutoFill = false;

// 分类元数据：显示名（中文）、英文目录名（slug）、查询关键词
const Map<String, Map<String, String>> kCategoriesMeta = {
  '动物': {'slug': 'animals', 'query': 'animals,pet,wildlife'},
  '风景': {'slug': 'landscape', 'query': 'nature,landscape,scenery'},
  '人物': {'slug': 'people', 'query': 'people,portrait'},
  '汽车': {'slug': 'cars', 'query': 'car,cars,vehicle'},
  '美女': {'slug': 'beauty', 'query': 'beauty,portrait'},
  '建筑': {'slug': 'architecture', 'query': 'architecture,building,city'},
};

// 按分类下载 kLocalImageCategories 中的图片到 assets/images/<分类>/ 目录。
// 文件名使用 URL 的 MD5 作为基名，扩展名根据响应的 Content-Type 判断。
// 运行方式：在项目根目录执行 `dart run tool/download_images.dart`
Future<void> main() async {
  final baseDir = Directory('assets/images');
  if (!baseDir.existsSync()) {
    baseDir.createSync(recursive: true);
  }

  int ok = 0;
  int fail = 0;

  // 尝试加载外部数据源（如 tool/image_sources.json），若存在则使用其 URL
  final externalSources = _loadExternalSources();

  for (final entry in kCategoriesMeta.entries) {
    final zhName = entry.key;
    final meta = entry.value;
    final slug = meta['slug']!;
    final query = meta['query']!;
    final externalList = externalSources?[zhName] ?? const <String>[];
    final needCount = (kImagesPerCategory - externalList.length);
    final genCount = needCount > 0 ? needCount : 0;
    final urls = <String>[
      ...externalList,
      ...(kAllowAutoFill
          ? _buildUnsplashUrls(query, genCount)
          : const <String>[]),
    ];
    final dir = Directory('assets/images/$slug');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    stdout.writeln('开始下载分类: $zhName (目录 $slug，共 ${urls.length} 张，仅确保横向)');
    for (int i = 0; i < urls.length; i++) {
      final url = urls[i];
      try {
        final uri = Uri.parse(url);
        final res = await http.get(uri);
        if (res.statusCode != 200) {
          if (kAllowAutoFill) {
            // 备用源：使用 picsum.photos 按 seed 生成稳定图片
            final fallback = Uri.parse(
                'https://picsum.photos/seed/${Uri.encodeComponent(slug)}-$i/${kTargetWidthLandscape}/${kTargetHeightLandscape}.jpg');
            final res2 = await http.get(fallback);
            if (res2.statusCode != 200) {
              fail++;
              stderr.writeln(
                  '下载失败(${res.statusCode}/${res2.statusCode}): $url | 备用失败: $fallback');
              continue;
            }
            final contentType2 = res2.headers['content-type'] ?? '';
            final ext2 = _extFromContentType(contentType2);
            final name2 =
                md5.convert(utf8.encode(fallback.toString())).toString();
            final file2 = File('assets/images/$slug/$name2.$ext2');
            final processed2 =
                _processToLandscape(res2.bodyBytes, preferExt: ext2);
            await file2.writeAsBytes(processed2);
            ok++;
            stdout.writeln('已保存(备用): ${file2.path}');
          } else {
            fail++;
            stderr.writeln('下载失败(${res.statusCode}): $url；已关闭自动填充与备用源。');
          }
          continue;
        }

        final contentType = res.headers['content-type'] ?? '';
        final ext = _extFromContentType(contentType);
        final name = md5.convert(utf8.encode(url)).toString();
        final file = File('assets/images/$slug/$name.$ext');
        final processed = _processToLandscape(res.bodyBytes, preferExt: ext);
        await file.writeAsBytes(processed);
        ok++;
        stdout.writeln('已保存: ${file.path}');
      } catch (e) {
        fail++;
        stderr.writeln('下载异常: $url -> $e');
      }
    }
  }

  stdout.writeln('下载完成：成功 $ok，失败 $fail');
  stdout.writeln('请在 pubspec.yaml 的 assets 中确保包含 `assets/images/`');

  // 生成/更新本地数据源：使用实际保存的本地路径覆盖 local_images.dart
  await _generateLocalImagesDart();
}

String _extFromContentType(String contentType) {
  final ct = contentType.toLowerCase();
  if (ct.contains('image/png')) return 'png';
  if (ct.contains('image/jpeg')) return 'jpg';
  // 统一将 webp 保存为 jpg，避免编码能力不一致
  if (ct.contains('image/webp')) return 'jpg';
  // 默认使用 jpg
  return 'jpg';
}

// 构建 Unsplash Source 的随机精选列表（通过 sig 保证缓存区分）
List<String> _buildUnsplashUrls(String query, int count) {
  final q = Uri.encodeQueryComponent(query);
  final w = kTargetWidthLandscape;
  final h = kTargetHeightLandscape;
  return List<String>.generate(
      count, (i) => 'https://source.unsplash.com/featured/${w}x$h?$q&sig=$i');
}

Future<void> _generateLocalImagesDart() async {
  final buffer = StringBuffer();
  buffer.writeln('''/// 本地图片分类数据（由工具脚本生成）。键为分类名，值为该分类下的图片资源路径列表。\n''');
  buffer.writeln('const Map<String, List<String>> kLocalImageCategories = {');

  // 以脚本内的分类为准，确保分类稳定（中文显示名 + 英文目录名）
  for (final entry in kCategoriesMeta.entries) {
    final zhName = entry.key;
    final slug = entry.value['slug']!;
    final dir = Directory('assets/images/$slug');
    final files = dir.existsSync()
        ? dir
            .listSync(recursive: false)
            .whereType<File>()
            .where((f) => _isImageFile(f.path))
            .toList()
        : <File>[];
    buffer.writeln("  '$zhName': [");
    for (final f in files) {
      // 统一使用正斜杠路径
      final p = f.path.replaceAll('\\\\', '/');
      buffer.writeln("    '$p',");
    }
    buffer.writeln('  ],');
  }

  buffer.writeln('};');
  buffer.writeln(
      '''\n/// 获取某个分类下的所有图片资源路径。如果分类不存在，返回空列表。\nList<String> getAssetsByCategory(String category) {\n  return List<String>.from(kLocalImageCategories[category] ?? const []);\n}\n\n/// 获取所有分类下的图片资源路径聚合列表。\nList<String> getAllAssets() {\n  final result = <String>[];\n  kLocalImageCategories.values.forEach(result.addAll);\n  return result;\n}''');

  final outFile = File('lib/src/level_selection/local_images.dart');
  await outFile.writeAsString(buffer.toString());
  stdout.writeln('已生成本地数据源：${outFile.path}');
}

bool _isImageFile(String path) {
  final lower = path.toLowerCase();
  return lower.endsWith('.png') ||
      lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.webp');
}

// 尝试加载外部数据源：tool/image_sources.json
// 格式：{"动物": ["https://...", ...], "风景": ["https://..."]}
Map<String, List<String>>? _loadExternalSources() {
  final file = File('tool/image_sources.json');
  if (!file.existsSync()) return null;
  try {
    final raw = file.readAsStringSync();
    final jsonMap = json.decode(raw);
    if (jsonMap is! Map) return null;
    final out = <String, List<String>>{};
    jsonMap.forEach((key, value) {
      if (value is List) {
        out[key.toString()] = value.map((e) => e.toString()).toList();
      }
    });
    stdout.writeln('已加载外部数据源: tool/image_sources.json');
    return out;
  } catch (e) {
    stderr.writeln('外部数据源解析失败: $e');
    return null;
  }
}

/// 仅确保图片为横向：
/// - 若已是横向 (width >= height)，不缩放不改变比例，仅按 preferExt 重新编码；
/// - 若为竖向 (width < height)，进行居中裁剪，使高度略小于宽度（不缩放），再编码。
List<int> _processToLandscape(List<int> bytes, {String preferExt = 'jpg'}) {
  final original = img.decodeImage(Uint8List.fromList(bytes));
  if (original == null) {
    return bytes;
  }

  final w = original.width;
  final h = original.height;
  final isLandscape = w >= h;

  if (isLandscape) {
    final ext = preferExt.toLowerCase();
    if (ext.contains('png')) {
      return img.encodePng(original);
    }
    return img.encodeJpg(original, quality: 90);
  }

  // 对竖图做最小裁剪：高度裁剪为宽度的 90%，确保横向
  final targetH = (w * 0.9).round();
  final y0 = ((h - targetH) / 2).round().clamp(0, h - targetH);
  final cropped =
      img.copyCrop(original, x: 0, y: y0, width: w, height: targetH);

  final ext = preferExt.toLowerCase();
  if (ext.contains('png')) {
    return img.encodePng(cropped);
  }
  return img.encodeJpg(cropped, quality: 90);
}
