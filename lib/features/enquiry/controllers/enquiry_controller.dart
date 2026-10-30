import 'dart:developer';

import 'package:get/get.dart';
import 'package:gifting_admin/core/widgets/custom_toast.dart';
import 'package:gifting_admin/features/enquiry/models/enquiry_model.dart';
import 'package:gifting_admin/features/enquiry/services/enquiry_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EnquiryController extends GetxController {
  EnquiryController({EnquiryServices? enquiryServices})
    : _enquiryServices = enquiryServices ?? EnquiryServices();

  final EnquiryServices _enquiryServices;
  final enquiries = <EnquiryModel>[].obs;
  final selectedStatus = 'All'.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final updatingIds = <String>{}.obs;

  final statuses = const ['All', 'New', 'Contacted', 'Converted', 'Lost'];

  List<EnquiryModel> get filteredEnquiries {
    if (selectedStatus.value == 'All') {
      return enquiries.toList();
    }

    return enquiries
        .where((item) => item.status == selectedStatus.value)
        .toList();
  }

  int get newCount => enquiries.where((item) => item.status == 'New').length;

  int get contactedCount =>
      enquiries.where((item) => item.status == 'Contacted').length;

  int get convertedCount =>
      enquiries.where((item) => item.status == 'Converted').length;

  @override
  void onInit() {
    super.onInit();
    if (enquiries.isEmpty) {
      loadEnquiries();
    }
  }

  Future<void> loadEnquiries() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      enquiries.assignAll(await _enquiryServices.fetchEnquiries());
    } on PostgrestException catch (error) {
      errorMessage.value = error.message;
    } catch (e, stackTree) {
      log("Error load enquiries $e, $stackTree");
      isLoading.value = false;
      errorMessage.value = 'Unable to load enquiries. Please try again.';
      customToast(
        title: "",
        text: "Unable to load enquiries. Please try again.",
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeStatus({
    required EnquiryModel enquiry,
    required String newStatus,
  }) async {
    const allowedStatuses = ['New', 'Contacted', 'Converted', 'Lost'];

    if (!allowedStatuses.contains(newStatus) ||
        newStatus == enquiry.status ||
        updatingIds.contains(enquiry.id)) {
      return;
    }

    updatingIds.add(enquiry.id ?? "");
    updatingIds.refresh();

    try {
      await _enquiryServices.updateStatus(
        enquiryId: enquiry.id ?? "",
        status: newStatus,
      );

      final index = enquiries.indexWhere((item) => item.id == enquiry.id);

      if (index != -1) {
        enquiries[index] = EnquiryModel(
          id: enquiry.id,
          referenceCode: enquiry.referenceCode,
          name: enquiry.name,
          company: enquiry.company,
          phone: enquiry.phone,
          email: enquiry.email,
          occasion: enquiry.occasion,
          quantity: enquiry.quantity,
          budget: enquiry.budget,
          deliveryDate: enquiry.deliveryDate,
          products: enquiry.products,
          customisations: enquiry.customisations,
          message: enquiry.message,
          source: enquiry.source,
          status: newStatus,
          createdAt: enquiry.createdAt,
        );
      }

      customToast(
        title: 'Status updated',
        text: '${enquiry.referenceCode} → $newStatus',
      );
    } catch (e, stackTree) {
      log("Error enquiry status change $e, $stackTree");
      customToast(
        title: 'Update failed',
        text: 'Could not save the status. Check your admin permissions.',
      );
    } finally {
      updatingIds.remove(enquiry.id);
      updatingIds.refresh();
    }
  }
}
