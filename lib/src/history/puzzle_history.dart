import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:puzzle/src/level_selection/jigsaw_info.dart';
import 'package:puzzle/src/utils/sp_util.dart';

/// 单次拼图历史记录
class PuzzleHistoryEntry {
  final int id; // 对应 JigsawInfo.id
  final String image; // 资源路径或网络 URL
  final String source; // asset | network
  final String title;
  final String photographer; // 可用作分类或作者
  final int gridSize;
  final String startedAt; // ISO 字符串
  final String? completedAt; // ISO 字符串
  final int? elapsedMs; // 完成时的用时毫秒
  final bool success;

  PuzzleHistoryEntry({
    required this.id,
    required this.image,
    required this.source,
    required this.title,
    required this.photographer,
    required this.gridSize,
    required this.startedAt,
    this.completedAt,
    this.elapsedMs,
    this.success = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
        'source': source,
        'title': title,
        'photographer': photographer,
        'gridSize': gridSize,
        'startedAt': startedAt,
        'completedAt': completedAt,
        'elapsedMs': elapsedMs,
        'success': success,
      };

  factory PuzzleHistoryEntry.fromJson(Map<String, dynamic> json) =>
      PuzzleHistoryEntry(
        id: json['id'] as int,
        image: json['image'] as String,
        source: json['source'] as String,
        title: (json['title'] ?? '') as String,
        photographer: (json['photographer'] ?? '') as String,
        gridSize: (json['gridSize'] ?? 4) as int,
        startedAt: json['startedAt'] as String,
        completedAt: json['completedAt'] as String?,
        elapsedMs: json['elapsedMs'] as int?,
        success: (json['success'] ?? false) as bool,
      );
}

/// 历史存储：使用 SharedPreferences(JSON) 持久化
class PuzzleHistoryStore {
  static const String _spKey = 'puzzle_history';
  // 用于通知外部：历史数据发生变化（例如完成拼图）
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  Future<List<PuzzleHistoryEntry>> load() async {
    final raw = SpUtil().getJSON(_spKey);
    if (raw == null) return [];
    final list = (raw as List)
        .map((e) => PuzzleHistoryEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return list;
  }

  Future<void> _save(List<PuzzleHistoryEntry> data) async {
    await SpUtil().setJSON(_spKey, data.map((e) => e.toJson()).toList());
  }

  /// 记录开始一局拼图
  Future<void> startPuzzle(JigsawInfo info,
      {required int gridSize, DateTime? startedAt}) async {
    final items = await load();
    final nowIso = (startedAt ?? DateTime.now()).toIso8601String();
    final src = info.image.startsWith('assets/') ? 'asset' : 'network';

    // 如果已有未完成记录，更新其开始时间与参数；否则追加新记录
    final idx = items.lastIndexWhere((e) => e.id == info.id && !e.success);
    final entry = PuzzleHistoryEntry(
      id: info.id,
      image: info.image,
      source: src,
      title: info.title,
      photographer: info.photographer,
      gridSize: gridSize,
      startedAt: nowIso,
    );
    if (idx >= 0) {
      items[idx] = entry;
    } else {
      items.add(entry);
    }
    await _save(items);
  }

  /// 标记完成一局拼图
  Future<void> completePuzzle(int id,
      {required int elapsedMs, DateTime? completedAt}) async {
    final items = await load();
    final idx = items.lastIndexWhere((e) => e.id == id && !e.success);
    if (idx >= 0) {
      final old = items[idx];
      items[idx] = PuzzleHistoryEntry(
        id: old.id,
        image: old.image,
        source: old.source,
        title: old.title,
        photographer: old.photographer,
        gridSize: old.gridSize,
        startedAt: old.startedAt,
        completedAt: (completedAt ?? DateTime.now()).toIso8601String(),
        elapsedMs: elapsedMs,
        success: true,
      );
      await _save(items);
      // 触发变更通知（用于刷新关卡列表的解锁状态）
      changes.value = changes.value + 1;
    }
  }

  /// 清空历史
  Future<void> clear() async {
    await SpUtil().remove(_spKey);
  }
}