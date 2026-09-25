import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/coupon_status_storage.dart';
import 'providers.dart';

/// 쿠폰 확인 상태 관리 Provider
class CouponStatusNotifier extends StateNotifier<Set<int>> {
  final CouponStatusStorage _storage;

  CouponStatusNotifier(this._storage) : super({}) {
    _loadInitialState();
  }

  /// 초기 상태 로드
  Future<void> _loadInitialState() async {
    final checkedIds = await _storage.getAllCheckedIds();
    state = checkedIds.toSet();
  }

  /// 쿠폰이 확인되었는지 확인
  bool isChecked(int feedId) {
    return state.contains(feedId);
  }

  /// 쿠폰을 확인됨으로 표시
  Future<void> markAsChecked(int feedId) async {
    await _storage.markAsChecked(feedId);
    state = {...state, feedId};
  }
}

/// 쿠폰 상태 Provider
final couponStatusProvider =
    StateNotifierProvider<CouponStatusNotifier, Set<int>>((ref) {
  final storage = ref.watch(couponStatusStorageProvider);
  return CouponStatusNotifier(storage);
});
