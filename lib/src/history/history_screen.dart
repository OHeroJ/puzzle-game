import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:puzzle/src/history/puzzle_history.dart';
import 'package:puzzle/src/level_selection/jigsaw_info.dart';
import 'package:puzzle/src/level_selection/piece_image.dart';
import 'package:provider/provider.dart';

import '../style/palette.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<PuzzleHistoryEntry> _entries = [];
  String _statusFilter = '全部'; // 全部/进行中/已完成
  String _categoryFilter = '全部';
  final _store = PuzzleHistoryStore();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _store.load();
    setState(() {
      _entries = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final categories = [
      '全部',
      ...{..._entries.map((e) => e.photographer).where((e) => e.isNotEmpty)}
    ];
    final filtered = _entries.where((e) {
      final statusOk = _statusFilter == '全部'
          ? true
          : (_statusFilter == '进行中' ? !e.success : e.success);
      final categoryOk =
          _categoryFilter == '全部' ? true : (e.photographer == _categoryFilter);
      return statusOk && categoryOk;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: palette.backgroundMain,
        title: Text(
          '历史记录',
          style: TextStyle(
            color: palette.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await _store.clear();
              await _load();
            },
            icon: Icon(Icons.delete_forever, color: palette.textColor),
            tooltip: '清空历史',
          ),
        ],
      ),
      backgroundColor: palette.backgroundMain,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilter(
                  palette,
                  label: '状态：',
                  value: _statusFilter,
                  items: const ['全部', '进行中', '已完成'],
                  onChanged: (v) => setState(() => _statusFilter = v ?? '全部'),
                ),
                SizedBox(width: 12.w),
                _buildFilter(
                  palette,
                  label: '分类：',
                  value: _categoryFilter,
                  items: categories,
                  onChanged: (v) => setState(() => _categoryFilter = v ?? '全部'),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        '暂无历史记录',
                        style: TextStyle(
                            color: palette.textColor.withValues(alpha: 0.7)),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => SizedBox(height: 8.h),
                      itemBuilder: (context, index) {
                        final e = filtered[index];
                        return _HistoryTile(
                            entry: e,
                            onStart: () async {
                              final info = e.source == 'asset'
                                  ? JigsawInfo.fromAsset(
                                      e.image,
                                      title: e.title,
                                      photographer: e.photographer,
                                    )
                                  : () {
                                      final i =
                                          JigsawInfo(e.image, e.image, e.title);
                                      i.photographer = e.photographer;
                                      i.id =
                                          JigsawInfo.stableIdFromPath(e.image);
                                      return i;
                                    }();
                              info.gridSize = e.gridSize;

                              final entries = await PuzzleHistoryStore().load();
                              final unlocked = entries
                                  .any((e) => e.id == info.id && e.success);
                              info.unlocked = unlocked;

                              GoRouter.of(context)
                                  .push('/play/loading', extra: info);
                            });
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilter(Palette palette,
      {required String label,
      required String value,
      required List<String> items,
      required void Function(String?) onChanged}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(color: palette.textColor.withValues(alpha: 0.8)),
        ),
        SizedBox(width: 8.w),
        DropdownButton<String>(
          value: value,
          dropdownColor: palette.backgroundMain,
          items: items
              .map((c) => DropdownMenuItem<String>(
                    value: c,
                    child: Text(c, style: TextStyle(color: palette.textColor)),
                  ))
              .toList(),
          onChanged: onChanged,
        )
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final PuzzleHistoryEntry entry;
  final VoidCallback onStart;
  const _HistoryTile({required this.entry, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            SizedBox(
              width: 120.w,
              height: 80.w,
              child: PieceImage(pictureUrl: entry.image),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '分类：${entry.photographer.isNotEmpty ? entry.photographer : '未知'}',
                        style: TextStyle(
                            color: palette.textColor.withValues(alpha: 0.8))),
                    SizedBox(height: 4.w),
                    Text('块数：${entry.gridSize} x ${entry.gridSize}',
                        style: TextStyle(
                            color: palette.textColor.withValues(alpha: 0.8))),
                    SizedBox(height: 4.w),
                    Text(
                      entry.success
                          ? '已完成，用时：${(entry.elapsedMs ?? 0) / 1000}s'
                          : '进行中',
                      style: TextStyle(
                        color: entry.success ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('开始'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
