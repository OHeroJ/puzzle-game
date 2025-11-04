import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:puzzle/src/history/puzzle_history.dart';
import 'package:puzzle/src/level_selection/jigsaw_info.dart';
import 'package:puzzle/src/level_selection/piece_image.dart';
import 'package:provider/provider.dart';

import '../style/palette.dart';

class HistoryScreen extends StatefulWidget {
  final int? filterId;
  const HistoryScreen({super.key, this.filterId});
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
    var filtered = _entries.where((e) {
      final statusOk = _statusFilter == '全部'
          ? true
          : (_statusFilter == '进行中' ? !e.success : e.success);
      final categoryOk =
          _categoryFilter == '全部' ? true : (e.photographer == _categoryFilter);
      return statusOk && categoryOk;
    }).toList();
    // 如果带入了指定图片的过滤 id，仅显示该图片的历史
    if (widget.filterId != null) {
      filtered = filtered.where((e) => e.id == widget.filterId).toList();
    }
    // 按时间倒序：已完成用 completedAt，否则用 startedAt
    filtered.sort((a, b) {
      final aTime = a.completedAt != null
          ? DateTime.parse(a.completedAt!)
          : DateTime.parse(a.startedAt);
      final bTime = b.completedAt != null
          ? DateTime.parse(b.completedAt!)
          : DateTime.parse(b.startedAt);
      return bTime.compareTo(aTime);
    });

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
            onPressed: () => _showFilterSheet(categories),
            icon: Icon(Icons.filter_list, color: palette.textColor),
            tooltip: '筛选',
          ),
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
      body: Column(
        children: [
          
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
                    padding: EdgeInsets.all(12),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
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
                                    i.id = JigsawInfo.stableIdFromPath(e.image);
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
    );
  }

  void _showFilterSheet(List<String> categories) {
    final palette = context.read<Palette>();
    String statusTemp = _statusFilter;
    String categoryTemp = _categoryFilter;
    final statuses = const ['全部', '进行中', '已完成'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.backgroundMain,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 12.h,
                bottom: MediaQuery.of(context).viewPadding.bottom + 16.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: palette.lightGray,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '筛选',
                    style: TextStyle(
                      color: palette.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text('状态',
                      style: TextStyle(
                          color: palette.textColor.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 8.h,
                    children: [
                      ...statuses.map((s) {
                        final selected = statusTemp == s;
                        return ChoiceChip(
                          label: Text(
                            s,
                            style: TextStyle(
                              color:
                                  selected ? Colors.white : palette.textColor,
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                          selected: selected,
                          selectedColor: palette.primaryColor,
                          backgroundColor: palette.lightGray,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onSelected: (_) =>
                              setModalState(() => statusTemp = s),
                        );
                      }),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text('分类',
                      style: TextStyle(
                          color: palette.textColor.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 8.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((c) {
                        final selected = categoryTemp == c;
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: ChoiceChip(
                            label: Text(
                              c,
                              style: TextStyle(
                                color:
                                    selected ? Colors.white : palette.textColor,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            selected: selected,
                            selectedColor: palette.primaryColor,
                            backgroundColor: palette.lightGray,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            onSelected: (_) =>
                                setModalState(() => categoryTemp = c),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            statusTemp = '全部';
                            categoryTemp = '全部';
                          });
                        },
                        child: Text('重置',
                            style: TextStyle(color: palette.textColor)),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _statusFilter = statusTemp;
                            _categoryFilter = categoryTemp;
                          });
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: palette.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 10.h, horizontal: 16.w),
                        ),
                        child: const Text('应用'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 顶部大图，采用移动端友好的 16:9 比例
            AspectRatio(
              aspectRatio: 16 / 9,
              child: PieceImage(
                pictureUrl: entry.image,
                unlocked: entry.success,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 8.w,
                    children: [
                      Chip(
                        label: Text(
                          entry.photographer.isNotEmpty
                              ? entry.photographer
                              : '未知分类',
                          style: TextStyle(color: palette.textColor),
                        ),
                        backgroundColor: palette.lightGray,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      Chip(
                        label: Text(
                          '${entry.gridSize}×${entry.gridSize}',
                          style: TextStyle(color: palette.textColor),
                        ),
                        backgroundColor: palette.lightGray,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      Chip(
                        label: Text(
                          entry.success
                              ? '已完成 ${(entry.elapsedMs ?? 0) / 1000}s'
                              : '进行中',
                          style: TextStyle(
                            color: entry.success ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: entry.success
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: const Text('开始'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
