import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../style/palette.dart';
import '../user/user_manager.dart';
import 'ranking_manager.dart';
import 'ranking.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  @override
  void initState() {
    super.initState();
    // 初始化时获取排行榜数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rankingManager = context.read<RankingManager>();
      rankingManager.fetchRankings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final rankingManager = context.watch<RankingManager>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            GoRouter.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        centerTitle: true,
        backgroundColor: palette.backgroundMain,
        title: Text(
          '排行榜',
          style: TextStyle(
            fontSize: 28.sp,
            color: palette.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: palette.backgroundMain,
      body: RefreshIndicator(
        onRefresh: () async {
          await rankingManager.fetchRankings();
        },
        child: rankingManager.isLoading
            ? _buildLoadingIndicator(palette)
            : _buildRankingList(rankingManager.rankings, palette),
      ),
    );
  }

  Widget _buildLoadingIndicator(Palette palette) {
    return Center(
      child: CircularProgressIndicator(
        color: palette.primaryColor,
      ),
    );
  }

  Widget _buildRankingList(List<Ranking> rankings, Palette palette) {
    if (rankings.isEmpty) {
      return Center(
        child: Text(
          '暂无排行榜数据',
          style: TextStyle(
            fontSize: 16.sp,
            color: palette.textColor.withOpacity(0.7),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: rankings.length,
      itemBuilder: (context, index) {
        final ranking = rankings[index];
        final isCurrentUser = _isCurrentUser(ranking.userId);

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? palette.primaryColor.withOpacity(0.2)
                : palette.secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
            border: isCurrentUser
                ? Border.all(color: palette.primaryColor, width: 2.w)
                : null,
          ),
          child: Row(
            children: [
              // 排名
              Container(
                width: 30.w,
                height: 30.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _getRankColor(index),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              
              // 用户头像
              CircleAvatar(
                radius: 20.r,
                backgroundColor: palette.primaryColor,
                child: ranking.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          ranking.avatarUrl!,
                          fit: BoxFit.cover,
                          width: 40.w,
                          height: 40.w,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 20.sp,
                              color: Colors.white,
                            );
                          },
                        ),
                      )
                    : Text(
                        ranking.username.substring(0, 1),
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
              ),
              SizedBox(width: 16.w),
              
              // 用户名和分数
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ranking.username,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: palette.textColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '分数: ${ranking.score}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: palette.textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 时间
              Text(
                _formatDateTime(ranking.createdAt),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: palette.textColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isCurrentUser(String userId) {
    final userManager = context.read<UserManager>();
    return userManager.isSignedIn && userManager.currentUser?.id == userId;
  }

  Color _getRankColor(int index) {
    final palette = context.read<Palette>();
    switch (index) {
      case 0:
        return Colors.orange; // 第一名 - 橙色
      case 1:
        return Colors.grey; // 第二名 - 灰色
      case 2:
        return Colors.brown; // 第三名 - 棕色
      default:
        return palette.primaryColor; // 其他 - 主色调
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}