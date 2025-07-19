// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jigsaw_puzzle/src/http/api.dart';
import 'package:flutter_jigsaw_puzzle/src/http/dio_client.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../style/palette.dart';
import 'jigsaw_grid_item.dart';
import 'jigsaw_info.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  late final PagingController<int, JigsawInfo> _pagingController;

  @override
  void initState() {
    _pagingController = PagingController<int, JigsawInfo>(
        fetchPage: _fetchPage,
        getNextPageKey: (PagingState<int, JigsawInfo> state) {
          return state.lastPageIsEmpty ? null : state.nextIntPageKey;
        });

    super.initState();
  }

  Future<List<JigsawInfo>> _fetchPage(int pageId) async {
    try {
      final response = await DioClient.getInstance()
          .get(Api.image, params: {"page": pageId, "per_page": 15});
      final List<JigsawInfo> newLists = (response["photos"] as List)
          .map((ele) => JigsawInfo.fromJson(ele))
          .toList();
      return newLists;
    } catch (error) {
      _pagingController.value = _pagingController.value.copyWith(error: error);
      return [];
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
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
          'Puzzles',
          style: TextStyle(
              fontSize: 28.sp,
              color: palette.textColor,
              fontWeight: FontWeight.bold),
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
            scrollBehavior:
                MaterialScrollBehavior().copyWith(scrollbars: false),
            slivers: [
              SliverToBoxAdapter(
                  child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Photos provided by Pexels',
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: palette.textColor.withOpacity(0.7)),
                  ),
                ),
              )),
              PagingListener(
                controller: _pagingController,
                builder: (context, state, fetchNextPage) {
                  return PagedSliverGrid<int, JigsawInfo>(
                    showNewPageProgressIndicatorAsGridChild: false,
                    showNewPageErrorIndicatorAsGridChild: false,
                    showNoMoreItemsIndicatorAsGridChild: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 50 / 33,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      crossAxisCount: 1.sw > 500 ? 4 : 3,
                    ),
                    builderDelegate: PagedChildBuilderDelegate<JigsawInfo>(
                      itemBuilder: (context, item, index) => JigsawGridItem(
                        info: item,
                        onTap: () {
                          _showDetailsDialog(context, item, palette);
                        },
                      ),
                    ),
                    state: state,
                    fetchNextPage: fetchNextPage,
                  );
                },
              ),
              SliverToBoxAdapter(
                  child: SizedBox(
                height: 30.h,
              ))
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsDialog(
      BuildContext context, JigsawInfo item, Palette palette) {
    var gridSizeValue = 4;
    late AwesomeDialog dialog;
    dialog = AwesomeDialog(
      dialogBackgroundColor: palette.backgroundMain,
      btnOkColor: palette.primaryColor,
      context: context,
      animType: AnimType.scale,
      width: (1.sw > 500 ? 600.w : 0.95.sw),
      dialogType: DialogType.noHeader,
      body: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  'Pieces',
                  style: TextStyle(
                      fontStyle: FontStyle.italic, color: palette.textColor),
                ),
                SizedBox(
                  height: 20.h,
                ),
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
                SizedBox(
                  height: 20.h,
                ),
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
                    }, palette)
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
            onPressed: () {
              dialog.dismiss();
              item.gridSize = gridSizeValue;
              GoRouter.of(context).push('/play/loading', extra: item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: palette.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Start"),
          ),
        ),
      ),
    )..show();
  }

  Widget buildSelectGridSize(
      int num, int gridSizeValue, f(v), Palette palette) {
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
            Text("${num * num}",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 28.sp,
                    color: gridSizeValue == num
                        ? Colors.white
                        : palette.textColor)),
          ],
        ),
      ),
    );
  }
}
