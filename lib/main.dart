// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:puzzle/src/loading_selection/loading_selection_screen.dart';
import 'package:puzzle/src/settings/about_screen.dart';
import 'package:puzzle/src/utils/sp_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'src/app_lifecycle/app_lifecycle.dart';
import 'src/audio/audio_controller.dart';
import 'src/level_selection/jigsaw_info.dart';
import 'src/level_selection/level_selection_screen.dart';
// import 'src/main_menu/main_menu_screen.dart';
import 'src/home_tabs/home_tabs_scaffold.dart';
import 'src/uploads/uploads_screen.dart';
import 'src/play_session/play_session_screen.dart';
import 'src/history/history_screen.dart';
import 'src/history/image_history_screen.dart';
import 'src/settings/persistence/local_storage_settings_persistence.dart';
import 'src/settings/persistence/settings_persistence.dart';
import 'src/settings/settings.dart';
import 'src/settings/settings_screen.dart';
import 'src/settings/privacy_consent_screen.dart';
import 'src/style/my_transition.dart';
import 'src/style/palette.dart';
import 'src/style/snack_bar.dart';

Future<void> main() async {
  if (kReleaseMode) {
    // Don't log anything below warnings in production.
    Logger.root.level = Level.WARNING;
  }
  Logger.root.onRecord.listen((record) {
    debugPrint(
      '${record.level.name}: ${record.time}: '
      '${record.loggerName}: '
      '${record.message}',
    );
  });
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  // 默认显示状态栏与导航栏（除游戏页外不隐藏）
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
    /// Prepare the google_mobile_ads plugin so that the first ad loads
    /// faster. This can be done later or with a delay if startup
    /// experience suffers.
  }
  await SpUtil().init();

  runApp(MyApp(settingsPersistence: LocalStorageSettingsPersistence()));
}

class MyApp extends StatelessWidget {
  static final _router = GoRouter(
    initialLocation: '/play',
    redirect: (context, state) {
      final accepted = SpUtil().getBool('privacyAccepted') ?? false;
      final currentLocation = state.uri.toString();
      final onPrivacy = currentLocation == '/privacy';
      if (!accepted && !onPrivacy) {
        return '/privacy';
      }
      if (accepted && onPrivacy) {
        return '/play';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyConsentScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeTabsScaffold(child: child),
        routes: [
          GoRoute(
            path: '/play',
            builder: (context, state) =>
                const LevelSelectionScreen(key: Key('level selection')),
          ),
          GoRoute(
            path: '/uploads',
            builder: (context, state) => const UploadsScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => HistoryScreen(
              key: const Key('history'),
              filterId: state.extra is int ? state.extra as int : null,
            ),
          ),
          GoRoute(
            path: '/history/image',
            builder: (context, state) => ImageHistoryScreen(
              imageId: state.extra as int,
            ),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) =>
                const SettingsScreen(key: Key('settings')),
            routes: [
              GoRoute(
                path: 'about',
                builder: (context, state) => const AboutScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/play/loading',
        pageBuilder: (context, state) {
          final jigsaw = state.extra! as JigsawInfo;
          return buildMyTransition<void>(
            child: LoadingSelectionScreen(
              key: const Key('loading session'),
              level: jigsaw,
            ),
            color: context.watch<Palette>().backgroundMain,
          );
        },
      ),
      GoRoute(
        path: '/play/session',
        pageBuilder: (context, state) {
          final jigsaw = state.extra! as JigsawInfo;
          return buildMyTransition<void>(
            child: PlaySessionScreen(jigsaw, key: const Key('play session')),
            color: context.watch<Palette>().backgroundMain,
          );
        },
      ),
    ],
  );

  final SettingsPersistence settingsPersistence;

  const MyApp({required this.settingsPersistence, super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1067, 750),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return AppLifecycleObserver(
          child: MultiProvider(
            providers: [
              Provider<SettingsController>(
                lazy: false,
                create: (context) =>
                    SettingsController(persistence: settingsPersistence)
                      ..loadStateFromPersistence(),
              ),
              ProxyProvider2<SettingsController,
                  ValueNotifier<AppLifecycleState>, AudioController>(
                lazy: false,
                create: (context) => AudioController()..initialize(),
                update: (context, settings, lifecycleNotifier, audio) {
                  if (audio == null) throw ArgumentError.notNull();
                  audio.attachSettings(settings);
                  audio.attachLifecycleNotifier(lifecycleNotifier);
                  return audio;
                },
                dispose: (context, audio) => audio.dispose(),
              ),
              Provider(create: (context) => Palette()),
            ],
            child: Builder(
              builder: (context) {
                final palette = context.watch<Palette>();

                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  builder: EasyLoading.init(),
                  title: '有趣拼图',
                  theme: ThemeData(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: palette.primaryColor,
                      background: palette.backgroundMain,
                    ),
                    useMaterial3: true,
                  ),
                  routerConfig: _router,
                  scaffoldMessengerKey: scaffoldMessengerKey,
                  showPerformanceOverlay: false,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
