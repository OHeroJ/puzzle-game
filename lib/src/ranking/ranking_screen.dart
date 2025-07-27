// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../style/palette.dart';
import '../widgets/responsive_widget.dart';
import 'ranking.dart';
import 'ranking_manager.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  @override
  void initState() {
    super.initState();
    // 延迟加载排行榜数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rankingManager = context.read<RankingManager>();
      rankingManager.getRankings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final rankingManager = context.watch<RankingManager>();

    return ResponsiveWidget(
      desktopBody: _buildBody(palette, rankingManager, true),
      mobileBody: _buildBody(palette, rankingManager, false),
    );
  }

  Widget _buildBody(Palette palette, RankingManager rankingManager, bool isDesktop) {
    return Scaffold(
      backgroundColor: palette.backgroundMain,
      appBar: AppBar(
        title: Text(
          '排行榜',
          style: TextStyle(
            color: palette.textColor,
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: palette.backgroundMain,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: palette.textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => rankingManager.getRankings(),
        child: Container(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Top Players',
                style: TextStyle(
                  color: palette.textColor,
                  fontSize: isDesktop ? 20 : 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: rankingManager.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : rankingManager.rankings.isEmpty
                        ? Center(
                            child: Text(
                              '暂无排行榜数据',
                              style: TextStyle(
                                color: palette.textColor,
                                fontSize: isDesktop ? 18 : 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: rankingManager.rankings.length,
                            itemBuilder: (context, index) {
                              final ranking = rankingManager.rankings[index];
                              return _buildRankingItem(
                                ranking,
                                index + 1,
                                palette,
                                isDesktop,
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankingItem(
      Ranking ranking, int rank, Palette palette, bool isDesktop) {
    return Card(
      color: palette.backgroundLevel1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: palette.primaryColor,
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          ranking.username,
          style: TextStyle(
            color: palette.textColor,
            fontSize: isDesktop ? 16 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Text(
          '${ranking.score}',
          style: TextStyle(
            color: palette.primaryColor,
            fontSize: isDesktop ? 18 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }


}