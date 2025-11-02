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
import 'package:google_fonts/google_fonts.dart';
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => GoRouter.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        centerTitle: true,
        backgroundColor: palette.backgroundMain,
        title: Text(
          '拼图',
          style: TextStyle(
            fontSize: 28.sp,
            color: palette.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              GoRouter.of(context).push('/settings');
            },
            icon: Icon(Icons.settings, color: palette.textColor),
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: 0.9.sw,
          child: CustomScrollView(
            scrollBehavior: MaterialScrollBehavior().copyWith(
              scrollbars: false,
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '分类：',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: palette.textColor.withOpacity(0.8),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      DropdownButton<String>(
                        value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
                        dropdownColor: palette.backgroundMain,
                        items: ['全部', ..._categories]
                            .map((c) => DropdownMenuItem<String>(
                                  value: c,
                                  child: Text(
                                    c,
                                    style: TextStyle(color: palette.textColor),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedCategory = value;
                            if (_selectedCategory == '我的上传') {
                              // 异步加载上传列表
                              _localItems = [];
                              _loadUploadsAndMerge();
                            } else if (_selectedCategory == '全部') {
                              _localItems =
                                  _buildItemsForCategory(_selectedCategory);
                              _loadUploadsAndMerge();
                            } else {
                              _localItems =
                                  _buildItemsForCategory(_selectedCategory);
                            }
                            // 通过刷新分页重新加载本地数据
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (_selectedCategory == '我的上传' && _localItems.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.w),
                      child: Text(
                        '正在加载“我的上传”...',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: palette.textColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_localItems.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.w),
                      child: Text(
                        '暂无图片',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: palette.textColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ),
              SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 50 / 33,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 1.sw > 500 ? 4 : 3,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = _localItems[index];
                    return JigsawGridItem(
                      info: item,
                      locked: !_completedIds.contains(item.id),
                      showDelete: _selectedCategory == '我的上传',
                      onDelete: _selectedCategory == '我的上传'
                          ? () => _onDeleteUpload(item)
                          : null,
                      onTap: () {
                        _showDetailsDialog(context, item, palette);
                      },
                    );
                  },
                  childCount: _localItems.length,
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 30.h)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _triggerUpload,
        label: const Text('上传图片'),
        icon: const Icon(Icons.upload),
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
                    fontStyle: FontStyle.italic,
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
        width: 120.w,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
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
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 28.sp,
                color: gridSizeValue == num ? Colors.white : palette.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _triggerUpload() async {
    final entry = await _uploadsStore.pickAndSave();
    if (entry != null) {
      await _loadUploadsAndMerge();
      // 如果当前不在“我的上传”，提示用户已添加
      if (mounted && _selectedCategory != '我的上传') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已添加到“我的上传”：${entry.title}')),
        );
      }
    }
  }

  Future<void> _onDeleteUpload(JigsawInfo item) async {
    await _uploadsStore.remove(item.id);
    await _loadUploadsAndMerge();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已删除：${item.title}')),
    );
  }
}
