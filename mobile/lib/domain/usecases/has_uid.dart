import '../repositories/user_repository.dart';

/// UID 존재 여부를 확인하는 Use Case
class HasUid {
  final UserRepository _userRepository;

  HasUid(this._userRepository);

  /// UID가 저장되어 있는지 확인
  ///
  /// Returns: UID가 있으면 true, 없으면 false
  Future<bool> call() async {
    return await _userRepository.hasUid();
  }
}
