import 'dart:developer';

import 'package:gifting_admin/core/widgets/custom_toast.dart';
import 'package:gifting_admin/features/authentication/services/local_login_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginServices {
  LoginServices({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<bool?> login({required String email, required String password}) async {
    try {
      final resp = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      log('resp login :  $resp');

      if (resp.user != null) {
        final role = await _client
            .from('user_roles')
            .select('role')
            .eq('user_id', resp.user!.id)
            .maybeSingle();
        log('access ${role?['role']}');
        if (role?['role'] == 'admin') {
          await LocalLoginServices.setAdminLoggedIn(value: true);
          return true;
        } else {
          await logout();
          customToast(
            title: 'Access denied',
            text: 'This account does not have admin access.',
          );
          return false;
        }
      } else {
        await logout();
        customToast(
          title: 'Access denied',
          text: 'This account does not have admin access.',
        );
        return false;
      }
    } catch (e) {
      // await logout();
      log('Error during login: $e');
      return null;
    }
  }

  Future<bool> logout() async {
    try {
      await _client.auth.signOut();
      await LocalLoginServices.setAdminLoggedIn(value: false);
      customToast(
        title: 'Sign out',
        text: 'Successfully signout from the admin dashboard.',
      );
      return true;
    } catch (e) {
      log('Error during sign out: $e');
      rethrow;
    }
  }
}
