import '../repositories/user_repository.dart';

/// 저장된 UID를 조회하는 Use Case
class GetUid {
  final UserRepository _userRepository;

  GetUid(this._userRepository);

  /// 저장된 UID 조회
  ///
  /// Returns: 저장된 UID, 없으면 null
  Future<String?> call() async {
    return await _userRepository.getUid();
  }
}
