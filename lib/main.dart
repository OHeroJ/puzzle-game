// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'firebase_options.dart';
import 'src/app_lifecycle/app_lifecycle.dart';
import 'src/audio/audio_controller.dart';
import 'src/config/supabase_config.dart';
import 'src/level_selection/level_selection_screen.dart';
import 'src/loading_selection/loading_selection_screen.dart';
import 'src/main_menu/main_menu_screen.dart';
import 'src/play_session/play_session_screen.dart';
import 'src/ranking/ranking_manager.dart';
import 'src/ranking/ranking_screen.dart';
import 'src/settings/about_screen.dart';
import 'src/settings/persistence/local_storage_settings_persistence.dart';
import 'src/settings/persistence/supabase_settings_persistence.dart';
import 'src/settings/settings.dart';
import 'src/settings/settings_screen.dart';
import 'src/style/palette.dart';
import 'src/user/login_screen.dart';
import 'src/user/register_screen.dart';
import 'src/user/supabase_auth_provider.dart';
import 'src/user/user_manager.dart';
import 'src/debug/database_debug_screen.dart';
import 'src/user/user_progress_manager.dart';

Future<void> main() async {
  // 初始化Flutter绑定
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化日志记录
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print(
          '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    }
  });

  // 初始化Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 传递未捕获的错误到Firebase Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    // Firebase初始化失败时的处理
    if (kDebugMode) {
      print('Firebase initialization failed: $e');
    }
  }

  // 初始化Supabase
  try {
    await supabase.Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  } catch (e) {
    if (kDebugMode) {
      print('Supabase initialization failed: $e');
    }
  }

  // Set up analytics.
  FirebaseAnalytics? analytics;
  if (!kIsWeb) {
    analytics = FirebaseAnalytics.instance;
  }

  // 运行应用
  runApp(
    MyApp(
      analytics: analytics,
    ),
  );
}

class MyApp extends StatelessWidget {
  final FirebaseAnalytics? analytics;

  const MyApp({
    this.analytics,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            // 音频控制器
            Provider<AudioController>(
              create: (context) => AudioController()..initialize(),
            ),

            // Supabase客户端
            Provider<supabase.SupabaseClient>(
              create: (context) => supabase.Supabase.instance.client,
            ),

            // 用户管理器
            ChangeNotifierProvider<UserManager>(
              create: (context) {
                final userManager = UserManager();
                // 初始化Supabase认证提供商
                final supabaseClient = context.read<supabase.SupabaseClient>();
                final authProvider =
                    SupabaseAuthProvider(supabaseClient: supabaseClient);
                userManager.initAuthProvider(authProvider);
                return userManager;
              },
            ),

            // 设置控制器
            ChangeNotifierProxyProvider<UserManager, SettingsController>(
              create: (context) => SettingsController(
                persistence: LocalStorageSettingsPersistence(),
              ),
              update: (context, userManager, previousSettingsController) {
                if (userManager.isSignedIn && userManager.currentUser != null) {
                  // 用户已登录，使用Supabase持久化
                  final supabaseClient =
                      context.read<supabase.SupabaseClient>();
                  return SettingsController(
                    persistence: SupabaseSettingsPersistence(
                      supabaseClient: supabaseClient,
                      userId: userManager.currentUser!.id,
                    ),
                  );
                } else {
                  // 用户未登录，使用本地存储
                  return SettingsController(
                    persistence: LocalStorageSettingsPersistence(),
                  );
                }
              },
            ),

            // 排行榜管理器
            Provider<RankingManager>(
              create: (context) {
                final supabaseClient = context.read<supabase.SupabaseClient>();
                return RankingManager(supabaseClient: supabaseClient);
              },
            ),

            // 用户进度管理器
            Provider<UserProgressManager>(
              create: (context) {
                final supabaseClient = context.read<supabase.SupabaseClient>();
                return UserProgressManager(supabaseClient: supabaseClient);
              },
            ),

            // 调色板（依赖于设置控制器）
            ChangeNotifierProxyProvider<SettingsController, Palette>(
              create: (context) =>
                  Palette(context.read<SettingsController>().theme.value),
              update: (context, settings, previousPalette) {
                final palette = Palette(settings.theme.value);
                return palette;
              },
            ),
          ],
          child: Consumer3<Palette, UserManager, SettingsController>(
            builder: (context, palette, userManager, settings, child) {
              return AppLifecycleObserver(
                child: MaterialApp.router(
                  title: 'Puzzle Game',
                  theme: ThemeData(
                    useMaterial3: true,
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: palette.darkPen,
                      brightness: settings.theme.value == AppTheme.dark
                          ? Brightness.dark
                          : Brightness.light,
                    ),
                    scaffoldBackgroundColor: palette.backgroundMain,
                    textTheme: TextTheme(
                      bodyMedium: TextStyle(color: palette.textColor),
                    ),
                    elevatedButtonTheme: ElevatedButtonThemeData(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.primaryColor,
                        foregroundColor: settings.theme.value == AppTheme.dark
                            ? const Color(0xFF212121)
                            : const Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                  routerConfig: _router,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

final GoRouter _router = GoRouter(
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
            return const LoadingSelectionScreen(level: 1);
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'level',
              builder: (BuildContext context, GoRouterState state) {
                return const LevelSelectionScreen();
              },
            ),
            GoRoute(
              path: 'level/:jigsawId',
              builder: (BuildContext context, GoRouterState state) {
                final jigsawIdParam = state.pathParameters['jigsawId']!;
                final jigsawId = int.tryParse(jigsawIdParam) ?? 1;
                return PlaySessionScreen(jigsawId: jigsawId);
              },
            ),
          ],
        ),
        GoRoute(
          path: 'settings',
          builder: (BuildContext context, GoRouterState state) {
            return const SettingsScreen();
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'about',
              builder: (BuildContext context, GoRouterState state) {
                return const AboutScreen();
              },
            ),
          ],
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
        GoRoute(
          path: 'debug/database',
          builder: (BuildContext context, GoRouterState state) {
            return const DatabaseDebugScreen();
          },
        ),
      ],
    ),
  ],
);
