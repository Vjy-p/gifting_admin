import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting_admin/core/theme/app_colors.dart';
import 'package:gifting_admin/features/catalogues/controllers/catalogues_controller.dart';

class WebFilterWidget extends StatelessWidget {
  const WebFilterWidget({
    super.key,
    required this.controller,
    this.scrollController,
  });

  final CatalogueController controller;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: controller.clearFilters,
                  child: const Text('Clear all'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _sectionTitle('Category'),

            ...controller.categories.map(
              (category) => RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(category),
                value: category,
                groupValue: controller.selectedCategory.value,
                onChanged: (value) {
                  if (value != null) {
                    controller.selectCategory(value);
                  }
                },
              ),
            ),

            const Divider(height: 30),

            _sectionTitle('Occasions'),

            ...controller.occasionsList.map(
              (occasion) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(occasion),
                value: controller.selectedOccasions.contains(occasion),
                onChanged: (value) {
                  controller.toggleOccasion(occasion);
                },
              ),
            ),

            const Divider(height: 30),

            _sectionTitle('Price range'),

            ...List.generate(
              controller.budgetOptions.length,
              (index) => RadioListTile<int>(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(controller.budgetOptions[index]),
                value: index,
                groupValue: controller.selectedBudgetIndex.value,
                onChanged: (value) {
                  if (value != null) {
                    controller.selectBudget(value);
                  }
                },
              ),
            ),

            const Divider(height: 30),

            _sectionTitle('Customisation'),

            ...controller.customisationOptions.map(
              (customisation) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(customisation),
                value: controller.selectedCustomisations.contains(
                  customisation,
                ),
                onChanged: (value) {
                  controller.toggleCustomisation(customisation);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Opens the filters in a bottom sheet (mobile / tablet).
Future<void> showCatalogueFilterSheet(
  BuildContext context,
  CatalogueController controller,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: WebFilterWidget(
              controller: controller,
              scrollController: scrollController,
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Show ${controller.products.length} results'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
