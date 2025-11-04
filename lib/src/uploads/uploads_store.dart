import 'dart:convert';
import 'dart:io' show File, Directory;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:puzzle/src/level_selection/jigsaw_info.dart';
import 'package:puzzle/src/uploads/uploads_entry.dart';
import 'package:puzzle/src/utils/sp_util.dart';

class UploadsStore {
  static const String _spKey = 'user_uploads';

  Future<List<UploadEntry>> load() async {
    final raw = SpUtil().getJSON(_spKey);
    if (raw == null) return [];
    final list = (raw as List)
        .map((e) => UploadEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return list;
  }

  Future<void> _save(List<UploadEntry> data) async {
    await SpUtil().setJSON(_spKey, data.map((e) => e.toJson()).toList());
  }

  /// 选择图片并持久化到本地（桌面/移动），Web 使用 base64 存储
  Future<UploadEntry?> pickAndSave({String category = '我的上传'}) async {
    final typeGroup = const XTypeGroup(
      label: 'images',
      extensions: ['jpg', 'jpeg', 'png', 'gif'],
    );
    final xfile = await openFile(acceptedTypeGroups: [typeGroup]);
    if (xfile == null) return null;
    final title = xfile.name;
    final createdAt = DateTime.now().toIso8601String();

    String storageType;
    String pathOrData;

    if (kIsWeb) {
      // Web: 以 data URI 存储（必须有 bytes）
      final bytes = await xfile.readAsBytes();
      if (bytes.isEmpty) return null;
      final base64 = base64Encode(bytes);
      final mime = _mimeFromName(title);
      storageType = 'base64';
      pathOrData = 'data:$mime;base64,$base64';
    } else {
      // 桌面/移动：复制到应用目录
      final appDir = await getApplicationDocumentsDirectory();
      final uploadsDir = Directory('${appDir.path}/uploads');
      if (!uploadsDir.existsSync()) {
        uploadsDir.createSync(recursive: true);
      }
      final sanitized = title.replaceAll(RegExp('[^a-zA-Z0-9._-]'), '_');
      final targetPath = '${uploadsDir.path}/$sanitized';
      if (xfile.path.isNotEmpty) {
        final file = File(xfile.path);
        await file.copy(targetPath);
      } else {
        final bytes = await xfile.readAsBytes();
        if (bytes.isEmpty) return null;
        final file = File(targetPath);
        await file.writeAsBytes(bytes);
      }
      storageType = 'file';
      pathOrData = targetPath;
    }

    final id = JigsawInfo.stableIdFromPath(pathOrData);
    final entry = UploadEntry(
      id: id,
      title: title,
      category: category,
      storageType: storageType,
      pathOrData: pathOrData,
      createdAt: createdAt,
    );

    final items = await load();
    items.add(entry);
    await _save(items);
    return entry;
  }

  Future<void> remove(int id) async {
    final items = await load();
    final idx = items.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      final entry = items[idx];
      // 删除文件（桌面/移动）
      if (entry.storageType == 'file') {
        final f = File(entry.pathOrData);
        if (f.existsSync()) {
          try {
            f.deleteSync();
          } catch (_) {}
        }
      }
      items.removeAt(idx);
      await _save(items);
    }
  }

  Future<List<JigsawInfo>> toJigsaws() async {
    final items = await load();
    return items.map((e) {
      final info = JigsawInfo(e.pathOrData, e.pathOrData, e.title);
      info.photographer = e.category;
      info.id = e.id;
      info.gridSize = 4;
      return info;
    }).toList(growable: false);
  }

  String _mimeFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/*';
  }
}
