import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gifting_admin/core/theme/theme_controller.dart';
import 'package:gifting_admin/main.dart';

void main() {
  testWidgets('App smoke test initializes MyApp', (WidgetTester tester) async {
    Get.testMode = true;
    Get.put(ThemeController());

    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });
}
