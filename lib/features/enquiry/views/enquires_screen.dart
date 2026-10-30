import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting_admin/core/theme/app_colors.dart';
import 'package:gifting_admin/features/enquiry/controllers/enquiry_controller.dart';
import 'package:gifting_admin/features/enquiry/views/enquiry_tile.dart';

class EnquiresScreen extends GetView<EnquiryController> {
  const EnquiresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enquiries',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  metricCard(
                    title: 'Total',
                    value: controller.enquiries.length,
                  ),
                  metricCard(title: 'New', value: controller.newCount),
                  metricCard(
                    title: 'Contacted',
                    value: controller.contactedCount,
                  ),
                  metricCard(
                    title: 'Converted',
                    value: controller.convertedCount,
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
                      child: Obx(
                        () => ChoiceChip(
                          label: Text(status),
                          selected: controller.selectedStatus.value == status,
                          onSelected: (_) {
                            controller.selectedStatus.value = status;
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.border,
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.border,
                          border: Border.all(color: AppColors.border),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Row(
                          spacing: 8,
                          children: [
                            tableHeadings(title: "Enquiry ID"),
                            tableHeadings(title: "Contact"),
                            tableHeadings(title: "Products"),
                            tableHeadings(title: "Source"),
                            tableHeadings(title: "Units"),
                            tableHeadings(title: "Budget"),
                            tableHeadings(title: "Status"),
                            tableHeadings(flex: 1, title: ""),
                          ],
                        ),
                      ),
                      Divider(),
                      Expanded(
                        child: items.isEmpty
                            ? const Center(child: Text('No enquiries found.'))
                            : ListView.separated(
                                itemCount: items.length,
                                physics: BouncingScrollPhysics(),
                                separatorBuilder: (_, _) => const Divider(),
                                itemBuilder: (context, index) {
                                  return EnquiryTile(enquiry: items[index]);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget metricCard({required String title, required value}) {
    return SizedBox(
      width: 145,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              const SizedBox(height: 8),
              Text('$value', style: TextStyle(fontSize: 24)),
            ],
          ),
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
