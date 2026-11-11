import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting_admin/app/routes/app_routes.dart';
import 'package:gifting_admin/core/theme/app_colors.dart';
import 'package:gifting_admin/features/authentication/controllers/login_controller.dart';
import 'package:gifting_admin/features/authentication/services/login_services.dart';
import 'package:gifting_admin/features/catalogues/controllers/catalogues_controller.dart';
import 'package:gifting_admin/features/enquiry/controllers/enquiry_controller.dart';

Future<dynamic> openDialogBox() {
  return Get.generalDialog(
    pageBuilder: (context, animation, secondaryAnimation) {
      return SimpleDialog(
        title: const Text(
          'Are you sure you want to sign out?',
          textAlign: TextAlign.center,
        ),
        titlePadding: const EdgeInsetsGeometry.fromLTRB(24, 24, 24, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(16),
        ),
        alignment: Alignment.center,
        children: [
          Row(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    AppColors.secondaryText,
                  ),
                ),
                onPressed: () {
                  Get.back();
                },
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Get.back();
                  await LoginServices().logout();
                  if (Get.isRegistered<LoginController>()) {
                    Get.delete<LoginController>(force: true);
                  }
                  if (Get.isRegistered<EnquiryController>()) {
                    Get.delete<EnquiryController>(force: true);
                  }
                  if (Get.isRegistered<CatalogueController>()) {
                    Get.delete<CatalogueController>(force: true);
                  }
                  Get.offAllNamed(AppRoutes.adminLogin);
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        ],
      );
    },
  );
}
