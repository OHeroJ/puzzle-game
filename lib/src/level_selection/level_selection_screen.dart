// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
// 改为使用本地图片，不再依赖网络
import 'package:puzzle/src/level_selection/local_image_service.dart';
import 'package:puzzle/src/uploads/uploads_store.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
// 移除分页依赖，改为一次性渲染 SliverGrid
import 'package:provider/provider.dart';

import '../style/palette.dart';
import 'jigsaw_grid_item.dart';
import 'jigsaw_info.dart';
import '../history/puzzle_history.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  late String _selectedCategory;
  late List<String> _categories;
  late List<JigsawInfo> _localItems;
  late final LocalImageService _localService;
  late final UploadsStore _uploadsStore;
  Set<int> _completedIds = <int>{};
  // 记录上传图片的 id，用于在“全部”中识别上传项并取消加锁
  Set<int> _uploadIds = <int>{};
  VoidCallback? _historyListener;

  @override
  void initState() {
    _localService = LocalImageService();
    _uploadsStore = UploadsStore();
    _categories = _localService.categories;
    if (!_categories.contains('我的上传')) {
      _categories = [..._categories, '我的上传'];
    }
    _selectedCategory = '全部';
    _localItems = _localService.allJigsaws();

    // 直接使用本地数据与上传合并后的集合进行展示

    // 异步加载用户上传合并到“全部”
    _loadUploadsAndMerge();

    _loadCompletedIds();

    // 监听历史完成事件，主动刷新解锁状态
    _historyListener = () {
      _loadCompletedIds();
    };
    PuzzleHistoryStore.changes.addListener(_historyListener!);

    super.initState();
  }

  Future<void> _loadCompletedIds() async {
    final entries = await PuzzleHistoryStore().load();
    final completed = entries.where((e) => e.success).map((e) => e.id).toSet();
    if (mounted) {
      setState(() {
        _completedIds = completed;
      });
    }
  }

  // 移除分页回调，改为一次性渲染

  List<JigsawInfo> _buildItemsForCategory(String category) {
    if (category == '全部') {
      // 合并本地与上传
      return [..._localService.allJigsaws()];
    }
    if (category == '我的上传') {
      // 仅显示上传
      // 注意：此方法在异步加载后通过 _localItems 更新分页
      return [];
    }
    return _localService.jigsawsForCategory(category);
  }

  Future<void> _loadUploadsAndMerge() async {
    final uploads = await _uploadsStore.toJigsaws();
    if (mounted) {
      setState(() {
        _uploadIds = uploads.map((e) => e.id).toSet();
        if (_selectedCategory == '我的上传') {
          _localItems = uploads;
        } else if (_selectedCategory == '全部') {
          _localItems = [..._localService.allJigsaws(), ...uploads];
        }
        // 直接触发重建
      });
    }
  }

  @override
  void dispose() {
    if (_historyListener != null) {
      PuzzleHistoryStore.changes.removeListener(_historyListener!);
      _historyListener = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final tabs = ['全部', ..._categories];
    final initialIndex = tabs.indexOf(_selectedCategory);
    return DefaultTabController(
      initialIndex: initialIndex < 0 ? 0 : initialIndex,
      length: tabs.length,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              centerTitle: true,
              backgroundColor: palette.backgroundMain,
              title: Text(
                '拼图',
                style: TextStyle(
                  color: palette.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottom: TabBar(
                dividerColor: Colors.transparent,
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.symmetric(vertical: 6),
                indicator: ShapeDecoration(
                  shape: StadiumBorder(
                    side: BorderSide(color: palette.primaryColor, width: 2),
                  ),
                ),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.normal),
                indicatorColor: palette.primaryColor,
                labelColor: palette.textColor,
                unselectedLabelColor: palette.textColor.withValues(alpha: 0.6),
                tabs: tabs.map((c) => Tab(text: c)).toList(),
                onTap: (index) {
                  final value = tabs[index];
                  setState(() {
                    _selectedCategory = value;
                    if (_selectedCategory == '我的上传') {
                      _localItems = [];
                      _loadUploadsAndMerge();
                    } else if (_selectedCategory == '全部') {
                      _localItems = _buildItemsForCategory(_selectedCategory);
                      _loadUploadsAndMerge();
                    } else {
                      _localItems = _buildItemsForCategory(_selectedCategory);
                    }
                  });
                },
              ),
            ),
          ],
          body: CustomScrollView(
            slivers: [
              // TabBar 已移动至 AppBar.bottom，实现吸顶
              if (_localItems.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      child: Text(
                        '暂无图片',
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
                      final item = _localItems[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: JigsawGridItem(
                          info: item,
                          // 上传的图片无需加锁；其他图片根据通关记录决定
                          locked: _uploadIds.contains(item.id)
                              ? false
                              : !_completedIds.contains(item.id),
                          showDelete: false,
                          onDelete: null,
                          onTap: () {
                            _showDetailsDialog(context, item, palette);
                          },
                          onViewHistory: () {
                            GoRouter.of(context)
                                .push('/history/image', extra: item.id);
                          },
                        ),
                      );
                    },
                    childCount: _localItems.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 30.h)),
            ],
          ),
        ),
        // 上传入口已迁移至“上传”标签页
      ),
    );
  }

  void _showDetailsDialog(
    BuildContext context,
    JigsawInfo item,
    Palette palette,
  ) {
    var gridSizeValue = 4;
    late AwesomeDialog dialog;
    dialog = AwesomeDialog(
      dialogBackgroundColor: palette.backgroundMain,
      btnOkColor: palette.primaryColor,
      context: context,
      animType: AnimType.scale,
      width: (1.sw > 500 ? 700.w : 0.95.sw),
      dialogType: DialogType.noHeader,
      body: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  '拼图块数',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: palette.textColor,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildSelectGridSize(2, gridSizeValue, (v) {
                      setState(() {
                        gridSizeValue = v;
                      });
                    }, palette),
                    buildSelectGridSize(4, gridSizeValue, (v) {
                      setState(() {
                        gridSizeValue = v;
                      });
                    }, palette),
                    buildSelectGridSize(5, gridSizeValue, (v) {
                      setState(() {
                        gridSizeValue = v;
                      });
                    }, palette),
                    buildSelectGridSize(6, gridSizeValue, (v) {
                      setState(() {
                        gridSizeValue = v;
                      });
                    }, palette),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildSelectGridSize(7, gridSizeValue, (v) {
                      setState(() {
                        gridSizeValue = v;
                      });
                    }, palette),
                    buildSelectGridSize(8, gridSizeValue, (v) {
                      setState(() {
                        gridSizeValue = v;
                      });
                    }, palette),
                    buildSelectGridSize(9, gridSizeValue, (v) {
                      setState(() {
                        gridSizeValue = v;
                      });
                    }, palette),
                    buildSelectGridSize(10, gridSizeValue, (v) {
                      setState(() {
                        gridSizeValue = v;
                      });
                    }, palette),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      btnOk: Center(
        child: Container(
          child: ElevatedButton(
            onPressed: () async {
              dialog.dismiss();
              item.gridSize = gridSizeValue;
              final entries = await PuzzleHistoryStore().load();
              final unlocked = entries.any((e) => e.id == item.id && e.success);
              item.unlocked = unlocked;
              GoRouter.of(context).push('/play/loading', extra: item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: palette.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("开始"),
          ),
        ),
      ),
    )..show();
  }

  Widget buildSelectGridSize(
    int num,
    int gridSizeValue,
    f(v),
    Palette palette,
  ) {
    return GestureDetector(
      onTap: () {
        f(num);
      },
      child: Container(
        width: 150.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.w),
        margin: EdgeInsets.only(left: 10.w, right: 10.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color:
              gridSizeValue == num ? palette.primaryColor : palette.lightGray,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${num * num}",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: gridSizeValue == num ? Colors.white : palette.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 上传与删除已迁移至“上传”标签页
}
