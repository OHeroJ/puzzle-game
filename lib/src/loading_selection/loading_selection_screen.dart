import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../level_selection/jigsaw_info.dart';
import '../level_selection/piece_image.dart';

class LoadingSelectionScreen extends StatefulWidget {
  final int level;

  const LoadingSelectionScreen({super.key, required this.level});

  @override
  State<LoadingSelectionScreen> createState() => _LoadingSelectionScreenState();
}

//GoRouter.of(context).go('/play/loading/', extra: item);
class _LoadingSelectionScreenState extends State<LoadingSelectionScreen> {
  double p = 0;
  int date = 0;

  @override
  void initState() {
    super.initState();
    date = DateTime.now().microsecondsSinceEpoch;
  }

  @override
  Widget build(BuildContext context) {
    final jigsawInfo = JigsawInfo.getJigsawInfo(widget.level.toString());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 300.w,
                height: 300.w,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: PieceImage(
                        pictureUrl: jigsawInfo.imageUrl,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: PieceImage(
                        pictureUrl: jigsawInfo.imageUrl,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: PieceImage(
                        pictureUrl: jigsawInfo.imageUrl,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: PieceImage(
                        pictureUrl: jigsawInfo.imageUrl,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50.h),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 50.h),
              SizedBox(
                width: 300.w,
                child: LinearProgressIndicator(
                  value: p,
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (p == 0) {
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          p = 0.3;
        });
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        setState(() {
          p = 0.6;
        });
      });
      Future.delayed(const Duration(milliseconds: 900), () {
        setState(() {
          p = 0.9;
        });
      });
      Future.delayed(const Duration(milliseconds: 1200), () {
        setState(() {
          p = 1.0;
        });
        int now = DateTime.now().microsecondsSinceEpoch;
        if (now - date > 1500000) {
          GoRouter.of(context).go('/play', extra: widget.level);
        } else {
          Future.delayed(const Duration(microseconds: 1500000), () {
            GoRouter.of(context).go('/play', extra: widget.level);
          });
        }
      });
    }
  }
}
