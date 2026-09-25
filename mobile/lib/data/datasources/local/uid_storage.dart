import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// UID를 암호화하여 로컬에 저장하는 데이터 소스
class UidStorage {
  static const String _uidKey = 'user_uid';

  final FlutterSecureStorage _secureStorage;

  UidStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  /// UID 저장
  ///
  /// Android: KeyStore를 사용한 AES 암호화
  /// iOS: Keychain을 사용한 암호화
  Future<void> saveUid(String uid) async {
    try {
      await _secureStorage.write(key: _uidKey, value: uid);
    } catch (e) {
      throw StorageException('UID 저장 실패: $e');
    }
  }

  /// UID 조회
  ///
  /// Returns: 저장된 UID, 없으면 null
  Future<String?> getUid() async {
    try {
      return await _secureStorage.read(key: _uidKey);
    } catch (e) {
      throw StorageException('UID 조회 실패: $e');
    }
  }

  /// UID 삭제
  Future<void> deleteUid() async {
    try {
      await _secureStorage.delete(key: _uidKey);
    } catch (e) {
      throw StorageException('UID 삭제 실패: $e');
    }
  }

  /// UID 존재 여부 확인
  Future<bool> hasUid() async {
    try {
      final uid = await getUid();
      return uid != null && uid.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 모든 저장된 데이터 삭제 (앱 초기화 시 사용)
  Future<void> deleteAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw StorageException('전체 데이터 삭제 실패: $e');
    }
  }
}

/// 저장소 관련 예외
class StorageException implements Exception {
  final String message;

  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}
