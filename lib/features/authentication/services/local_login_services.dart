import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class LocalLoginServices {
  static Future<void> setAdminLoggedIn({required bool value}) async {
    try {
      final preference = await SharedPreferences.getInstance();
      await preference.setBool('login', value);
      log('set login $value');
    } catch (e, stackTree) {
      log('Error $e, $stackTree');
      rethrow;
    }
  }

  static Future<bool> getAdminLoggedIn() async {
    try {
      final preference = await SharedPreferences.getInstance();
      final resp = preference.getBool('login') ?? false;
      log('get login $resp');
      return resp;
    } catch (e, stackTree) {
      log('Error $e, $stackTree');
      rethrow;
    }
  }
}
