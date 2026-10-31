import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gifting_admin/core/theme/theme_controller.dart';
import 'package:gifting_admin/features/enquiry/controllers/enquiry_controller.dart';
import 'package:gifting_admin/features/enquiry/models/enquiry_model.dart';
import 'package:gifting_admin/features/enquiry/models/enquiry_stats_model.dart';
import 'package:gifting_admin/features/enquiry/services/enquiry_services.dart';
import 'package:gifting_admin/features/enquiry/utils/enquiry_csv_exporter.dart';
import 'package:gifting_admin/features/enquiry/views/enquires_screen.dart';

EnquiryModel _mockEnquiry(int id, {String status = 'New'}) {
  return EnquiryModel(
    id: 'id_$id',
    referenceCode: 'ENQ-$id',
    name: 'Customer $id',
    company: 'Company $id',
    phone: '1234567890',
    email: 'cust$id@test.com',
    occasion: 'Anniversary',
    quantity: id * 10,
    budget: '\$1000',
    deliveryDate: DateTime(2026, 12, 1),
    products: const [],
    customisations: const [],
    message: 'Hello $id',
    source: 'Website',
    status: status,
    createdAt: DateTime(2026, 1, 1),
  );
}

class FakeEnquiryServices implements EnquiryServices {
  FakeEnquiryServices([this.mockItems = const []]);
  final List<EnquiryModel> mockItems;

  @override
  Future<List<EnquiryModel>> fetchEnquiries() async => mockItems;

  @override
  Future<void> updateStatus({
    required String enquiryId,
    required String status,
  }) async {}

  @override
  Future<EnquiryStatsModel> getEnquiryStats() async {
    return const EnquiryStatsModel(
      total: 0,
      newCount: 0,
      contacted: 0,
      converted: 0,
      lost: 0,
    );
  }
}

