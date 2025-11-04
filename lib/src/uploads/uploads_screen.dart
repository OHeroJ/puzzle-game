import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../history/puzzle_history.dart';
import '../level_selection/jigsaw_grid_item.dart';
import '../level_selection/jigsaw_info.dart';
import '../style/palette.dart';
import 'uploads_store.dart';

class UploadsScreen extends StatefulWidget {
  const UploadsScreen({super.key});

  @override
  State<UploadsScreen> createState() => _UploadsScreenState();
}

class _UploadsScreenState extends State<UploadsScreen> {
  late final UploadsStore _uploadsStore;
  List<JigsawInfo> _items = [];
  Set<int> _completedIds = <int>{};

  @override
  void initState() {
    super.initState();
    _uploadsStore = UploadsStore();
    _loadUploads();
    _loadCompletedIds();
  }

  Future<void> _loadUploads() async {
    final uploads = await _uploadsStore.toJigsaws();
    if (!mounted) return;
    setState(() {
      _items = uploads;
    });
  }

  Future<void> _loadCompletedIds() async {
    final entries = await PuzzleHistoryStore().load();
    final completed = entries.where((e) => e.success).map((e) => e.id).toSet();
    if (!mounted) return;
    setState(() {
      _completedIds = completed;
    });
  }

  Future<void> _triggerUpload() async {
    final entry = await _uploadsStore.pickAndSave();
    if (entry != null) {
      await _loadUploads();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已上传：${entry.title}')),
      );
    }
  }

  Future<void> _onDeleteUpload(JigsawInfo item) async {
    await _uploadsStore.remove(item.id);
    await _loadUploads();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已删除：${item.title}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: palette.backgroundMain,
        title: Text(
          '上传',
          style: TextStyle(
            color: palette.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: palette.backgroundMain,
      body: CustomScrollView(
        slivers: [
          if (_items.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Text(
                    '暂无上传',
                    style: TextStyle(
                      color: palette.textColor.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
            ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: JigsawGridItem(
                      info: item,
                      // 上传的图片无需加锁
                      locked: false,
                      showDelete: true,
                      onDelete: () => _onDeleteUpload(item),
                      onTap: () {
                        GoRouter.of(context).push('/play/loading', extra: item);
                      },
                      onViewHistory: () {
                        GoRouter.of(context)
                            .push('/history/image', extra: item.id);
                      },
                    ),
                  );
                },
                childCount: _items.length,
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 30.h)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: _triggerUpload,
        label: const Text('上传图片'),
        icon: const Icon(Icons.upload),
      ),
    );
  }
}
