import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gifting_admin/core/theme/app_colors.dart';
import 'package:gifting_admin/core/theme/app_theme.dart';
import 'package:gifting_admin/core/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    Get.reset();
  });

  group('ThemeController and AppColors Dark Mode Tests', () {
    test('Default mode is light and colors match light palette', () {
      final controller = ThemeController();
      Get.put(controller);

      expect(controller.isDarkMode, isFalse);
      expect(controller.themeMode, ThemeMode.light);

      expect(AppColors.background, AppColors.lightBackground);
      expect(AppColors.surface, AppColors.lightSurface);
      expect(AppColors.primary, AppColors.lightPrimary);
      expect(AppColors.border, AppColors.lightBorder);
      expect(AppColors.text, AppColors.lightText);
    });

    test('Toggling theme switches to dark mode and updates colors', () async {
      final controller = ThemeController();
      Get.put(controller);

      await controller.toggleTheme();

      expect(controller.isDarkMode, isTrue);
      expect(controller.themeMode, ThemeMode.dark);

      expect(AppColors.background, AppColors.darkBackground);
      expect(AppColors.surface, AppColors.darkSurface);
      expect(AppColors.primary, AppColors.darkPrimary);
      expect(AppColors.border, AppColors.darkBorder);
      expect(AppColors.text, AppColors.darkText);

      // Toggle back to light
      await controller.toggleTheme();
      expect(controller.isDarkMode, isFalse);
      expect(AppColors.background, AppColors.lightBackground);
    });

    test('setDarkMode explicitly sets dark mode', () async {
      final controller = ThemeController();
      Get.put(controller);

      await controller.setDarkMode(true);
      expect(controller.isDarkMode, isTrue);
      expect(controller.themeMode, ThemeMode.dark);

      await controller.setDarkMode(false);
      expect(controller.isDarkMode, isFalse);
      expect(controller.themeMode, ThemeMode.light);
    });

    test('Themes contain correct brightness and color schemes', () {
      final light = AppTheme.lightTheme;
      final dark = AppTheme.darkTheme;

      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);

      expect(light.colorScheme.brightness, Brightness.light);
      expect(dark.colorScheme.brightness, Brightness.dark);

      expect(light.scaffoldBackgroundColor, AppColors.lightBackground);
      expect(dark.scaffoldBackgroundColor, AppColors.darkBackground);
    });
  });
}
