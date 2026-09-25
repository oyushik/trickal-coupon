import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// FCM 백그라운드 메시지 핸들러
///
/// 앱이 백그라운드 또는 종료 상태일 때 메시지를 처리
/// 이 함수는 main() 함수 외부의 최상위 레벨에서 정의되어야 함
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase 초기화 (백그라운드에서 필요)
  await Firebase.initializeApp();

  // 알림 채널 생성 (Terminated 상태에서도 알림을 표시하기 위해)
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'coupon_notification_channel',
    '쿠폰 알림',
    description: '새로운 쿠폰이 등록되면 알려드립니다',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  if (kDebugMode) {
    print('📩 백그라운드 메시지 수신: ${message.messageId}');
    print('📦 데이터: ${message.data}');
    if (message.notification != null) {
      print('🔔 알림: ${message.notification!.title} - ${message.notification!.body}');
    }
  }
}

/// FCM 설정 클래스
class FcmConfig {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// FCM 초기화 및 설정
  static Future<void> initialize() async {
    // 1. Android 알림 채널 생성
    await _createNotificationChannel();

    // 2. 알림 권한 요청 (iOS 필수, Android 13+ 필요)
    await _requestPermission();

    // 3. 백그라운드 메시지 핸들러 등록
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    if (kDebugMode) {
      print('✅ FCM 초기화 완료');
    }
  }

  /// Android 알림 채널 생성
  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'coupon_notification_channel', // AndroidManifest.xml과 동일한 ID
      '쿠폰 알림',
      description: '새로운 쿠폰이 등록되면 알려드립니다',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    if (kDebugMode) {
      print('✅ 알림 채널 생성 완료: ${channel.id}');
    }
  }

  /// 알림 권한 요청
  static Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('알림 권한 상태: ${settings.authorizationStatus}');
    }
  }

  /// FCM 토큰 가져오기
  static Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      if (kDebugMode) {
        print('📱 FCM 토큰: ${token?.substring(0, 20)}...');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('❌ FCM 토큰 가져오기 실패: $e');
      }
      return null;
    }
  }

  /// 토큰 갱신 리스너 등록
  static void onTokenRefresh(Function(String) onNewToken) {
    _messaging.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        print('🔄 FCM 토큰 갱신: ${newToken.substring(0, 20)}...');
      }
      onNewToken(newToken);
    });
  }
}
