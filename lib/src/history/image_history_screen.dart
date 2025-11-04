import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:puzzle/src/history/puzzle_history.dart';
import 'package:puzzle/src/level_selection/jigsaw_info.dart';
import 'package:puzzle/src/level_selection/piece_image.dart';
import 'package:puzzle/src/style/palette.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ImageHistoryScreen extends StatefulWidget {
  const ImageHistoryScreen({super.key, required this.imageId});
  final int imageId;

  @override
  State<ImageHistoryScreen> createState() => _ImageHistoryScreenState();
}

class _ImageHistoryScreenState extends State<ImageHistoryScreen> {
  List<PuzzleHistoryEntry>? _entries;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final store = PuzzleHistoryStore();
    final all = await store.load();
    final filtered = all.where((e) => e.id == widget.imageId).toList()
      ..sort((a, b) {
        final aTime = a.completedAt != null
            ? DateTime.parse(a.completedAt!)
            : DateTime.parse(a.startedAt);
        final bTime = b.completedAt != null
            ? DateTime.parse(b.completedAt!)
            : DateTime.parse(b.startedAt);
        return bTime.compareTo(aTime);
      });
    setState(() {
      _entries = filtered;
      _loading = false;
    });
  }

  String _formatIso(String iso) {
    final dt = DateTime.parse(iso);
    final fmt = DateFormat('yyyy-MM-dd HH:mm');
    return fmt.format(dt);
  }

  Future<void> _start(PuzzleHistoryEntry e) async {
    final info = JigsawInfo(e.image, e.image, e.title);
    info.photographer = e.photographer;
    info.id = e.id;
    info.gridSize = e.gridSize;

    final entries = await PuzzleHistoryStore().load();
    final unlocked = entries.any((it) => it.id == info.id && it.success);
    info.unlocked = unlocked;

    GoRouter.of(context).push('/play/loading', extra: info);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final entries = _entries;
    return Scaffold(
      appBar: AppBar(
        title: const Text('图片历史'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (entries == null || entries.isEmpty)
              ? const Center(child: Text('暂无该图片的历史记录'))
              : ListView.separated(
                  padding: EdgeInsets.all(12.w),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final e = entries[index];
                    final statusText = e.success == true
                        ? '已完成'
                        : (e.completedAt == null ? '进行中' : '未完成');
                    final timeLabel = e.completedAt != null ? '完成时间' : '开始时间';
                    final timeText = _formatIso(e.completedAt ?? e.startedAt);
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
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: PieceImage(
                                pictureUrl: e.image,
                                unlocked: true,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 12.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 10.w,
                                    runSpacing: 8.w,
                                    children: [
                                      Chip(
                                        label: Text(
                                          '${e.gridSize}×${e.gridSize}',
                                          style: TextStyle(
                                              color: palette.textColor),
                                        ),
                                        backgroundColor: palette.lightGray,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      Chip(
                                        label: Text(
                                          statusText,
                                          style: TextStyle(
                                            color: e.success == true
                                                ? Colors.green
                                                : Colors.orange,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        backgroundColor: (e.success == true
                                                ? Colors.green
                                                : Colors.orange)
                                            .withValues(alpha: 0.1),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Text('$timeLabel：$timeText',
                                      style:
                                          TextStyle(color: palette.textColor)),
                                  SizedBox(height: 12.h),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => _start(e),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: palette.primaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12.h),
                                      ),
                                      child: const Text('开始该记录的拼图'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
