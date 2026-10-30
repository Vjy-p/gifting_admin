import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gifting_admin/features/enquiry/models/enquiry_model.dart';

class EnquiryScreen extends StatelessWidget {
  const EnquiryScreen({super.key, required this.enquiry});
  final EnquiryModel enquiry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [productsWidget()]),
      ),
    );
  }

  Widget productsWidget() {
    return Column(
      children: [
        CarouselView.builder(
          itemExtent: 100,
          itemCount: enquiry.products.length,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: enquiry.products[index].imageUrl ?? "",
            );
          },
        ),
      ],
    );
  }

  Widget productsName() {
    return Wrap(
      children: List.generate(enquiry.products.length, (i) {
        return Text(enquiry.products[i].name);
      }),
    );
  }
}
