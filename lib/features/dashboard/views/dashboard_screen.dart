import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting_admin/core/theme/app_colors.dart';
import 'package:gifting_admin/core/theme/theme_controller.dart';
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
  List<Widget> screens = [const EnquiresScreen(), const CatalogueScreen()];
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
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 750;

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
          body: isMobile
              ? IndexedStack(index: selectedIndex, children: screens)
              : Row(
                  children: [
                    NavigationRail(
                      // backgroundColor: AppColors.background,
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

                      leading: const SizedBox(height: 20),
                      trailing: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Obx(
                              () => IconButton(
                                tooltip: ThemeController.to.isDarkMode
                                    ? 'Switch to Light Mode'
                                    : 'Switch to Dark Mode',
                                onPressed: () =>
                                    ThemeController.to.toggleTheme(),
                                icon: Icon(
                                  ThemeController.to.isDarkMode
                                      ? Icons.light_mode_outlined
                                      : Icons.dark_mode_outlined,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            IconButton(
                              tooltip: 'Sign out',
                              onPressed: () {
                                openDialogBox();
                              },
                              icon: const Icon(Icons.logout),
                            ),
                          ],
                        ),
                      ),
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.query_stats),
                          label: Text('Enquires'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.category),
                          label: Text('Catalogues'),
                        ),
                      ],
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (value) => setScreenIndex(value),
                    ),
                    // const VerticalDivider(),
                    Expanded(
                      child: IndexedStack(
                        index: selectedIndex,
                        children: screens,
                      ),
                    ),
                  ],
                ),
          floatingActionButton: isMobile
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'theme_toggle_btn',
                      backgroundColor: AppColors.surface,
                      tooltip: 'Toggle Theme',
                      onPressed: () => ThemeController.to.toggleTheme(),
                      child: Obx(
                        () => Icon(
                          ThemeController.to.isDarkMode
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton.small(
                      heroTag: 'logout_btn',
                      backgroundColor: AppColors.sage,
                      tooltip: 'Sign out',
                      onPressed: () {
                        openDialogBox();
                      },
                      child: const Icon(Icons.logout),
                    ),
                  ],
                )
              : null,
          bottomNavigationBar: isMobile
              ? BottomNavigationBar(
                  backgroundColor: AppColors.background,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.query_stats_outlined),
                      activeIcon: Icon(Icons.query_stats),
                      label: 'Enquires',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.category_outlined),
                      activeIcon: Icon(Icons.category),
                      label: 'Catalogues',
                    ),
                  ],
                  currentIndex: selectedIndex,
                  onTap: (value) => setScreenIndex(value),
                )
              : null,
        );
      },
    );
  }

  Future<dynamic> openDialogBox() {
    return Get.generalDialog(
      pageBuilder: (context, animation, secondaryAnimation) {
        return SimpleDialog(
          title: const Text(
            'Are you sure to Sign Out!',
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
                  onPressed: () {
                    Get.find<LoginController>().logout();
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
}
