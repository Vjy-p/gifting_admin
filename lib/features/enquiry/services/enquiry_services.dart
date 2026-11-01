import 'dart:developer';

import 'package:gifting_admin/features/enquiry/models/enquiry_model.dart';
import 'package:gifting_admin/features/enquiry/models/enquiry_stats_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EnquiryServices {
  EnquiryServices({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<EnquiryModel>> fetchEnquiries() async {
    try {
      final response = await _client
          .from('enquiries')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((row) => EnquiryModel.fromJson(Map<String, dynamic>.from(row)))
          .toList();
    } on PostgrestException catch (error, stackTrace) {
      log('Supabase get enquiry error: ${error.message}, $stackTrace');
      log('Code: ${error.code}');
      rethrow;
    } catch (error, stackTrace) {
      log('Unexpected get enquiry error: $error, $stackTrace');

      rethrow;
    }
  }

  Future<void> updateStatus({
    required String enquiryId,
    required String status,
  }) async {
    try {
      const allowedStatuses = ['New', 'Contacted', 'Converted', 'Lost'];

      if (!allowedStatuses.contains(status)) {
        throw ArgumentError('Invalid enquiry status.');
      }

      await _client
          .from('enquiries')
          .update({'status': status})
          .eq('id', enquiryId);
    } on PostgrestException catch (error, stackTrace) {
      log('Supabase update enquiry error: ${error.message}, $stackTrace');
      log('Code: ${error.code}');
      rethrow;
    } catch (error, stackTrace) {
      log('Unexpected update enquiry error: $error, $stackTrace');

      rethrow;
    }
  }

  Future<EnquiryStatsModel> getEnquiryStats() async {
    try {
      final response = await _client.rpc('get_enquiry_stats');

      return EnquiryStatsModel.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    } on PostgrestException catch (error, stackTrace) {
      log('Supabase get enquiry stats error: ${error.message}, $stackTrace');
      log('Code: ${error.code}');
      rethrow;
    } catch (error, stackTrace) {
      log('Unexpected get enquiry stats error: $error, $stackTrace');

      rethrow;
    }
  }
}
