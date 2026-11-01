import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginServices {
  static Future<void> setAdminLoggedIn({required bool value}) async {
    final preference = await SharedPreferences.getInstance();
    await preference.setBool('login', value);
    log('set login $value');
  }

  static Future<bool> getAdminLoggedIn() async {
    final preference = await SharedPreferences.getInstance();
    final resp = preference.getBool('login') ?? false;
    log('get login $resp');
    return resp;
  }

  static Future<void> logout() async {
    await setAdminLoggedIn(value: false);
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      log('Error during sign out: $e');
    }
  }
}
