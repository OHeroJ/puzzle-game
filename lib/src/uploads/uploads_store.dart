import 'package:file_selector/file_selector.dart';
import 'package:puzzle/src/level_selection/jigsaw_info.dart';
import 'package:puzzle/src/uploads/uploads_entry.dart';
import 'package:puzzle/src/utils/sp_util.dart';

import 'uploads_store_impl_non_web.dart';

/// 跨平台上传存储封装：在 Web 与 非 Web 环境使用不同实现，避免 Web 构建失败。
class UploadsStore {
  static const String spKey = 'user_uploads';

  final UploadsStorePlatform _impl = UploadsStorePlatform();

  Future<List<UploadEntry>> load() => _impl.load();

  Future<UploadEntry?> pickAndSave({String category = '我的上传'}) =>
      _impl.pickAndSave(category: category);

  Future<void> remove(int id) => _impl.remove(id);

  Future<List<JigsawInfo>> toJigsaws() => _impl.toJigsaws();
}
