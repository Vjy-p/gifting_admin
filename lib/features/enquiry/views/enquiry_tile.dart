import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:gifting_admin/core/theme/app_colors.dart';
import 'package:gifting_admin/features/enquiry/controllers/enquiry_controller.dart';
import 'package:gifting_admin/features/enquiry/models/enquiry_model.dart';

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
              enquiry.referenceCode ?? "",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          contactDetails(),
          Expanded(
            child: Text(
              enquiry.products.join(', '),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(child: Text(enquiry.source)),
          Expanded(child: Text(enquiry.quantity.toString())),
          Expanded(child: Text(enquiry.budget)),
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
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline, size: 18),
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
                items: const [
                  DropdownMenuItem(value: 'New', child: Text('New')),
                  DropdownMenuItem(
                    value: 'Contacted',
                    child: Text('Contacted'),
                  ),
                  DropdownMenuItem(
                    value: 'Converted',
                    child: Text('Converted'),
                  ),
                  DropdownMenuItem(value: 'Lost', child: Text('Lost')),
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
              onPressed: () {},
              iconAlignment: IconAlignment.end,
              label: Text(
                "View",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              icon: Icon(
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
