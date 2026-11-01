import 'dart:developer';

import 'package:get/get.dart';
import 'package:gifting_admin/core/utils/file_downloader/file_downloader.dart';
import 'package:gifting_admin/core/widgets/custom_toast.dart';
import 'package:gifting_admin/features/enquiry/models/enquiry_model.dart';
import 'package:gifting_admin/features/enquiry/models/enquiry_stats_model.dart';
import 'package:gifting_admin/features/enquiry/services/enquiry_services.dart';
import 'package:gifting_admin/features/enquiry/utils/enquiry_csv_exporter.dart';
import 'package:intl/intl.dart';
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
  final RxBool isLoadingStats = false.obs;
  final Rxn<EnquiryStatsModel> stats = Rxn<EnquiryStatsModel>();

  final statuses = const ['All', 'New', 'Contacted', 'Converted', 'Lost'];

  final currentPage = 1.obs;
  final pageSize = 10.obs;

  int get totalPages {
    final count = filteredEnquiries.length;
    if (count == 0) return 1;
    return (count / pageSize.value).ceil();
  }

  bool get canGoPrevious => currentPage.value > 1;

  bool get canGoNext => currentPage.value < totalPages;

  List<EnquiryModel> get paginatedEnquiries {
    final items = filteredEnquiries;
    if (items.isEmpty) return [];

    final maxPage = totalPages;
    final page = currentPage.value.clamp(1, maxPage > 0 ? maxPage : 1);

    final start = (page - 1) * pageSize.value;
    if (start >= items.length) return [];
    final end = (start + pageSize.value).clamp(0, items.length);
    return items.sublist(start, end);
  }

  void nextPage() {
    if (canGoNext) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (canGoPrevious) {
      currentPage.value--;
    }
  }

  void goToPage(int page) {
    final maxPage = totalPages;
    currentPage.value = page.clamp(1, maxPage);
  }

  void setPageSize(int size) {
    if (size > 0 && size != pageSize.value) {
      pageSize.value = size;
      currentPage.value = 1;
    }
  }

  List<EnquiryModel> get filteredEnquiries {
    if (selectedStatus.value == 'All') {
      return enquiries.toList();
    }

    return enquiries
        .where((item) => item.status == selectedStatus.value)
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    ever(selectedStatus, (_) {
      currentPage.value = 1;
    });
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    await Future.wait([loadStats(), loadEnquiries()]);
  }

  Future<void> loadStats() async {
    try {
      isLoadingStats.value = true;
      stats.value = await _enquiryServices.getEnquiryStats();
    } catch (e) {
      customToast(title: 'Error', text: 'Unable to load enquiry statistics');
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> loadEnquiries() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      enquiries.assignAll(await _enquiryServices.fetchEnquiries());
      if (currentPage.value > totalPages) {
        currentPage.value = 1;
      }
    } on PostgrestException catch (error) {
      errorMessage.value = error.message;
    } catch (e, stackTree) {
      log('Error load enquiries $e, $stackTree');
      isLoading.value = false;
      errorMessage.value = 'Unable to load enquiries. Please try again.';
      customToast(
        title: '',
        text: 'Unable to load enquiries. Please try again.',
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

    updatingIds.add(enquiry.id ?? '');
    updatingIds.refresh();

    try {
      await _enquiryServices.updateStatus(
        enquiryId: enquiry.id ?? '',
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

      if (currentPage.value > totalPages) {
        currentPage.value = totalPages.clamp(1, totalPages);
      }
      await loadStats();

      customToast(
        title: 'Status updated',
        text: '${enquiry.referenceCode} → $newStatus',
      );
    } catch (e, stackTree) {
      log('Error enquiry status change $e, $stackTree');
      customToast(
        title: 'Update failed',
        text: 'Could not save the status. Check your admin permissions.',
      );
    } finally {
      updatingIds.remove(enquiry.id);
      updatingIds.refresh();
    }
  }

  Future<void> downloadAllEnquiriesAsCsv() async {
    try {
      if (enquiries.isEmpty) {
        await loadEnquiries();
      }

      if (enquiries.isEmpty) {
        customToast(
          title: 'Export CSV',
          text: 'No enquiries available to download.',
        );
        return;
      }

      final csvData = EnquiryCsvExporter.toCsv(enquiries.toList());
      final timestamp = DateFormat('dd_MMM_yyyy_hh_mm_ss')
          .format(DateTime.now());
      final fileName = 'enquiries_$timestamp.csv';

      await downloadFile(content: csvData, fileName: fileName);

      customToast(
        title: 'Download complete',
        text: 'Downloaded ${enquiries.length} enquiries to $fileName',
      );
    } catch (e, stackTree) {
      log('Error exporting CSV $e, $stackTree');
      customToast(
        title: 'Download failed',
        text: 'Could not export enquiries to CSV. Please try again.',
      );
    }
  }
}
