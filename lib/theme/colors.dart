import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  // Light Theme Colors
  static const Color primaryLight = Color(0xFF2563EB);
  static const Color primaryDarkLight = Color(0xFF1E3A8A);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color textLightSecondary = Color(0xFF64748B);
  static const Color lostLight = Color(0xFF1E40AF);
  static const Color foundLight = Color(0xFF0EA5E9);
  static const Color resolvedLight = Color(0xFF94A3B8);

  // Dark Theme Colors
  static const Color primaryDarkVal = Color(0xFF3B82F6);
  static const Color primaryDarkDark = Color(0xFF1E293B);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color dividerDark = Color(0xFF334155);
  static const Color textDarkSecondary = Color(0xFF94A3B8);
  static const Color lostDark = Color(0xFF3B5BDB);
  static const Color foundDark = Color(0xFF38BDF8);
  static const Color resolvedDark = Color(0xFF64748B);

  // Common accessibility/utility colors
  static const Color error = Color(0xFFEF4444);
  static const Color darkSlate = Color(0xFF0F172A);
  static const Color lightGrey = Color(0xFFF1F5F9);
  static const Color dialogLight = Color(0xFFFFFFFF);
  static const Color dialogDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFF0F172A);
  static const Color textDark = Color(0xFFF8FAFC);
  static const Color inputFill = Color(0xFFF1F5F9);

  // Dynamic getters checking theme mode
  static bool get isDark => Get.isDarkMode;

  static Color get primary => isDark ? primaryDarkVal : primaryLight;
  static Color get primaryDark => isDark ? primaryDarkDark : primaryDarkLight;
  static Color get background => isDark ? backgroundDark : backgroundLight;
  static Color get surface => isDark ? surfaceDark : surfaceLight;
  static Color get divider => isDark ? dividerDark : dividerLight;
  static Color get secondaryText => isDark ? textDarkSecondary : textLightSecondary;
  static Color get lost => isDark ? lostDark : lostLight;
  static Color get found => isDark ? foundDark : foundLight;
  static Color get resolved => isDark ? resolvedDark : resolvedLight;
  static Color get text => isDark ? textDark : textLight;
  static Color get secondary => isDark ? primaryDarkVal : primaryLight;
  static Color get tertiary => isDark ? foundDark : foundLight;
  static Color get border => divider;
  static Color get dividerLightColor => dividerLight;
  static Color get dividerDarkColor => dividerDark;
}

