// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_jigsaw_puzzle/src/loading_selection/loading_selection_screen.dart';
import 'package:flutter_jigsaw_puzzle/src/settings/about_screen.dart';
import 'package:flutter_jigsaw_puzzle/src/utils/sp_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'src/app_lifecycle/app_lifecycle.dart';
import 'src/audio/audio_controller.dart';
import 'src/level_selection/jigsaw_info.dart';
import 'src/level_selection/level_selection_screen.dart';
import 'src/main_menu/main_menu_screen.dart';
import 'src/play_session/play_session_screen.dart';
import 'src/settings/persistence/local_storage_settings_persistence.dart';
import 'src/settings/persistence/settings_persistence.dart';
import 'src/settings/settings.dart';
import 'src/settings/settings_screen.dart';
import 'src/style/my_transition.dart';
import 'src/style/palette.dart';
import 'src/style/snack_bar.dart';

Future<void> main() async {
  if (kReleaseMode) {
    // Don't log anything below warnings in production.
    Logger.root.level = Level.WARNING;
  }
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: '
        '${record.loggerName}: '
        '${record.message}');
  });
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);

  if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
    /// Prepare the google_mobile_ads plugin so that the first ad loads
    /// faster. This can be done later or with a delay if startup
    /// experience suffers.
  }
  await SpUtil().init();

  runApp(
    MyApp(
      settingsPersistence: LocalStorageSettingsPersistence(),
    ),
  );
}

class MyApp extends StatelessWidget {
  static final _router = GoRouter(
    routes: [
      GoRoute(
          path: '/',
          builder: (context, state) =>
              const MainMenuScreen(key: Key('main menu')),
          routes: [
            GoRoute(
                path: 'play',
                pageBuilder: (context, state) => buildMyTransition<void>(
                      child: const LevelSelectionScreen(
                          key: Key('level selection')),
                      color: context.watch<Palette>().backgroundMain,
                    ),
                routes: [
                  GoRoute(
                    path: 'loading',
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
                    path: 'session',
                    pageBuilder: (context, state) {
                      final jigsaw = state.extra! as JigsawInfo;
                      return buildMyTransition<void>(
                        child: PlaySessionScreen(
                          jigsaw,
                          key: const Key('play session'),
                        ),
                        color: context.watch<Palette>().backgroundMain,
                      );
                    },
                  ),
                ]),
            GoRoute(
                path: 'settings',
                builder: (context, state) =>
                    const SettingsScreen(key: Key('settings')),
                routes: [
                  GoRoute(
                    path: 'about',
                    builder: (context, state) => const AboutScreen(),
                  )
                ]),
          ]),
    ],
  );

  final SettingsPersistence settingsPersistence;

  const MyApp({
    required this.settingsPersistence,
    super.key,
  });

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
                create: (context) => SettingsController(
                  persistence: settingsPersistence,
                )..loadStateFromPersistence(),
              ),
              ProxyProvider2<SettingsController,
                  ValueNotifier<AppLifecycleState>, AudioController>(
                // Ensures that the AudioController is created on startup,
                // and not "only when it's needed", as is default behavior.
                // This way, music starts immediately.
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
              Provider(
                create: (context) => Palette(),
              ),
            ],
            child: Builder(builder: (context) {
              final palette = context.watch<Palette>();

              return MaterialApp.router(
                builder: EasyLoading.init(),
                title: 'Real Puzzle',
                theme: ThemeData.from(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: palette.btnOkColor,
                    background: palette.backgroundMain,
                  ),
                  textTheme: TextTheme(
                    bodyMedium: TextStyle(
                      color: palette.textColor,
                    ),
                  ),
                  useMaterial3: true,
                ),
                routeInformationProvider: _router.routeInformationProvider,
                routeInformationParser: _router.routeInformationParser,
                routerDelegate: _router.routerDelegate,
                scaffoldMessengerKey: scaffoldMessengerKey,
                showPerformanceOverlay: false,
              );
            }),
          ),
        );
      },
    );
  }
}