void main() {
  setUp(() {
    Get.reset();
    Get.put(ThemeController());
  });

  tearDown(() {
    Get.reset();
  });

  group('EnquiryController pagination logic', () {
    test('Empty enquiries should have 1 total page and disabled buttons', () {
      final controller = EnquiryController(enquiryServices: FakeEnquiryServices());
      controller.enquiries.clear();

      expect(controller.totalPages, 1);
      expect(controller.currentPage.value, 1);
      expect(controller.canGoPrevious, isFalse);
      expect(controller.canGoNext, isFalse);
      expect(controller.paginatedEnquiries, isEmpty);
    });

    test('25 enquiries paginate properly with pageSize 10', () {
      final controller = EnquiryController(enquiryServices: FakeEnquiryServices());
      final items = List.generate(25, (i) => _mockEnquiry(i + 1));
      controller.enquiries.assignAll(items);

      expect(controller.totalPages, 3);
      expect(controller.currentPage.value, 1);
      expect(controller.canGoPrevious, isFalse);
      expect(controller.canGoNext, isTrue);
      expect(controller.paginatedEnquiries.length, 10);
      expect(controller.paginatedEnquiries.first.referenceCode, 'ENQ-1');

      // Next to page 2
      controller.nextPage();
      expect(controller.currentPage.value, 2);
      expect(controller.canGoPrevious, isTrue);
      expect(controller.canGoNext, isTrue);
      expect(controller.paginatedEnquiries.length, 10);
      expect(controller.paginatedEnquiries.first.referenceCode, 'ENQ-11');

      // Next to page 3
      controller.nextPage();
      expect(controller.currentPage.value, 3);
      expect(controller.canGoPrevious, isTrue);
      expect(controller.canGoNext, isFalse);
      expect(controller.paginatedEnquiries.length, 5);
      expect(controller.paginatedEnquiries.first.referenceCode, 'ENQ-21');

      // Attempt next beyond max
      controller.nextPage();
      expect(controller.currentPage.value, 3);

      // Previous back to page 2
      controller.previousPage();
      expect(controller.currentPage.value, 2);

      // Previous back to page 1
      controller.previousPage();
      expect(controller.currentPage.value, 1);
      expect(controller.canGoPrevious, isFalse);

      // Attempt previous beyond 1
      controller.previousPage();
      expect(controller.currentPage.value, 1);
    });

    test('Changing selectedStatus resets currentPage to 1', () {
      final controller = EnquiryController(enquiryServices: FakeEnquiryServices());
      controller.onInit();
      final items = [
        ...List.generate(15, (i) => _mockEnquiry(i + 1, status: 'New')),
        ...List.generate(5, (i) => _mockEnquiry(i + 16, status: 'Converted')),
      ];
      controller.enquiries.assignAll(items);

      controller.nextPage();
      expect(controller.currentPage.value, 2);

      controller.selectedStatus.value = 'Converted';
      expect(controller.currentPage.value, 1);
      expect(controller.filteredEnquiries.length, 5);
      expect(controller.totalPages, 1);
    });
  });

  group('EnquiresScreen web pagination UI', () {
    testWidgets('Renders bottom row and paginates enquiries on button tap', (
      tester,
    ) async {
      final items = List.generate(25, (i) => _mockEnquiry(i + 1));
      final controller = EnquiryController(enquiryServices: FakeEnquiryServices(items));
      controller.enquiries.assignAll(items);
      Get.put<EnquiryController>(controller);

      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: EnquiresScreen())),
      );
      await tester.pumpAndSettle();

      // Check header and first page content
      expect(find.text('Enquiries'), findsOneWidget);
      expect(find.text('ENQ-1'), findsOneWidget);
      expect(find.text('ENQ-11'), findsNothing);

      // Check bottom row
      expect(find.text('Showing 1–10 of 25 enquiries'), findsOneWidget);
      expect(find.text('Page 1 of 3'), findsOneWidget);
      expect(find.text('Previous Page'), findsOneWidget);
      expect(find.text('Next Page'), findsOneWidget);

      // Tap Next Page
      await tester.tap(find.text('Next Page'));
      await tester.pumpAndSettle();

      // Page 2 assertions
      expect(find.text('Page 2 of 3'), findsOneWidget);
      expect(find.text('Showing 11–20 of 25 enquiries'), findsOneWidget);
      expect(find.text('ENQ-1'), findsNothing);
      expect(find.text('ENQ-11'), findsOneWidget);

      // Tap Previous Page
      await tester.tap(find.text('Previous Page'));
      await tester.pumpAndSettle();

      // Back to Page 1
      expect(find.text('Page 1 of 3'), findsOneWidget);
      expect(find.text('Showing 1–10 of 25 enquiries'), findsOneWidget);
      expect(find.text('ENQ-1'), findsOneWidget);
      expect(find.text('ENQ-11'), findsNothing);

      // Previous button on Page 1 is disabled
      await tester.tap(find.text('Previous Page'));
      await tester.pumpAndSettle();
      expect(find.text('Page 1 of 3'), findsOneWidget);
    });

    testWidgets('Renders empty state when there are no enquiries', (
      tester,
    ) async {
      final controller = EnquiryController(enquiryServices: FakeEnquiryServices());
      controller.enquiries.clear();
      Get.put<EnquiryController>(controller);

      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: EnquiresScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('No enquiries found.'), findsOneWidget);
      expect(find.text('No enquiries found'), findsOneWidget);
      expect(find.text('Page 1 of 1'), findsOneWidget);
      expect(find.text('Previous Page'), findsOneWidget);
      expect(find.text('Next Page'), findsOneWidget);
    });

    testWidgets('Tapping download icon triggers CSV download of all enquiries', (
      tester,
    ) async {
      final items = List.generate(25, (i) => _mockEnquiry(i + 1));
      final controller = EnquiryController(
        enquiryServices: FakeEnquiryServices(items),
      );
      controller.enquiries.assignAll(items);
      Get.put<EnquiryController>(controller);

      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: EnquiresScreen())),
      );
      await tester.pumpAndSettle();

      final downloadIcons = find.byIcon(Icons.download_rounded);
      expect(downloadIcons, findsAtLeastNWidgets(1));

      // Tap the download icon in the header
      await tester.tap(downloadIcons.first);
      await tester.pumpAndSettle();

      // Controller should still retain all 25 enquiries
      expect(controller.enquiries.length, 25);
    });
  });

  group('EnquiryCsvExporter unit tests', () {
    test('Correctly escapes special characters and generates valid CSV', () {
      final enquiries = [
        EnquiryModel(
          id: '1',
          referenceCode: 'REF-001',
          name: 'John Doe',
          company: 'Acme, Inc.',
          phone: '999888777',
          email: 'john@acme.com',
          occasion: 'Diwali "Special"',
          quantity: 50,
          budget: '\$5,000',
          deliveryDate: DateTime(2026, 11, 15),
          products: const [],
          customisations: const ['Logo', 'Ribbon'],
          message: 'Line 1\nLine 2',
          source: 'Web',
          status: 'New',
          createdAt: DateTime(2026, 10, 31, 10, 30),
        ),
      ];

      final csv = EnquiryCsvExporter.toCsv(enquiries);

      // Verify header
      expect(
        csv,
        contains('Enquiry ID,Reference Code,Customer Name'),
      );
      expect(csv, contains('Created At,Created Time'));

      // Verify escaping
      expect(csv, contains('"Acme, Inc."'));
      expect(csv, contains('"Diwali ""Special"""'));
      expect(csv, contains('"\$5,000"'));
      expect(csv, contains('Logo; Ribbon'));
      expect(csv, contains('"Line 1\nLine 2"'));
      expect(csv, contains('2026-11-15'));
      expect(csv, contains('2026-10-31'));
    });
  });
}
