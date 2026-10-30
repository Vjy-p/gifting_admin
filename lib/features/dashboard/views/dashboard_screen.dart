import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting_admin/core/theme/app_colors.dart';
import 'package:gifting_admin/features/authentication/controllers/login_controller.dart';
import 'package:gifting_admin/features/catalogues/views/catalogues_screen.dart';
import 'package:gifting_admin/features/enquiry/controllers/enquiry_controller.dart';

import '../../enquiry/views/enquires_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Widget> screens = [EnquiresScreen(), CataloguesScreen()];
  int selectedIndex = 0;

  @override
  void initState() {
    if (!Get.isRegistered<EnquiryController>()) {
      Get.lazyPut<EnquiryController>(() => EnquiryController());
    }
    super.initState();
  }

  void setScreenIndex(int value) {
    selectedIndex = value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Tribe Green Admin'),
      //   actions: [
      //     IconButton(
      //       tooltip: 'Refresh enquiries',
      //       onPressed: controller.loadEnquiries,
      //       icon: const Icon(Icons.refresh),
      //     ),
      //     IconButton(
      //       tooltip: 'Sign out',
      //       onPressed: () {
      //         Get.find<LoginController>().logout();
      //       },
      //       icon: const Icon(Icons.logout),
      //     ),
      //   ],
      // ),
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              backgroundColor: AppColors.background,
              trailingAtBottom: true,
              // extended: true,
              labelType: NavigationRailLabelType.all,
              selectedLabelTextStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
              unselectedLabelTextStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppColors.secondaryText,
              ),

              leading: SizedBox(height: 20),
              trailing: Padding(
                padding: EdgeInsetsGeometry.only(bottom: 20),
                child: IconButton(
                  tooltip: 'Sign out',
                  onPressed: () {
                    openDialogBox();
                  },
                  icon: const Icon(Icons.logout),
                ),
              ),
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.equalizer_outlined),
                  label: Text("Enquires"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.category),
                  label: Text("Catalogues"),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) => setScreenIndex(value),
            ),
            VerticalDivider(),
            Expanded(
              child: IndexedStack(index: selectedIndex, children: screens),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> openDialogBox() {
    return Get.generalDialog(
      pageBuilder: (context, animation, secondaryAnimation) {
        return SimpleDialog(
          title: Text("Are you sure to Sign Out!", textAlign: TextAlign.center),
          titlePadding: EdgeInsetsGeometry.fromLTRB(24, 24, 24, 40),
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
                  child: Text("No"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.find<LoginController>().logout();
                  },
                  child: Text("Yes"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
