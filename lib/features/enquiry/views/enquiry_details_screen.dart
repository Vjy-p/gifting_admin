import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting_admin/core/theme/app_colors.dart';
import 'package:gifting_admin/features/enquiry/models/enquiry_model.dart';
import 'package:intl/intl.dart';

import '../controllers/enquiry_controller.dart';

class EnquiryDetailsScreen extends GetView<EnquiryController> {
  const EnquiryDetailsScreen({super.key, required this.enquiry});
  final EnquiryModel enquiry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        spacing: 20,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: AlignmentGeometry.centerRight,
            child: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.remove_circle),
            ),
          ),
          sectionWidget(
            title: 'Details',
            fields: [
              textFieldWidget(label: 'Full name', value: enquiry.name),
              textFieldWidget(label: 'Company name', value: enquiry.company),
              textFieldWidget(label: 'Phone number', value: enquiry.phone),
              textFieldWidget(label: 'Email address', value: enquiry.email),
            ],
          ),
          sectionWidget(
            title: 'Order requirements',
            fields: [
              textFieldWidget(label: 'Occasion', value: enquiry.occasion),
              textFieldWidget(
                label: 'Number of units',
                value: enquiry.quantity.toString(),
              ),
              textFieldWidget(
                label: 'Budget per unit *',
                value: enquiry.budget,
              ),
              textFieldWidget(
                label: 'Delivery date',
                value: DateFormat('dd MMM yyyy').format(enquiry.deliveryDate),
              ),
              textFieldWidget(
                label: 'Customisation',
                value: enquiry.customisations.join(', '),
              ),
              textFieldWidget(
                label: 'Additional message',
                value: enquiry.message,
              ),
            ],
          ),
          productsWidget(),
        ],
      ),
    );
  }

  Widget sectionWidget({required String title, required List<Widget> fields}) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [sectionTitle(title), ...fields],
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.darkGreen,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget textFieldWidget({required String label, required String value}) {
    return Row(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.titleText,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: AppColors.text),
          ),
        ),
      ],
    );
  }

  Widget productsWidget() {
    return Column(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle('Products'),
        enquiry.products.isEmpty
            ? const Center(
                child: Text(
                  'No products selected yet.',
                  textAlign: TextAlign.center,
                ),
              )
            : SizedBox(
                height: 220,
                child: ListView.separated(
                  itemCount: enquiry.products.length,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20),
                  clipBehavior: Clip.none,
                  itemBuilder: (context, index) {
                    final product = enquiry.products[index];
                    return AspectRatio(
                      aspectRatio: 1,
                      child: Card(
                        child: Column(
                          spacing: 10,
                          children: [
                            Expanded(
                              flex: 5,
                              child: ClipRRect(
                                borderRadius: BorderRadiusGeometry.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: product.imageUrl ?? '',
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) {
                                    return Center(
                                      child: Icon(
                                        Icons.card_giftcard_outlined,
                                        size: 46,
                                        color: AppColors.primary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                ),
              ),
      ],
    );
  }
}
