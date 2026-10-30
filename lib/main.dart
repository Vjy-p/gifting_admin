import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting_admin/app/routes/app_pages.dart';
import 'package:gifting_admin/app/routes/app_routes.dart';
import 'package:gifting_admin/core/constants/constants.dart';
import 'package:gifting_admin/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    return GetMaterialApp(
      title: 'Gifting Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      getPages: AppPages.pages,
      initialRoute: AppRoutes.adminLogin,
    );
  }
}
