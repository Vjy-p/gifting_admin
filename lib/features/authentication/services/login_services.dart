import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class LoginServices {
  static Future<void> setAdminLoggedIn({required bool value}) async {
    final preference = await SharedPreferences.getInstance();
    preference.setBool('login', value);
    log('set login $value');
  }

  static Future<bool> getAdminLoggedIn() async {
    final preference = await SharedPreferences.getInstance();
    final resp = preference.getBool('login') ?? false;
    log('get login $resp');
    return resp;
  }
}
