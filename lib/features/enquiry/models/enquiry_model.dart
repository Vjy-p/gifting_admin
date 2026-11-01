import 'package:gifting_admin/features/catalogues/models/product_model.dart';

class EnquiryModel {
  const EnquiryModel({
    this.id,
    this.referenceCode,
    required this.name,
    required this.company,
    required this.phone,
    required this.email,
    required this.occasion,
    required this.quantity,
    required this.budget,
    required this.deliveryDate,
    required this.products,
    required this.customisations,
    required this.message,
    required this.source,
    this.status = 'New',
    this.createdAt,
  });

  final String? id;
  final String? referenceCode;

  final String name;
  final String company;
  final String phone;
  final String email;
  final String occasion;
  final int quantity;
  final String budget;
  final DateTime deliveryDate;

  final List<ProductModel> products;
  final List<String> customisations;

  final String message;
  final String source;

  final String status;
  final DateTime? createdAt;

  /// Data sent when inserting a new enquiry.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'company': company,
      'phone': phone,
      'email': email,
      'occasion': occasion,
      'quantity': quantity,
      'budget': budget,
      'delivery_date': _dateOnly(deliveryDate),
      'products': products.map((product) => product.toJson()).toList(),
      'customisations': customisations,
      'message': message,
      'source': source,
      'status': status,
    };
  }

  /// Data received when reading an enquiry from Supabase.
  factory EnquiryModel.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'] as List? ?? [];

    return EnquiryModel(
      id: json['id']?.toString(),
      referenceCode: json['reference_code']?.toString(),
      name: json['name']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      occasion: json['occasion']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      budget: json['budget']?.toString() ?? '',
      deliveryDate: DateTime.parse(json['delivery_date'].toString()),
      products: rawProducts.map((item) {
        if (item is Map) {
          return ProductModel.fromJson(Map<String, dynamic>.from(item));
        }

        // Supports older enquiries where products were stored as names.
        return ProductModel(
          id: '',
          name: item.toString(),
          category: '',
          minPrice: 0,
          maxPrice: 0,
          description: '',
        );
      }).toList(),
      customisations: List<String>.from(json['customisations'] ?? const []),
      message: json['message']?.toString() ?? '',
      source: json['source']?.toString() ?? 'website',
      status: json['status']?.toString() ?? 'New',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }

  static String _dateOnly(DateTime date) {
    final localDate = DateTime(date.year, date.month, date.day);
    return '${localDate.year.toString().padLeft(4, '0')}-'
        '${localDate.month.toString().padLeft(2, '0')}-'
        '${localDate.day.toString().padLeft(2, '0')}';
  }
}
