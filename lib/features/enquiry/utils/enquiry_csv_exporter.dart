import 'package:gifting_admin/features/enquiry/models/enquiry_model.dart';
import 'package:intl/intl.dart';

class EnquiryCsvExporter {
  EnquiryCsvExporter._();

  static String toCsv(List<EnquiryModel> enquiries) {
    final buffer = StringBuffer();

    final headers = [
      'Enquiry ID',
      'Reference Code',
      'Customer Name',
      'Company',
      'Phone',
      'Email',
      'Occasion',
      'Quantity',
      'Budget',
      'Delivery Date',
      'Status',
      'Source',
      'Products',
      'Customisations',
      'Message',
      'Created At',
      'Created Time',
    ];
    buffer.writeln(headers.map(_escapeCsvValue).join(','));

    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('hh:mm a');

    for (final enquiry in enquiries) {
      final localCreatedAt = enquiry.createdAt?.toLocal();
      final row = [
        enquiry.id ?? '',
        enquiry.referenceCode ?? '',
        enquiry.name,
        enquiry.company,
        enquiry.phone,
        enquiry.email,
        enquiry.occasion,
        enquiry.quantity.toString(),
        enquiry.budget,
        dateFormat.format(enquiry.deliveryDate),
        enquiry.status,
        enquiry.source,
        enquiry.products.map((p) => p.name).join('; '),
        enquiry.customisations.join('; '),
        enquiry.message,
        localCreatedAt != null ? dateFormat.format(localCreatedAt) : '',
        localCreatedAt != null ? timeFormat.format(localCreatedAt) : '',
      ];
      buffer.writeln(row.map(_escapeCsvValue).join(','));
    }

    return buffer.toString();
  }

  static String _escapeCsvValue(dynamic value) {
    if (value == null) return '';
    final str = value.toString();
    if (str.contains(',') ||
        str.contains('"') ||
        str.contains('\n') ||
        str.contains('\r')) {
      return '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }
}
