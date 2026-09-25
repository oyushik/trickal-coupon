import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';

/// UID 상태를 관리하는 Provider
final uidStateProvider = StateNotifierProvider<UidStateNotifier, AsyncValue<String?>>((ref) {
  final getUid = ref.watch(getUidProvider);
  final saveUid = ref.watch(saveUidProvider);
  final userRepository = ref.watch(userRepositoryProvider);

  return UidStateNotifier(
    getUid: getUid,
    saveUid: saveUid,
    userRepository: userRepository,
  );
});

/// UID 상태 관리 StateNotifier
class UidStateNotifier extends StateNotifier<AsyncValue<String?>> {
  final dynamic getUid;
  final dynamic saveUid;
  final dynamic userRepository;

  UidStateNotifier({
    required this.getUid,
    required this.saveUid,
    required this.userRepository,
  }) : super(const AsyncValue.loading()) {
    // 초기화 시 UID 로드
    loadUid();
  }

  /// UID 로드
  Future<void> loadUid() async {
    state = const AsyncValue.loading();
    try {
      final uid = await getUid.call();
      state = AsyncValue.data(uid);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// UID 저장
  Future<void> setUid(String uid) async {
    state = const AsyncValue.loading();
    try {
      print('🚀 UID 저장 시작: $uid');
      await saveUid.call(uid);
      print('✅ UID 저장 완료');
      state = AsyncValue.data(uid);
    } catch (e, stackTrace) {
      print('❌ UID 저장 실패: $e');
      print('스택 트레이스: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// UID가 있는지 확인
  bool get hasUid {
    return state.value != null && state.value!.isNotEmpty;
  }

  /// UID 삭제
  Future<void> clearUid() async {
    state = const AsyncValue.loading();
    try {
      await userRepository.deleteUid();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
