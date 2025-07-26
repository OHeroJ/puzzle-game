// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:supabase/supabase.dart' as supabase;

import 'firebase_options.dart';
import 'src/app_lifecycle/app_lifecycle.dart';
import 'src/config/supabase_config.dart';
import 'src/level_selection/level_selection_screen.dart';
import 'src/level_selection/jigsaw_info.dart';
import 'src/loading_selection/loading_selection_screen.dart';
import 'src/main_menu/main_menu_screen.dart';
import 'src/play_session/play_session_screen.dart';
import 'src/ranking/ranking_manager.dart';
import 'src/ranking/ranking_screen.dart';
import 'src/settings/settings.dart';
import 'src/settings/persistence/local_storage_settings_persistence.dart';
import 'src/settings/settings_screen.dart';
import 'src/style/palette.dart';
import 'src/user/login_screen.dart';
import 'src/user/register_screen.dart';
import 'src/user/user_manager.dart';

Future<void> main() async {
  // A temporary workaround to avoid issues on web.
  // See: https://github.com/firebase/firebase-dart/issues/746
  if (!kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Disable print() in production.
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // Enable logging (release and debug) in the console.
  Logger.root.level = kReleaseMode ? Level.WARNING : Level.ALL;
  Logger.root.onRecord.listen((record) {
    if (kReleaseMode) {
      // In release mode, only log warnings and errors.
      if (record.level >= Level.WARNING) {
        debugPrint('${record.level.name}: ${record.time}: '
            '${record.loggerName}: '
            '${record.message}');
      }
    } else {
      // In debug mode, log everything.
      debugPrint('${record.level.name}: ${record.time}: '
          '${record.loggerName}: '
          '${record.message}');
    }
  });
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    Logger('FlutterError')
        .severe(details.exception, details.stack);
  };

  if (!kIsWeb) {
    // Report uncaught errors.
    PlatformDispatcher.instance.onError = (error, stack) {
      Logger('PlatformDispatcher').severe('Uncaught error', error, stack);
      if (!kReleaseMode) {
        // In debug mode, print the error to the console.
        debugPrint('PlatformDispatcher: $error\n$stack');
      }
      return true;
    };
  }

  // Report errors to Crashlytics.
  if (!kDebugMode && !kIsWeb) {
    FlutterError.onError = (FlutterErrorDetails details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Set up routing.
  final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const MainMenuScreen();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'play',
            builder: (BuildContext context, GoRouterState state) {
              // 创建一个默认的JigsawInfo对象
              final level = JigsawInfo(
                'https://images.pexels.com/photos/1366957/pexels-photo-1366957.jpeg',
                'https://images.pexels.com/photos/1366957/pexels-photo-1366957.jpeg',
                'Default Puzzle',
                3,
                'https://images.pexels.com/photos/1366957/pexels-photo-1366957.jpeg',
              );
              return LoadingSelectionScreen(level: level);
            },
          ),
          GoRoute(
            path: 'levelSelection',
            builder: (BuildContext context, GoRouterState state) {
              return const LevelSelectionScreen();
            },
          ),
          GoRoute(
            path: 'playSession/:levelId',
            builder: (BuildContext context, GoRouterState state) {
              final levelId = state.pathParameters['levelId']!;
              final level = JigsawInfo.getJigsawInfo(levelId);
              return PlaySessionScreen(level);
            },
          ),
          GoRoute(
            path: 'settings',
            builder: (BuildContext context, GoRouterState state) {
              return const SettingsScreen();
            },
          ),
          GoRoute(
            path: 'login',
            builder: (BuildContext context, GoRouterState state) {
              return const LoginScreen();
            },
          ),
          GoRoute(
            path: 'register',
            builder: (BuildContext context, GoRouterState state) {
              return const RegisterScreen();
            },
          ),
          GoRoute(
            path: 'ranking',
            builder: (BuildContext context, GoRouterState state) {
              return const RankingScreen();
            },
          ),
        ],
      ),
    ],
  );

  // Set up analytics.
  FirebaseAnalytics? analytics;
  if (!kIsWeb) {
    analytics = FirebaseAnalytics.instance;
  }

  // Run the app.
  runApp(
    MyApp(
      router: router,
      analytics: analytics,
    ),
  );
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  final FirebaseAnalytics? analytics;

  const MyApp({
    required this.router,
    this.analytics,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MultiProvider(
        providers: [
          Provider<GoRouter>.value(value: router),
          Provider<FirebaseAnalytics?>.value(value: analytics),
          ChangeNotifierProvider(
            create: (context) => Palette(),
          ),
          ChangeNotifierProvider(
            create: (context) => SettingsController(
              persistence: LocalStorageSettingsPersistence(),
            ),
          ),
          // 初始化Supabase客户端
          Provider<supabase.SupabaseClient>(
            create: (context) => supabase.SupabaseClient(
              SupabaseConfig.supabaseUrl,
              SupabaseConfig.supabaseAnonKey,
            ),
          ),
          // 初始化用户管理器
          ChangeNotifierProvider(
            create: (context) => UserManager(),
          ),
          // 初始化排行榜管理器
          ChangeNotifierProvider(
            create: (context) {
              final supabaseClient = context.read<supabase.SupabaseClient>();
              final userManager = context.read<UserManager>();
              return RankingManager(supabaseClient, userManager);
            },
          ),
        ],
        child: Consumer2<Palette, SettingsController>(
          builder: (context, palette, settings, child) {
            return ScreenUtilInit(
              designSize: const Size(411, 839),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, child) {
                return MaterialApp.router(
                  title: 'Puzzle',
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData(
                    useMaterial3: true,
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: palette.primaryColor,
                      background: palette.backgroundMain,
                    ),
                    scaffoldBackgroundColor: palette.backgroundMain,
                    textSelectionTheme: TextSelectionThemeData(
                      cursorColor: palette.primaryColor,
                      selectionColor: palette.primaryColor.withOpacity(0.3),
                      selectionHandleColor: palette.primaryColor,
                    ),
                  ),
                  routeInformationProvider: router.routeInformationProvider,
                  routeInformationParser: router.routeInformationParser,
                  routerDelegate: router.routerDelegate,
                );
              },
            );
          },
        ),
      ),
    );
  }
}