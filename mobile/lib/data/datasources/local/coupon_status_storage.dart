import 'package:shared_preferences/shared_preferences.dart';

/// 쿠폰 확인 상태를 로컬에 저장하는 데이터 소스
class CouponStatusStorage {
  static const String _keyPrefix = 'checked_coupon_';

  final SharedPreferences _prefs;

  CouponStatusStorage(this._prefs);

  /// 쿠폰을 확인됨으로 표시
  Future<void> markAsChecked(int feedId) async {
    await _prefs.setBool('$_keyPrefix$feedId', true);
  }

  /// 쿠폰이 확인되었는지 확인
  bool isChecked(int feedId) {
    return _prefs.getBool('$_keyPrefix$feedId') ?? false;
  }

  /// 모든 확인된 쿠폰 ID 목록 가져오기
  Future<List<int>> getAllCheckedIds() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
    final checkedIds = <int>[];

    for (final key in keys) {
      if (_prefs.getBool(key) == true) {
        // 'checked_coupon_12345' -> '12345'
        final feedIdStr = key.substring(_keyPrefix.length);
        final feedId = int.tryParse(feedIdStr);
        if (feedId != null) {
          checkedIds.add(feedId);
        }
      }
    }

    return checkedIds;
  }

  /// 모든 확인 상태 초기화 (선택적)
  Future<void> clearAllChecked() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
