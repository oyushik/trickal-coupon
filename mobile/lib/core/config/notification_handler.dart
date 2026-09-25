import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../presentation/providers/uid_provider.dart';

/// FCM 알림 핸들러
///
/// Foreground, Background, Terminated 상태에서의 알림 처리
class NotificationHandler {
  final WidgetRef ref;
  final GoRouter router;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  NotificationHandler({
    required this.ref,
    required this.router,
  });

  /// 알림 핸들러 초기화
  void initialize() {
    // 로컬 알림 초기화
    _initializeLocalNotifications();

    // Foreground 메시지 처리 (앱이 실행 중일 때)
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background/Terminated 상태에서 알림 클릭 처리
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);

    // 앱이 종료된 상태에서 알림을 클릭하여 앱을 열었을 때
    _checkInitialMessage();
  }

  /// 로컬 알림 초기화
  void _initializeLocalNotifications() {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);

    _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // 알림 클릭 시 처리
        if (response.payload != null) {
          final couponCode = response.payload!;
          _navigateToWebview(couponCode: couponCode);
        }
      },
    );
  }

  /// Foreground 메시지 처리
  void _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('📩 Foreground 메시지 수신: ${message.messageId}');
      print('   제목: ${message.notification?.title}');
      print('   내용: ${message.notification?.body}');
      print('   데이터: ${message.data}');
    }

    // 쿠폰 알림인 경우
    if (message.data['type'] == 'coupon_notification') {
      final couponCode = message.data['coupon_code'];
      final title = message.notification?.title ?? '🎁 새로운 쿠폰이 등록되었습니다!';
      final body = message.notification?.body ?? '쿠폰 코드: $couponCode';

      if (kDebugMode) {
        print('🎁 쿠폰 알림: $couponCode');
      }

      // Foreground에서 로컬 알림 표시
      await _showLocalNotification(
        title: title,
        body: body,
        payload: couponCode,
      );
    }
  }

  /// 로컬 알림 표시
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'coupon_notification_channel',
      '쿠폰 알림',
      channelDescription: '새로운 쿠폰이 등록되면 알려드립니다',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      0, // notification id
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    if (kDebugMode) {
      print('✅ Foreground 알림 표시 완료');
    }
  }

  /// 알림 클릭 처리 (Background/Foreground)
  void _handleNotificationClick(RemoteMessage message) {
    if (kDebugMode) {
      print('🔔 알림 클릭됨: ${message.messageId}');
      print('   데이터: ${message.data}');
    }

    // 쿠폰 알림인 경우 웹뷰로 이동
    if (message.data['type'] == 'coupon_notification') {
      final couponCode = message.data['coupon_code'];
      final feedIdStr = message.data['feed_id'];
      final feedId = feedIdStr != null ? int.tryParse(feedIdStr.toString()) : null;

      if (couponCode != null && couponCode.isNotEmpty) {
        _navigateToWebview(couponCode: couponCode, feedId: feedId);
      }
    }
  }

  /// 앱 시작 시 알림 확인 (Terminated 상태)
  Future<void> _checkInitialMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      if (kDebugMode) {
        print('🚀 앱이 알림으로 시작됨: ${initialMessage.messageId}');
        print('   데이터: ${initialMessage.data}');
      }

      // 쿠폰 알림인 경우 웹뷰로 이동
      if (initialMessage.data['type'] == 'coupon_notification') {
        final couponCode = initialMessage.data['coupon_code'];
        final feedIdStr = initialMessage.data['feed_id'];
        final feedId = feedIdStr != null ? int.tryParse(feedIdStr.toString()) : null;

        if (couponCode != null && couponCode.isNotEmpty) {
          // 약간의 지연을 주어 앱이 완전히 초기화되도록 함
          await Future.delayed(const Duration(milliseconds: 500));
          _navigateToWebview(couponCode: couponCode, feedId: feedId);
        }
      }
    }
  }

  /// 웹뷰로 이동
  void _navigateToWebview({required String couponCode, int? feedId}) async {
    try {
      // UID 가져오기
      final uidState = ref.read(uidStateProvider);
      final uid = uidState.value;

      if (kDebugMode) {
        print('🔑 UID 확인: $uid');
        print('🎫 Feed ID: $feedId');
      }

      // URL 파라미터 구성
      final params = <String, String>{
        'couponCode': couponCode,
        if (uid != null && uid.isNotEmpty) 'uid': uid,
        if (feedId != null) 'feedId': feedId.toString(),
      };

      final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
      router.push('/webview?$queryString');

      if (kDebugMode) {
        print('🌐 웹뷰로 이동: $queryString');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 웹뷰 이동 실패: $e');
      }
    }
  }
}

/// NotificationHandler Provider
final notificationHandlerProvider = Provider<NotificationHandler?>((ref) {
  // router가 생성되기 전에는 null 반환
  return null;
});
