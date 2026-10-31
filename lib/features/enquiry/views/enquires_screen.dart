import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting_admin/core/theme/app_colors.dart';
import 'package:gifting_admin/core/theme/theme_controller.dart';
import 'package:gifting_admin/features/enquiry/controllers/enquiry_controller.dart';
import 'package:gifting_admin/features/enquiry/models/enquiry_model.dart';
import 'package:gifting_admin/features/enquiry/views/enquiry_box_tile.dart';
import 'package:gifting_admin/features/enquiry/views/enquiry_tile.dart';

class EnquiresScreen extends GetView<EnquiryController> {
  const EnquiresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth <= 900;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(controller.errorMessage.value),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: controller.loadEnquiries,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final items = controller.filteredEnquiries;

              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Enquiries',
                                style: isMobile
                                    ? textTheme.bodyLarge
                                    : textTheme.headlineMedium,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 8,
                                children: [
                                  Obx(
                                    () => IconButton(
                                      tooltip: ThemeController.to.isDarkMode
                                          ? 'Switch to Light Mode'
                                          : 'Switch to Dark Mode',
                                      onPressed:
                                          () => ThemeController.to.toggleTheme(),
                                      style: IconButton.styleFrom(
                                        backgroundColor: AppColors.surface,
                                        foregroundColor: AppColors.primary,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                        side: BorderSide(
                                          color: AppColors.border,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      icon: Icon(
                                        ThemeController.to.isDarkMode
                                            ? Icons.light_mode_outlined
                                            : Icons.dark_mode_outlined,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Download all enquiries as CSV',
                                    onPressed:
                                        controller.downloadAllEnquiriesAsCsv,
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppColors.surface,
                                      foregroundColor: AppColors.primary,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                      side: BorderSide(
                                        color: AppColors.border,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: const Icon(Icons.download_rounded),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              metricCard(
                                title: 'Total',
                                value: controller.stats.value?.total ?? 0,
                                isMobile: isMobile,
                              ),
                              metricCard(
                                title: 'New',
                                value: controller.stats.value?.newCount ?? 0,
                                isMobile: isMobile,
                              ),
                              metricCard(
                                title: 'Contacted',
                                value: controller.stats.value?.contacted ?? 0,
                                isMobile: isMobile,
                              ),
                              metricCard(
                                title: 'Converted',
                                value: controller.stats.value?.converted ?? 0,
                                isMobile: isMobile,
                              ),
                              metricCard(
                                title: 'Lost',
                                value: controller.stats.value?.lost ?? 0,
                                isMobile: isMobile,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: controller.statuses.map((status) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(status),
                                    selected:
                                        controller.selectedStatus.value ==
                                        status,
                                    onSelected: (_) {
                                      controller.selectedStatus.value = status;
                                      controller.currentPage.value = 1;
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ];
                },
                body: isMobile
                    ? mobileWidget(items: items)
                    : webWidget(items: items),
              );
            }),
          );
        },
      ),
    );
  }

  Widget mobileWidget({required List<EnquiryModel> items}) {
    return ListView.separated(
      itemCount: items.length,
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        return EnquiryBoxTile(enquiry: items[index]);
      },
    );
  }

  Widget webWidget({required List<EnquiryModel> items}) {
    final totalItems = items.length;
    final totalPages = controller.totalPages;
    final currentPage = totalItems == 0
        ? 1
        : controller.currentPage.value.clamp(1, totalPages);
    final pageSize = controller.pageSize.value;
    final start = (currentPage - 1) * pageSize;
    final displayedItems = totalItems == 0 || start >= totalItems
        ? <EnquiryModel>[]
        : items.sublist(start, (start + pageSize).clamp(0, totalItems));

    final startItem = totalItems == 0 ? 0 : start + 1;
    final endItem = (start + displayedItems.length).clamp(0, totalItems);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.border,
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.border,
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              spacing: 8,
              children: [
                tableHeadings(title: 'Enquiry ID'),
                tableHeadings(title: 'Contact'),
                tableHeadings(title: 'Products'),
                tableHeadings(title: 'Source'),
                tableHeadings(title: 'Units'),
                tableHeadings(title: 'Budget'),
                tableHeadings(title: 'Status'),
                tableHeadings(flex: 1, title: ''),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: displayedItems.isEmpty
                ? const Center(child: Text('No enquiries found.'))
                : ListView.separated(
                    key: ValueKey('enquiries_page_$currentPage'),
                    itemCount: displayedItems.length,
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      return EnquiryTile(enquiry: displayedItems[index]);
                    },
                  ),
          ),
          const Divider(),
          paginationBottomRow(
            totalItems: totalItems,
            totalPages: totalPages,
            currentPage: currentPage,
            startItem: startItem,
            endItem: endItem,
          ),
        ],
      ),
    );
  }

  Widget paginationBottomRow({
    required int totalItems,
    required int totalPages,
    required int currentPage,
    required int startItem,
    required int endItem,
  }) {
    final canGoPrevious = controller.canGoPrevious;
    final canGoNext = controller.canGoNext;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            totalItems == 0
                ? 'No enquiries found'
                : 'Showing $startItem–$endItem of $totalItems enquiries',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.titleText,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: canGoPrevious ? controller.previousPage : null,
                icon: const Icon(Icons.chevron_left, size: 18),
                label: const Text('Previous Page'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.primary,
                  disabledForegroundColor: AppColors.secondaryText.withValues(
                    alpha: 0.5,
                  ),
                  disabledBackgroundColor: AppColors.surface.withValues(
                    alpha: 0.6,
                  ),
                  side: BorderSide(
                    color: canGoPrevious ? AppColors.primary : AppColors.border,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  minimumSize: const Size(0, 36),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'Page $currentPage of $totalPages',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.titleText,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: canGoNext ? controller.nextPage : null,
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.chevron_right, size: 18),
                label: const Text('Next Page'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.primary,
                  disabledForegroundColor: AppColors.secondaryText.withValues(
                    alpha: 0.5,
                  ),
                  disabledBackgroundColor: AppColors.surface.withValues(
                    alpha: 0.6,
                  ),
                  side: BorderSide(
                    color: canGoNext ? AppColors.primary : AppColors.border,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  minimumSize: const Size(0, 36),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget metricCard({
    required String title,
    required dynamic value,
    required bool isMobile,
  }) {
    return Card(
      child: Container(
        width: isMobile ? 120 : 145,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 6,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 14 : 20,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '$value',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 16 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tableHeadings({required String title, int? flex}) {
    return Expanded(
      flex: flex ?? 1,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.titleText,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
