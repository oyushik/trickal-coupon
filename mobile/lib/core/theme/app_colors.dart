import 'package:flutter/material.dart';

/// 앱 전역 색상 정의
class AppColors {
  // ========== Primary Colors ==========
  static const Color primaryLight = Color(0xFF5EA630); // Purple
  static const Color primaryDark = Color(0xFF5EA630);

  static const Color secondaryLight = Color(0xFF03DAC6); // Teal
  static const Color secondaryDark = Color(0xFF03DAC6);

  // ========== Background Colors ==========
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // ========== Text Colors ==========
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);

  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // ========== Semantic Colors ==========
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color error = Color(0xFFCF6679); // Red
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color info = Color(0xFF2196F3); // Blue

  // ========== Card/Container Colors ==========
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2C2C2C);

  // ========== Divider Colors ==========
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF3A3A3A);

  // Private constructor to prevent instantiation
  AppColors._();
}
