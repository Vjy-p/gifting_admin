import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting_admin/core/theme/app_colors.dart';
import 'package:gifting_admin/features/catalogues/models/product_model.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1150),
          child: Column(
            spacing: 20,
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
              sectionTitle('Product Details'),
              productImage(),
              productInformation(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget productImage() {
    final String imageUrl = product.imageUrl ?? '';
    if (imageUrl.isEmpty) {
      return Center(
        child: Icon(Icons.card_giftcard, size: 56, color: AppColors.primary),
      );
    }
    log('image url $imageUrl');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.sage,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 1,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          errorWidget: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.card_giftcard_outlined,
                size: 96,
                color: AppColors.primary,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget productInformation(BuildContext context) {
    return Column(
      spacing: 20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.category.toUpperCase(),
          style: TextStyle(
            color: AppColors.primary,
            letterSpacing: 1.5,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(product.name, style: Theme.of(context).textTheme.headlineMedium),
        Text(
          '${product.priceRange} / unit',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        if (product.description.isNotEmpty)
          Text(
            product.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        sectionWidget(
          title: 'Suitable Occasions',
          widgets: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(product.occasions.length, (i) {
                return Text('* ${product.occasions[i]}');
              }),
            ),
          ],
        ),

        sectionWidget(
          title: 'Customisation Available',
          widgets: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: product.customisations.map((option) {
                return Text('* $option');
              }).toList(),
            ),
          ],
        ),
        Text(
          'Final pricing depends on order quantity and customisation.',
          style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
        ),
      ],
    );
  }

  Widget sectionWidget({required String title, required List<Widget> widgets}) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [sectionTitle(title), ...widgets],
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.text,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
