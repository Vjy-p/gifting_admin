import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting_admin/app/routes/app_pages.dart';
import 'package:gifting_admin/app/routes/app_routes.dart';
import 'package:gifting_admin/core/constants/constants.dart';
import 'package:gifting_admin/core/theme/app_theme.dart';
import 'package:gifting_admin/core/theme/theme_controller.dart';
import 'package:gifting_admin/features/authentication/services/login_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ThemeController());
  await Supabase.initialize(
    url: Constants.supabaseUrl,
    publishableKey: Constants.supbasePublishableKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController.to;
    return Obx(
      () => GetMaterialApp(
        title: 'Gifting Admin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode,
        getPages: AppPages.pages,
        initialRoute: AppRoutes.splashScreen,
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.stylus,
            PointerDeviceKind.touch,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.unknown,
          },
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    initialise();
    super.initState();
  }

  Future<void> initialise() async {
    final bool isLoggedIn = await LoginServices.getAdminLoggedIn();
    if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.adminDashboard);
    } else {
      Get.offAllNamed(AppRoutes.adminLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
