import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 테마 모드를 관리하는 Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// 테마 모드 StateNotifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  /// 테마 모드 설정
  void setThemeMode(ThemeMode mode) {
    state = mode;
    // TODO: PreferencesStorage에 저장
  }

  /// 라이트 모드로 전환
  void setLightMode() => setThemeMode(ThemeMode.light);

  /// 다크 모드로 전환
  void setDarkMode() => setThemeMode(ThemeMode.dark);

  /// 시스템 모드로 전환
  void setSystemMode() => setThemeMode(ThemeMode.system);

  /// 테마 토글 (라이트 ↔ 다크)
  void toggleTheme() {
    if (state == ThemeMode.light) {
      setDarkMode();
    } else {
      setLightMode();
    }
  }
}
