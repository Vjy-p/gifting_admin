import 'package:gifting_admin/features/enquiry/models/enquiry_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EnquiryServices {
  EnquiryServices({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<EnquiryModel>> fetchEnquiries() async {
    final response = await _client
        .from('enquiries')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => EnquiryModel.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<void> updateStatus({
    required String enquiryId,
    required String status,
  }) async {
    const allowedStatuses = ['New', 'Contacted', 'Converted', 'Lost'];

    if (!allowedStatuses.contains(status)) {
      throw ArgumentError('Invalid enquiry status.');
    }

    await _client
        .from('enquiries')
        .update({'status': status})
        .eq('id', enquiryId);
  }
}
