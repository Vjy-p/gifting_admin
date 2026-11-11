import 'dart:developer';

import 'package:get/get.dart';
import 'package:gifting_admin/core/widgets/custom_toast.dart';
import 'package:gifting_admin/features/authentication/services/login_services.dart';
import 'package:gifting_admin/features/notifications/services/push_notifications_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/routes/app_routes.dart';

class LoginController extends GetxController {
  final isLoading = false.obs;

  final loginServices = LoginServices();

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

  Future<void> login({required String email, required String password}) async {
    if (isLoading.value) return;

    if (email.trim().isEmpty || password.trim().isEmpty) {
      customToast(title: 'Required', text: 'Enter your email and password.');
      return;
    }

    try {
      isLoading.value = true;

      final response = await loginServices.login(
        email: email.trim(),
        password: password.trim(),
      );

      if (response == true) {
        Get.offAllNamed(AppRoutes.adminDashboard);
        final pushService = Get.put(
          PushNotificationsServices.instance,
          permanent: true,
        );
        await pushService.init();
      }
    } on AuthException catch (error, stackTree) {
      log('Error login $error, $stackTree ');
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
    try {
      if (Get.isRegistered<PushNotificationsServices>()) {
        try {
          await Get.find<PushNotificationsServices>().unregister();
        } catch (e) {
          log('Warning during push unregister on logout: $e');
        }
      }
      final resp = await loginServices.logout();
      if (resp) {
        Get.offAllNamed(AppRoutes.adminLogin);
      }
    } catch (e, stackTree) {
      log('Error sign out $e, $stackTree');
      customToast(
        title: 'Unable to sign out',
        text: 'Check your connection and try again',
      );
    }
  }
}
