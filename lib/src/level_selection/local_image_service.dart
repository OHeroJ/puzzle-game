import 'package:puzzle/src/level_selection/jigsaw_info.dart';
import 'package:puzzle/src/level_selection/local_images.dart';

class LocalImageItem {
  final int id;
  final String path;
  final String title;
  final String category;

  LocalImageItem({
    required this.id,
    required this.path,
    required this.title,
    required this.category,
  });
}

class LocalImageService {
  List<String> get categories =>
      kLocalImageCategories.keys.toList(growable: false);

  List<LocalImageItem> itemsForCategory(String category) {
    final assets = getAssetsByCategory(category);
    return assets
        .map((p) => LocalImageItem(
              id: JigsawInfo.stableIdFromPath(p),
              path: p,
              title: _basename(p),
              category: category,
            ))
        .toList(growable: false);
  }

  List<LocalImageItem> allItems() {
    final result = <LocalImageItem>[];
    for (final entry in kLocalImageCategories.entries) {
      result.addAll(itemsForCategory(entry.key));
    }
    return result;
  }

  List<JigsawInfo> jigsawsForCategory(String category) {
    return itemsForCategory(category).map((e) {
      if (e.path.startsWith('assets/')) {
        return JigsawInfo.fromAsset(e.path,
            title: e.title, photographer: e.category);
      }
      final info = JigsawInfo(e.path, e.path, e.title);
      info.photographer = e.category;
      info.id = JigsawInfo.stableIdFromPath(e.path);
      info.gridSize = 4;
      return info;
    }).toList(growable: false);
  }

  List<JigsawInfo> allJigsaws() {
    return allItems().map((e) {
      if (e.path.startsWith('assets/')) {
        return JigsawInfo.fromAsset(e.path,
            title: e.title, photographer: e.category);
      }
      final info = JigsawInfo(e.path, e.path, e.title);
      info.photographer = e.category;
      info.id = JigsawInfo.stableIdFromPath(e.path);
      info.gridSize = 4;
      return info;
    }).toList(growable: false);
  }

  String _basename(String path) {
    final idx = path.lastIndexOf('/');
    return idx >= 0 && idx < path.length - 1 ? path.substring(idx + 1) : path;
  }
}
