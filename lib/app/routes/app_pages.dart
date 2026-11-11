import 'package:get/get.dart';
import 'package:gifting_admin/app/routes/app_routes.dart';
import 'package:gifting_admin/features/authentication/controllers/login_controller.dart';
import 'package:gifting_admin/features/authentication/views/login_screen.dart';
import 'package:gifting_admin/features/catalogues/controllers/catalogues_controller.dart';
import 'package:gifting_admin/features/dashboard/views/dashboard_screen.dart';
import 'package:gifting_admin/features/enquiry/controllers/enquiry_controller.dart';
import 'package:gifting_admin/features/enquiry/views/enquires_screen.dart';
import 'package:gifting_admin/features/enquiry/views/enquiry_details_screen.dart';
import 'package:gifting_admin/main.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splashScreen,
      page: () => const SplashScreen(),
    ),

    GetPage(
      name: AppRoutes.adminLogin,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        if (Get.isRegistered<LoginController>()) {
          Get.delete<LoginController>(force: true);
        }
        Get.lazyPut<LoginController>(() => LoginController());
      }),
    ),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const DashboardScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EnquiryController>(() => EnquiryController());
        Get.lazyPut<CatalogueController>(() => CatalogueController());
      }),
    ),
    GetPage(
      name: AppRoutes.enquiry,
      page: () => const EnquiresScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EnquiryController>(() => EnquiryController());
      }),
    ),
    GetPage(
      name: '/enquiries',
      page: () => const DashboardScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EnquiryController>(() => EnquiryController());
        Get.lazyPut<CatalogueController>(() => CatalogueController());
      }),
    ),
    GetPage(
      name: AppRoutes.enquiryDetails,
      page: () => EnquiryDetailsScreen(enquiry: Get.arguments),
      binding: BindingsBuilder(() {
        Get.lazyPut<EnquiryController>(() => EnquiryController());
      }),
    ),
  ];
}
