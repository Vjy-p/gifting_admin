import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting_admin/core/theme/app_colors.dart';
import 'package:gifting_admin/features/enquiry/controllers/enquiry_controller.dart';
import 'package:gifting_admin/features/enquiry/views/enquiry_details_screen.dart';
import 'package:intl/intl.dart';

import '../models/enquiry_model.dart';

class EnquiryBoxTile extends StatelessWidget {
  final EnquiryModel enquiry;
  const EnquiryBoxTile({super.key, required this.enquiry});

  static final controller = Get.find<EnquiryController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.sage,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  enquiry.referenceCode ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              if (enquiry.createdAt != null)
                Text(
                  DateFormat('dd-MMM-yyyy hh:mm a').format(enquiry.createdAt!),
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          Text(
            enquiry.company,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          Text('Occasion: ${enquiry.occasion}'),
          Text('Quantity: ${enquiry.quantity} units'),
          Text('Products: ${enquiry.products.length}'),
          if (enquiry.customisations.isEmpty)
            Text('Customisations: ${enquiry.customisations.join(", ")}'),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                enquiry.createdAt?.toString().split(' ').first ?? '',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const Spacer(),
              statusChangeWidget(),
              TextButton(
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
                child: const Text('View details →'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget statusChangeWidget() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 100, maxWidth: 150),
      child: Obx(
        () => DropdownButtonFormField<String>(
          // isExpanded: true,
          isDense: true,
          initialValue: enquiry.status,
          style: const TextStyle(fontSize: 12),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            visualDensity: VisualDensity.compact,
            prefixIcon: Icon(Icons.lock_outline, size: 16),
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
                style: TextStyle(fontSize: 12, color: AppColors.blackText),
              ),
            ),
            DropdownMenuItem(
              value: 'Contacted',
              child: Text(
                'Contacted',
                style: TextStyle(fontSize: 12, color: AppColors.blackText),
              ),
            ),
            DropdownMenuItem(
              value: 'Converted',
              child: Text(
                'Converted',
                style: TextStyle(fontSize: 12, color: AppColors.blackText),
              ),
            ),
            DropdownMenuItem(
              value: 'Lost',
              child: Text(
                'Lost',
                style: TextStyle(fontSize: 12, color: AppColors.blackText),
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
    );
  }
}
