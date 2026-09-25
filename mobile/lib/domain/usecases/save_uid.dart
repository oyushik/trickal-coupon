import '../repositories/user_repository.dart';

/// UID를 저장하는 Use Case
class SaveUid {
  final UserRepository _userRepository;

  SaveUid(this._userRepository);

  /// UID 저장 (로컬만) 및 FCM 토큰 등록 (Firebase)
  ///
  /// [uid]: 저장할 사용자 UID
  ///
  /// Throws:
  /// - [InvalidUidException]: UID가 유효하지 않은 경우
  /// - [Exception]: 저장 실패 시
  Future<void> call(String uid) async {
    // UID 유효성 검증
    if (!_isValidUid(uid)) {
      throw InvalidUidException('유효하지 않은 UID입니다. UID는 숫자로만 구성되어야 합니다.');
    }

    // 1. UID 로컬 저장
    await _userRepository.saveUid(uid);

    // 2. FCM 토큰 등록 (Firebase, UID 제외)
    await _userRepository.registerFcmToken();
  }

  /// UID 유효성 검증
  ///
  /// UID는 숫자로만 구성되어 있어야 하며, 최대 10자리까지 입력 가능
  bool _isValidUid(String uid) {
    if (uid.isEmpty) return false;

    // 숫자로만 구성되었는지 확인
    if (!RegExp(r'^\d+$').hasMatch(uid)) return false;

    // 최대 10자리까지 허용
    if (uid.length > 10) return false;

    return true;
  }
}

/// UID 유효성 검증 실패 예외
class InvalidUidException implements Exception {
  final String message;

  InvalidUidException(this.message);

  @override
  String toString() => message;
}
