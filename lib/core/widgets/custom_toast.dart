import 'package:flutter/painting.dart';
import 'package:get/get.dart';

SnackbarController customToast({required String title, required String text}) {
  return Get.snackbar(
    title,
    text,
    snackPosition: SnackPosition.BOTTOM,
    padding: const EdgeInsets.all(16),
  );
}
