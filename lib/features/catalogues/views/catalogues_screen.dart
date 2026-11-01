import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting_admin/core/theme/app_colors.dart';
import 'package:gifting_admin/core/theme/theme_controller.dart';
import 'package:gifting_admin/core/widgets/retry_widget.dart';
import 'package:gifting_admin/features/catalogues/controllers/catalogues_controller.dart';
import 'package:gifting_admin/features/catalogues/models/product_model.dart';
import 'package:gifting_admin/features/catalogues/views/product_details_screen.dart';
import 'package:gifting_admin/features/catalogues/views/widgets/bottom_sheet_filter.dart';
import 'package:gifting_admin/features/catalogues/views/widgets/product_tile.dart';
import 'package:gifting_admin/features/catalogues/views/widgets/web_filter_widget.dart';
import 'package:gifting_admin/features/dashboard/widgets/logout_dialog_box.dart';

class CatalogueScreen extends GetView<CatalogueController> {
  const CatalogueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth <= 900;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          spacing: 2,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Corporate Gifts',
                              style: isMobile
                                  ? textTheme.bodyLarge
                                  : textTheme.headlineMedium,
                            ),
                            Text(
                              'Explore thoughtful gifts for teams, clients and events.',
                              style: isMobile
                                  ? textTheme.bodySmall
                                  : textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      if (isMobile)
                        IconButton(
                          style: const ButtonStyle(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () {
                            openBottomSheetFilterWidget(context, controller);
                          },
                          iconSize: 20,
                          icon: const Icon(Icons.filter_alt, size: 20),
                        ),
                      if (MediaQuery.of(context).size.width < 750) ...[
                        Obx(
                          () => IconButton(
                            tooltip: ThemeController.to.isDarkMode
                                ? 'Switch to Light Mode'
                                : 'Switch to Dark Mode',
                            onPressed: () => ThemeController.to.toggleTheme(),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surface,
                              foregroundColor: AppColors.primary,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              side: BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: Icon(
                              ThemeController.to.isDarkMode
                                  ? Icons.light_mode_outlined
                                  : Icons.dark_mode_outlined,
                              size: 20,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Sign out',
                          onPressed: () {
                            openDialogBox();
                          },
                          icon: const Icon(Icons.logout),
                        ),
                      ],
                    ],
                  ),
                  if (isMobile) selectedFilters(),
                  Expanded(
                    child: isMobile
                        ? productsWidget()
                        : Row(
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minWidth: 120,
                                  maxWidth: 280,
                                ),
                                child: WebFilterWidget(controller: controller),
                              ),
                              const VerticalDivider(),
                              Expanded(child: productsWidget()),
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget productsWidget() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return RetryWidget(onPressed: controller.loadProducts);
      }

      final products = controller.products;

      if (products.isEmpty) {
        return const Center(child: Text('No products found in this category.'));
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 1300
              ? 6
              : width >= 1000
              ? 4
              : width >= 650
              ? 3
              : width >= 400
              ? 2
              : 1;

          return GridView.builder(
            itemCount: products.length,
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              childAspectRatio: columns == 1 ? 1.35 : 0.68,
            ),
            itemBuilder: (context, index) {
              final ProductModel product = products[index];
              return ProductTile(
                product: product,
                onTap: () {
                  Get.dialog(
                    // barrierDismissible: false,
                    barrierColor: AppColors.darkGreen.withValues(alpha: 0.4),
                    Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      insetPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      backgroundColor: AppColors.background,
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: ProductDetailsScreen(product: product),
                    ),
                  );
                },
              );
            },
          );
        },
      );
    });
  }

  Widget selectedFilters() {
    return Obx(
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        runAlignment: WrapAlignment.start,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          if (controller.selectedCategory.isNotEmpty) ...[
            ChoiceChip(
              label: Text(controller.selectedCategory.value),
              selected: true,
              onSelected: (_) =>
                  controller.selectCategory(controller.selectedCategory.value),
              selectedColor: AppColors.sage,
              labelStyle: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(color: AppColors.primary),
            ),
          ],
          ...controller.selectedCustomisations.map(
            (e) => ChoiceChip(
              label: Text(e),
              selected: true,
              onSelected: (_) => controller.toggleCustomisation(e),
              selectedColor: AppColors.sage,
              labelStyle: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(color: AppColors.primary),
            ),
          ),
          ...controller.selectedOccasions.map(
            (e) => ChoiceChip(
              label: Text(e),
              selected: true,
              onSelected: (_) => controller.toggleOccasion(e),
              selectedColor: AppColors.sage,
              labelStyle: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(color: AppColors.primary),
            ),
          ),
          // if (controller.selectedPrice.value.start != null) ...[
          //   ChoiceChip(
          //     label: Text(controller.selectedCategory.value),
          //     selected: true,
          //     onSelected: (_) =>
          //         controller.selectCategory(controller.selectedCategory.value),
          //     selectedColor: AppColors.sage,
          //     labelStyle: TextStyle(
          //       color: AppColors.primary,
          //       fontWeight: FontWeight.w600,
          //     ),
          //     side: BorderSide(color: AppColors.primary),
          //   ),
          // ],
        ],
      ),
    );
  }
}
