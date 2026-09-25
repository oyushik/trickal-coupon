import '../entities/user.dart';

/// 사용자 관련 비즈니스 로직을 담당하는 Repository 인터페이스
abstract class UserRepository {
  // ========== UID 관리 (로컬 전용) ==========

  /// UID 저장 (로컬 암호화 저장만)
  Future<void> saveUid(String uid);

  /// UID 조회 (로컬에서 조회)
  Future<String?> getUid();

  /// UID 삭제 (로컬에서만 삭제)
  Future<void> deleteUid();

  /// UID 존재 여부 확인
  Future<bool> hasUid();

  // ========== FCM 토큰 관리 ==========

  /// UID 등록 + FCM 토큰 등록을 하나의 트랜잭션으로 처리
  ///
  /// 실패 시 모든 변경사항 롤백
  Future<void> setupUserWithNotification(String uid);

  /// FCM 토큰 등록 (Firestore에 저장, UID 제외)
  Future<void> registerFcmToken();

  /// 현재 FCM 토큰 가져오기
  Future<String?> getFcmToken();

  /// FCM 토큰 갱신 시 Firestore 업데이트
  Future<void> updateFcmToken(String newToken);

  // ========== 알림 권한 ==========

  /// 알림 권한 요청
  Future<bool> requestNotificationPermission();

  /// 알림 권한 상태 확인
  Future<bool> isNotificationPermissionGranted();
}
