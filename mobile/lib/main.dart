import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'core/config/router.dart';
import 'core/config/fcm_config.dart';
import 'core/config/notification_handler.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/uid_provider.dart';
import 'presentation/providers/providers.dart';

void main() async {
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // SharedPreferences 초기화
  final prefs = await SharedPreferences.getInstance();

  // FCM 초기화
  await FcmConfig.initialize();

  // 앱 실행
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final Future<bool> _initFuture;
  NotificationHandler? _notificationHandler;
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    _initFuture = _checkUid();
  }

  /// UID 존재 여부 확인
  Future<bool> _checkUid() async {
    try {
      await ref.read(uidStateProvider.notifier).loadUid();
      final uidState = ref.read(uidStateProvider);
      return uidState.value != null && uidState.value!.isNotEmpty;
    } catch (e) {
      debugPrint('UID 확인 오류: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return FutureBuilder<bool>(
      future: _initFuture,
      builder: (context, snapshot) {
        // 로딩 중
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // UID 존재 여부에 따라 초기 라우트 결정
        final hasUid = snapshot.data ?? false;

        // Router 캐시 (한 번만 생성)
        _router ??= AppRouter.createRouter(hasUid: hasUid);

        // NotificationHandler 초기화 (한 번만)
        if (_notificationHandler == null) {
          _notificationHandler = NotificationHandler(
            ref: ref,
            router: _router!,
          );
          _notificationHandler!.initialize();
        }

        return MaterialApp.router(
          title: '쿠폰스탕스',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: _router!,
        );
      },
    );
  }
}
