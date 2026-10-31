import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting_admin/core/theme/app_colors.dart';
import 'package:gifting_admin/features/enquiry/controllers/enquiry_controller.dart';
import 'package:gifting_admin/features/enquiry/models/enquiry_model.dart';
import 'package:gifting_admin/features/enquiry/views/enquiry_details_screen.dart';

class EnquiryTile extends GetView<EnquiryController> {
  const EnquiryTile({super.key, required this.enquiry});
  final EnquiryModel enquiry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: Text(
              enquiry.referenceCode ?? '',
              style: TextStyle(fontSize: 12, color: AppColors.blackText),
            ),
          ),
          contactDetails(),
          Expanded(
            child: Text(
              enquiry.products.isNotEmpty
                  ? '${enquiry.products.first.name} ${enquiry.products.length > 1 ? '...' : ''}'
                  : '',
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: AppColors.blackText),
            ),
          ),
          Expanded(
            child: Text(
              enquiry.source,
              style: TextStyle(fontSize: 12, color: AppColors.blackText),
            ),
          ),
          Expanded(
            child: Text(
              enquiry.quantity.toString(),
              style: TextStyle(fontSize: 12, color: AppColors.blackText),
            ),
          ),
          Expanded(
            child: Text(
              enquiry.budget,
              style: TextStyle(fontSize: 12, color: AppColors.blackText),
            ),
          ),
          // Expanded(
          //   child: Text(
          //     // DateFormat('dd MMM yyyy, hh:mm a')
          //     //     .format(enquiry.createdAt.toLocal()),
          //     enquiry.deliveryDate,
          //   ),
          // ),

          Expanded(
            child: Obx(
              () => DropdownButtonFormField<String>(
                isExpanded: true,
                isDense: true,
                initialValue: enquiry.status,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline, size: 16),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 8,
                  ),
                  visualDensity: VisualDensity.compact,
                  // suffixIcon: IconButton(
                  //   onPressed: () {
                  //     controller.obscurePassword.toggle();
                  //   },
                  //   icon: Icon(
                  //     controller.obscurePassword.value
                  //         ? Icons.visibility_outlined
                  //         : Icons.visibility_off_outlined,
                  //   ),
                  // ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'New',
                    child: Text(
                      'New',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.blackText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Contacted',
                    child: Text(
                      'Contacted',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.blackText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Converted',
                    child: Text(
                      'Converted',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.blackText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Lost',
                    child: Text(
                      'Lost',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.blackText,
                      ),
                    ),
                  ),
                ],
                onChanged: controller.updatingIds.contains(enquiry.id)
                    ? null
                    : (status) {
                        if (status != null && status != enquiry.status) {
                          controller.changeStatus(
                            enquiry: enquiry,
                            newStatus: status,
                          );
                        }
                      },
              ),
            ),
          ),
          Expanded(
            child: TextButton.icon(
              onPressed: () {
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
                    child: EnquiryDetailsScreen(enquiry: enquiry),
                  ),
                );
              },
              iconAlignment: IconAlignment.end,
              label: const Text(
                'View',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              icon: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget contactDetails() {
    return Expanded(
      child: Column(
        spacing: 2,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            enquiry.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, color: AppColors.blackText),
          ),
          Text(
            enquiry.company,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: AppColors.blackText),
          ),
          Text(
            enquiry.email,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: AppColors.blackText),
          ),
          Text(
            enquiry.phone,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: AppColors.blackText),
          ),
        ],
      ),
    );
  }
}
