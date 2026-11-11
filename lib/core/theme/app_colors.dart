import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting_admin/core/theme/theme_controller.dart';

class AppColors {
  AppColors._();

  static bool get _isDark {
    try {
      if (Get.isRegistered<ThemeController>()) {
        return ThemeController.to.isDarkMode;
      }
      return Get.isDarkMode;
    } catch (_) {
      return false;
    }
  }

  // Light Palette
  static const Color lightPrimary = Color(0xFF245C45);
  static const Color lightDarkGreen = Color(0xFF193F30);
  static const Color lightSage = Color(0xFFDDE9DF);
  static const Color lightBackground = Color(0xFFFAF9F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF252925);
  static const Color lightSecondaryText = Color(0xFF6B716B);
  static const Color lightTitleText = Color(0xFF404943);
  static const Color lightBlackText = Color(0xFF1B1C1A);
  static const Color lightBorder = Color(0xFFE5E7E2);

  // Dark Palette
  static const Color darkPrimary = Color(0xFF5BAA88);
  static const Color darkDarkGreen = Color(0xFF2A5944);
  static const Color darkSage = Color(0xFF23362A);
  static const Color darkBackground = Color(0xFF121613);
  static const Color darkSurface = Color(0xFF1B211D);
  static const Color darkText = Color(0xFFE4E9E4);
  static const Color darkSecondaryText = Color(0xFF9CA59C);
  static const Color darkTitleText = Color(0xFFD0D7D0);
  static const Color darkBlackText = Color(0xFFF0F4F0);
  static const Color darkBorder = Color(0xFF2C362F);

  // Dynamic Theme-Aware Colors
  static Color get primary => _isDark ? darkPrimary : lightPrimary;
  static Color get darkGreen => _isDark ? darkDarkGreen : lightDarkGreen;
  static Color get sage => _isDark ? darkSage : lightSage;
  static Color get background => _isDark ? darkBackground : lightBackground;
  static Color get surface => _isDark ? darkSurface : lightSurface;
  static Color get text => _isDark ? darkText : lightText;
  static Color get secondaryText =>
      _isDark ? darkSecondaryText : lightSecondaryText;
  static Color get titleText => _isDark ? darkTitleText : lightTitleText;
  static Color get blackText => _isDark ? darkBlackText : lightBlackText;
  static Color get border => _isDark ? darkBorder : lightBorder;
  static Color get gold =>
      _isDark ? const Color(0xFFD9B982) : const Color(0xFFC5A46D);

  // Constants
  static const Color white = Color(0xFFFFFFFF);
  static const Color red = Color(0xFFB42318);
}
