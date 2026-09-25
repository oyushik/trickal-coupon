import 'package:shared_preferences/shared_preferences.dart';

/// 앱 설정을 로컬에 저장하는 데이터 소스
/// 민감하지 않은 정보(테마 설정 등)를 저장
class PreferencesStorage {
  static const String _themeKey = 'theme_mode';
  static const String _firstLaunchKey = 'is_first_launch';
  static const String _notificationEnabledKey = 'notification_enabled';

  final SharedPreferences _prefs;

  PreferencesStorage(this._prefs);

  /// SharedPreferences 인스턴스 생성
  static Future<PreferencesStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesStorage(prefs);
  }

  // ========== 테마 설정 ==========

  /// 테마 모드 저장 (light, dark, system)
  Future<bool> saveThemeMode(String themeMode) async {
    return await _prefs.setString(_themeKey, themeMode);
  }

  /// 테마 모드 조회
  String getThemeMode() {
    return _prefs.getString(_themeKey) ?? 'system';
  }

  // ========== 최초 실행 여부 ==========

  /// 최초 실행 여부 확인
  bool isFirstLaunch() {
    return _prefs.getBool(_firstLaunchKey) ?? true;
  }

  /// 최초 실행 완료 표시
  Future<bool> markFirstLaunchComplete() async {
    return await _prefs.setBool(_firstLaunchKey, false);
  }

  // ========== 알림 설정 ==========

  /// 알림 활성화 여부 저장
  Future<bool> setNotificationEnabled(bool enabled) async {
    return await _prefs.setBool(_notificationEnabledKey, enabled);
  }

  /// 알림 활성화 여부 조회
  bool isNotificationEnabled() {
    return _prefs.getBool(_notificationEnabledKey) ?? true;
  }

  // ========== 전체 초기화 ==========

  /// 모든 설정 초기화
  Future<bool> clearAll() async {
    return await _prefs.clear();
  }
}
