import 'dart:convert';
import 'dart:io' show File, Directory;

import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:puzzle/src/level_selection/jigsaw_info.dart';
import 'package:puzzle/src/uploads/uploads_entry.dart';
import 'package:puzzle/src/utils/sp_util.dart';
import 'uploads_store.dart';

/// 非 Web 平台的实现：文件复制到应用目录，并持久化记录。
class UploadsStorePlatform {
  Future<List<UploadEntry>> load() async {
    final raw = SpUtil().getJSON(UploadsStore.spKey);
    if (raw == null) return [];
    final list = (raw as List)
        .map((e) => UploadEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return list;
  }

  Future<void> _save(List<UploadEntry> data) async {
    await SpUtil().setJSON(UploadsStore.spKey, data.map((e) => e.toJson()).toList());
  }

  Future<UploadEntry?> pickAndSave({String category = '我的上传'}) async {
    final typeGroup = const XTypeGroup(
      label: 'images',
      extensions: ['jpg', 'jpeg', 'png', 'gif'],
    );
    final xfile = await openFile(acceptedTypeGroups: [typeGroup]);
    if (xfile == null) return null;
    final title = xfile.name;
    final createdAt = DateTime.now().toIso8601String();

    final appDir = await getApplicationDocumentsDirectory();
    final uploadsDir = Directory('${appDir.path}/uploads');
    if (!uploadsDir.existsSync()) {
      uploadsDir.createSync(recursive: true);
    }
    // 统一为每次上传生成唯一文件名，避免同名文件覆盖与删除时误伤
    final sanitized = title.replaceAll(RegExp('[^a-zA-Z0-9._-]'), '_');
    final dot = sanitized.lastIndexOf('.');
    final base = dot > 0 ? sanitized.substring(0, dot) : sanitized;
    final ext = dot > 0 ? sanitized.substring(dot) : '';
    final ts = DateTime.now().millisecondsSinceEpoch;
    final uniqueName = '${base}_$ts$ext';
    final targetPath = '${uploadsDir.path}/$uniqueName';
    if (xfile.path.isNotEmpty) {
      final file = File(xfile.path);
      await file.copy(targetPath);
    } else {
      final bytes = await xfile.readAsBytes();
      if (bytes.isEmpty) return null;
      final file = File(targetPath);
      await file.writeAsBytes(bytes);
    }

    final id = JigsawInfo.stableIdFromPath(targetPath);
    final entry = UploadEntry(
      id: id,
      title: title,
      category: category,
      storageType: 'file',
      pathOrData: targetPath,
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
      // 如果多个记录共享同一个文件路径，仅移除记录，不删除文件
      final samePathCount = items.where((e) => e.pathOrData == entry.pathOrData).length;
      if (entry.storageType == 'file' && samePathCount <= 1) {
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