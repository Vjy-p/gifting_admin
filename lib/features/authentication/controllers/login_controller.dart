import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting_admin/core/widgets/custom_toast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/routes/app_routes.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  FocusNode emailFocus = FocusNode();
  final passwordController = TextEditingController();
  FocusNode passwordFocus = FocusNode();

  final isLoading = false.obs;
  final obscurePassword = true.obs;

  final SupabaseClient _client = Supabase.instance.client;

  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[\w.!#$%&’*+/=?^_`{|}~-]+@[\w-]+(?:\.[\w-]+)+$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  Future<void> login() async {
    if (isLoading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      customToast(title: 'Required', text: 'Enter your email and password.');
      return;
    }

    try {
      isLoading.value = true;

      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      log("resp $response ");

      if (user == null) {
        throw Exception('Login failed.');
      }

      final role = await _client
          .from('user_roles')
          .select('role')
          .eq('user_id', user.id)
          .maybeSingle();

      if (role?['role'] != 'admin') {
        await _client.auth.signOut();
        customToast(
          title: 'Access denied',
          text: 'This account does not have admin access.',
        );
        return;
      }

      Get.offAllNamed(AppRoutes.adminDashboard);
    } on AuthException catch (error, stackTree) {
      log("Error login $error, $stackTree ");
      customToast(title: 'Login failed', text: error.message);
    } catch (_) {
      customToast(
        title: 'Unable to sign in',
        text: 'Check your connection and admin account configuration.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
    Get.offAllNamed(AppRoutes.adminLogin);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}
