import 'package:get/get.dart';
import 'package:gifting_admin/app/routes/app_routes.dart';
import 'package:gifting_admin/features/authentication/controllers/login_controller.dart';
import 'package:gifting_admin/features/authentication/views/login_screen.dart';
import 'package:gifting_admin/features/dashboard/views/dashboard_screen.dart';
import 'package:gifting_admin/features/enquiry/controllers/enquiry_controller.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.adminLogin,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LoginController>(() => LoginController());
      }),
    ),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const DashboardScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EnquiryController>(() => EnquiryController());
      }),
    ),
  ];
}
