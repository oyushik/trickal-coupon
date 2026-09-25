import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/pages/uid_setup_page.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/webview_page.dart';
import '../../presentation/pages/settings_page.dart';
import '../../presentation/pages/disclaimer_page.dart';

/// 앱 라우팅 설정
///
/// 라우트 경로:
/// - `/` : 스플래시 화면 (UID 확인 후 자동 라우팅)
/// - `/uid_setup` : UID 등록 화면
/// - `/home` : 메인 홈 화면
/// - `/settings` : 설정 화면
/// - `/webview` : 쿠폰 입력 웹뷰 화면
/// - `/disclaimer` : 면책 조항 화면
class AppRouter {
  static const String splash = '/';
  static const String uidSetup = '/uid_setup';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String webview = '/webview';
  static const String disclaimer = '/disclaimer';

  /// GoRouter 인스턴스 생성
  ///
  /// [hasUid]: UID 존재 여부 (초기 라우팅 결정)
  static GoRouter createRouter({required bool hasUid}) {
    return GoRouter(
      initialLocation: hasUid ? home : uidSetup,
      routes: [
        // Splash Screen (사용하지 않을 수도 있음)
        GoRoute(
          path: splash,
          builder: (context, state) => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),

        // UID 등록 화면
        GoRoute(
          path: uidSetup,
          name: 'uidSetup',
          builder: (context, state) => const UidSetupPage(),
        ),

        // 홈 화면
        GoRoute(
          path: home,
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),

        // 설정 화면
        GoRoute(
          path: settings,
          name: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),

        // 웹뷰 화면
        GoRoute(
          path: webview,
          name: 'webview',
          builder: (context, state) {
            // 쿼리 파라미터에서 UID, 쿠폰 코드, Feed ID 추출
            final uid = state.uri.queryParameters['uid'];
            final couponCode = state.uri.queryParameters['couponCode'];
            final feedIdStr = state.uri.queryParameters['feedId'];
            final feedId = feedIdStr != null ? int.tryParse(feedIdStr) : null;

            return WebViewPage(
              uid: uid,
              couponCode: couponCode,
              feedId: feedId,
            );
          },
        ),

        // 면책 조항 화면
        GoRoute(
          path: disclaimer,
          name: 'disclaimer',
          builder: (context, state) => const DisclaimerPage(),
        ),
      ],

      // 에러 화면
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('오류')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                '페이지를 찾을 수 없습니다',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                state.uri.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Private constructor to prevent instantiation
  AppRouter._();
}
