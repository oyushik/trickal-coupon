import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/uid_storage.dart';
import '../datasources/remote/firebase_datasource.dart';
import '../datasources/remote/fcm_datasource.dart';
import '../models/user_model.dart';

/// UserRepository 구현체 (UID는 로컬만, FCM 토큰만 Firebase 저장)
class UserRepositoryImpl implements UserRepository {
  final UidStorage _uidStorage;
  final FirebaseDatasource _firebaseDatasource;
  final FcmDatasource _fcmDatasource;

  // 현재 사용자 ID 캐시 (FCM 토큰 해시값)
  String? _currentUserId;

  UserRepositoryImpl({
    required UidStorage uidStorage,
    required FirebaseDatasource firebaseDatasource,
    required FcmDatasource fcmDatasource,
  })  : _uidStorage = uidStorage,
        _firebaseDatasource = firebaseDatasource,
        _fcmDatasource = fcmDatasource;

  // ========== UID 관리 (로컬 전용) ==========

  @override
  Future<void> saveUid(String uid) async {
    // 로컬에만 저장
    await _uidStorage.saveUid(uid);
  }

  /// UID 등록 + FCM 토큰 등록을 하나의 트랜잭션으로 처리
  ///
  /// 실패 시 모든 변경사항 롤백
  Future<void> setupUserWithNotification(String uid) async {
    if (kDebugMode) {
      print('🚀 사용자 설정 시작: UID=$uid');
    }

    String? fcmToken;
    String? userId;
    bool uidSaved = false;

    try {
      // 1단계: FCM 토큰 발급
      if (kDebugMode) {
        print('[1/3] FCM 토큰 발급 중...');
      }
      fcmToken = await _fcmDatasource.getToken();
      if (fcmToken == null) {
        throw Exception('푸시 알림 설정에 실패했습니다. 알림 권한을 확인해주세요.');
      }
      if (kDebugMode) {
        print('✅ FCM 토큰 획득: ${fcmToken.substring(0, 20)}...');
      }

      // 2단계: UID 로컬 저장
      if (kDebugMode) {
        print('[2/3] UID 저장 중...');
      }
      await _uidStorage.saveUid(uid);
      uidSaved = true;
      if (kDebugMode) {
        print('✅ UID 저장 완료');
      }

      // 3단계: Firestore에 FCM 토큰 등록
      if (kDebugMode) {
        print('[3/3] 푸시 알림 등록 중...');
      }
      userId = fcmToken.hashCode.toString();
      _currentUserId = userId;

      final user = UserModel(
        id: userId,
        fcmToken: fcmToken,
        createdAt: DateTime.now(),
      );

      await _firebaseDatasource.saveUser(user);
      if (kDebugMode) {
        print('✅ 푸시 알림 등록 완료!');
      }

      if (kDebugMode) {
        print('🎉 사용자 설정 완료!');
      }
    } catch (e) {
      // 롤백: UID가 저장되었다면 삭제
      if (uidSaved) {
        if (kDebugMode) {
          print('⏪ 롤백: UID 삭제 중...');
        }
        try {
          await _uidStorage.deleteUid();
        } catch (rollbackError) {
          if (kDebugMode) {
            print('❌ 롤백 실패: $rollbackError');
          }
        }
      }

      if (kDebugMode) {
        print('❌ 사용자 설정 실패: $e');
      }
      rethrow;
    }
  }

  @override
  Future<String?> getUid() async {
    return await _uidStorage.getUid();
  }

  @override
  Future<void> deleteUid() async {
    await _uidStorage.deleteUid();
  }

  @override
  Future<bool> hasUid() async {
    return await _uidStorage.hasUid();
  }

  // ========== FCM 토큰 관리 ==========

  @override
  Future<void> registerFcmToken() async {
    if (kDebugMode) {
      print('📱 FCM 토큰 등록 시작...');
    }

    // 1. FCM 토큰 가져오기
    final fcmToken = await _fcmDatasource.getToken();
    if (fcmToken == null) {
      if (kDebugMode) {
        print('❌ FCM 토큰을 가져올 수 없습니다');
      }
      throw Exception('FCM 토큰을 가져올 수 없습니다');
    }

    if (kDebugMode) {
      print('✅ FCM 토큰 획득: ${fcmToken.substring(0, 20)}...');
    }

    // 2. 사용자 ID 생성 (FCM 토큰 해시)
    final userId = fcmToken.hashCode.toString();
    _currentUserId = userId;

    if (kDebugMode) {
      print('🔑 사용자 ID 생성: $userId');
    }

    // 3. Firestore에 FCM 토큰만 저장 (UID 제외)
    final user = UserModel(
      id: userId,
      fcmToken: fcmToken,
      createdAt: DateTime.now(),
    );

    if (kDebugMode) {
      print('💾 Firestore에 FCM 토큰 저장 중...');
    }

    await _firebaseDatasource.saveUser(user);

    if (kDebugMode) {
      print('✅ FCM 토큰 등록 완료!');
    }
  }

  @override
  Future<String?> getFcmToken() async {
    return await _fcmDatasource.getToken();
  }

  @override
  Future<void> updateFcmToken(String newToken) async {
    final userId = await _getUserId();
    if (userId != null) {
      await _firebaseDatasource.updateFcmToken(userId, newToken);
    }
  }

  // ========== 알림 권한 ==========

  @override
  Future<bool> requestNotificationPermission() async {
    final status = await _fcmDatasource.requestPermission();
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  @override
  Future<bool> isNotificationPermissionGranted() async {
    return await _fcmDatasource.isPermissionGranted();
  }

  // ========== 내부 헬퍼 메서드 ==========

  /// 사용자 ID 가져오기 (FCM 토큰 기반)
  Future<String?> _getUserId() async {
    // 캐시된 ID가 있으면 반환
    if (_currentUserId != null) return _currentUserId;

    // FCM 토큰으로 ID 생성
    final fcmToken = await _fcmDatasource.getToken();
    if (fcmToken == null) return null;

    _currentUserId = fcmToken.hashCode.toString();
    return _currentUserId;
  }
}
