// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
  final PagingController<int, JigsawInfo> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageId) async {
    try {
      final response = await DioClient.getInstance()
          .get(Api.image, params: {"page": pageId, "per_page": 15});
      final List<JigsawInfo> newLists = (response["photos"] as List)
          .map((ele) => JigsawInfo.fromJson(ele))
          .toList();
      final isLastPage = response["next_page"] == null;
      if (isLastPage) {
        _pagingController.appendLastPage(newLists);
      } else {
        final nextPageId = pageId + 1;
        _pagingController.appendPage(newLists, nextPageId);
      }
    } catch (error) {
      _pagingController.error = error;
      if (mounted) {
        CherryToast.error(title: Text(error.toString())).show(context);
      }
      print(error);
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
          'Real Puzzle',
          style: TextStyle(fontSize: 28.sp, color: palette.textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                GoRouter.of(context).push('/settings');
              },
              icon: Icon(Icons.settings, color: palette.textColor)),
        ],
      ),
      body: Center(
        child: Container(
          width: 0.9.sw,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                  child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Photos provided by Pexels',
                    style: TextStyle(fontSize: 16.sp, color: palette.textColor.withOpacity(0.7)),
                  ),
                ),
              )),
              PagedSliverGrid<int, JigsawInfo>(
                pagingController: _pagingController,
                showNewPageProgressIndicatorAsGridChild: false,
                showNewPageErrorIndicatorAsGridChild: false,
                showNoMoreItemsIndicatorAsGridChild: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 50 / 33,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 4,
                ),
                builderDelegate: PagedChildBuilderDelegate<JigsawInfo>(
                  itemBuilder: (context, item, index) => JigsawGridItem(
                    info: item,
                    onTap: () {
                      _showDetailsDialog(context, item, palette);
                    },
                  ),
                ),
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
    AwesomeDialog(
      dialogBackgroundColor: palette.backgroundMain,
      btnOkColor: palette.primaryColor,
      context: context,
      animType: AnimType.scale,
      width: 600.w,
      dialogType: DialogType.noHeader,
      body: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  'Pieces:',
                  style: TextStyle(fontStyle: FontStyle.italic, color: palette.textColor),
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
          width: 100.w,
          child: ElevatedButton(
            onPressed: () {
              item.gridSize = gridSizeValue;
              GoRouter.of(context).go('/play/loading/', extra: item);
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
    ).show();
  }

  Widget buildSelectGridSize(
      int num, int gridSizeValue, f(v), Palette palette) {
    return GestureDetector(
      onTap: () {
        f(num);
      },
      child: Container(
        width: 100.w,
        padding: EdgeInsets.only(left: 20.w, right: 20.w),
        margin: EdgeInsets.only(left: 8.w, right: 8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: gridSizeValue == num
              ? palette.primaryColor
              : palette.lightGray,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${num * num}",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 26.sp,
                    color: gridSizeValue == num ? Colors.white : palette.textColor)),
          ],
        ),
      ),
    );
  }
}