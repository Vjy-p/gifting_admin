import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find<ThemeController>();

  static const String _themePrefKey = 'app_theme_is_dark';

  final RxBool _isDarkMode = false.obs;

  bool get isDarkMode => _isDarkMode.value;

  ThemeMode get themeMode =>
      _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themePrefKey) ?? false;
      _isDarkMode.value = isDark;
      Get.changeThemeMode(themeMode);
    } catch (e) {
      log('Error load theme preference $e');
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeThemeMode(themeMode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePrefKey, _isDarkMode.value);
    } catch (_) {}
  }

  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode.value != isDark) {
      _isDarkMode.value = isDark;
      Get.changeThemeMode(themeMode);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_themePrefKey, isDark);
      } catch (_) {}
    }
  }
}
