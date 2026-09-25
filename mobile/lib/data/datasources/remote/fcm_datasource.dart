import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;

/// FCM(Firebase Cloud Messaging) 관련 원격 데이터 소스
class FcmDatasource {
  final FirebaseMessaging _messaging;

  FcmDatasource({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  // ========== FCM 토큰 관리 ==========

  /// FCM 토큰 가져오기
  Future<String?> getToken() async {
    try {
      // iOS는 APNs 토큰이 필요하므로 권한 요청 후 토큰 가져오기
      if (Platform.isIOS) {
        await requestPermission();
      }

      final token = await _messaging.getToken();
      return token;
    } catch (e) {
      throw FcmException('FCM 토큰 가져오기 실패: $e');
    }
  }

  /// FCM 토큰 갱신 스트림
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// 토큰 삭제 (로그아웃 시)
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
    } catch (e) {
      throw FcmException('FCM 토큰 삭제 실패: $e');
    }
  }

  // ========== 알림 권한 ==========

  /// 알림 권한 요청 (iOS 필수, Android 13+ 필요)
  Future<AuthorizationStatus> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
  }) async {
    try {
      final settings = await _messaging.requestPermission(
        alert: alert,
        announcement: announcement,
        badge: badge,
        carPlay: carPlay,
        criticalAlert: criticalAlert,
        provisional: provisional,
        sound: sound,
      );

      return settings.authorizationStatus;
    } catch (e) {
      throw FcmException('알림 권한 요청 실패: $e');
    }
  }

  /// 현재 알림 설정 확인
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      return await _messaging.getNotificationSettings();
    } catch (e) {
      throw FcmException('알림 설정 확인 실패: $e');
    }
  }

  /// 알림 권한이 허용되었는지 확인
  Future<bool> isPermissionGranted() async {
    try {
      final settings = await getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      return false;
    }
  }

  // ========== 메시지 처리 ==========

  /// Foreground 메시지 스트림
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  /// Background/Terminated 상태에서 알림 클릭 시
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  /// 앱이 Terminated 상태에서 알림으로 실행되었는지 확인
  Future<RemoteMessage?> getInitialMessage() async {
    try {
      return await _messaging.getInitialMessage();
    } catch (e) {
      throw FcmException('초기 메시지 가져오기 실패: $e');
    }
  }

  // ========== 토픽 구독 (선택사항) ==========

  /// 특정 토픽 구독 (예: 'all_users')
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      throw FcmException('토픽 구독 실패: $e');
    }
  }

  /// 토픽 구독 해제
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      throw FcmException('토픽 구독 해제 실패: $e');
    }
  }

  // ========== APNs 설정 (iOS) ==========

  /// APNs 토큰 가져오기 (iOS 전용)
  Future<String?> getAPNSToken() async {
    try {
      if (!Platform.isIOS) return null;
      return await _messaging.getAPNSToken();
    } catch (e) {
      throw FcmException('APNs 토큰 가져오기 실패: $e');
    }
  }
}

/// FCM 관련 예외
class FcmException implements Exception {
  final String message;

  FcmException(this.message);

  @override
  String toString() => 'FcmException: $message';
}
