import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../style/palette.dart';

class HomeTabsScaffold extends StatelessWidget {
  final Widget child;

  const HomeTabsScaffold({super.key, required this.child});

  int _indexForLocation(String location) {
    if (location.startsWith('/settings')) return 2;
    if (location.startsWith('/history')) return 1;
    // 默认拼图列表
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final location = GoRouter.of(context).state.uri.toString();
    final index = _indexForLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        backgroundColor: palette.backgroundMain,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/play');
              break;
            case 1:
              context.go('/history');
              break;
            case 2:
              context.go('/settings');
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view), label: '拼图'),
          NavigationDestination(icon: Icon(Icons.history), label: '历史'),
          NavigationDestination(icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }
}
