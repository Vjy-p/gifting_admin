import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gifting_admin/features/catalogues/services/product_services.dart';
import 'package:gifting_admin/features/enquiry/models/product_model.dart';

class CatalogueController extends GetxController {
  CatalogueController({ProductServices? repository})
    : _repository = repository ?? ProductServices();

  final ProductServices _repository;

  final searchController = TextEditingController();

  static const int pageSize = 8;

  final categories = [
    'All Gifts',
    'Drinkware',
    'Apparel',
    'Work Essentials',
    'Wellness',
  ];

  final occasionsList = [
    'Employee Onboarding',
    'Corporate Diwali Gifting',
    'New Year Gifts',
    'Client and Vendor Gifting',
    'Events and Trade Shows',
    'Employee Recognition',
  ];

  final customisationOptions = [
    'Logo printing',
    'Laser engraving',
    'Name personalisation',
  ];

  final budgetOptions = [
    'All Budgets',
    'Under ₹500',
    '₹500 – ₹1,500',
    '₹1,500 – ₹3,000',
    'Above ₹3,000',
  ];

  final products = <ProductModel>[].obs;

  final selectedCategory = 'All Gifts'.obs;
  final selectedOccasions = <String>[].obs;
  final selectedCustomisations = <String>[].obs;
  final selectedBudgetIndex = 0.obs;

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = ''.obs;

  int _currentPage = 0;
  Timer? _searchDebounce;

  int? get minPrice {
    switch (selectedBudgetIndex.value) {
      case 1:
        return 0;
      case 2:
        return 500;
      case 3:
        return 1500;
      case 4:
        return 3000;
      default:
        return null;
    }
  }

  int? get maxPrice {
    switch (selectedBudgetIndex.value) {
      case 1:
        return 500;
      case 2:
        return 1500;
      case 3:
        return 3000;
      default:
        return null;
    }
  }

  bool get hasActiveFilters =>
      selectedCategory.value != 'All Gifts' ||
      selectedOccasions.isNotEmpty ||
      selectedCustomisations.isNotEmpty ||
      selectedBudgetIndex.value != 0;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts({bool reset = true}) async {
    if (isLoading.value || isLoadingMore.value) return;

    if (reset) {
      _currentPage = 0;
      hasMore.value = true;
      products.clear();
      errorMessage.value = '';
      isLoading.value = true;
    } else {
      if (!hasMore.value) return;
      isLoadingMore.value = true;
    }

    try {
      final result = await _repository.fetchProducts(
        page: _currentPage,
        limit: pageSize,
        search: searchController.text.trim(),
        category: selectedCategory.value,
        minPrice: minPrice,
        maxPrice: maxPrice,
        occasions: selectedOccasions.toList(),
        customisations: selectedCustomisations.toList(),
      );

      if (reset) {
        products.assignAll(result);
      } else {
        products.addAll(result);
      }

      hasMore.value = result.length == pageSize;

      if (hasMore.value) {
        _currentPage++;
      }
    } catch (error) {
      errorMessage.value = 'Unable to load products. Please try again.';
      debugPrint('Catalogue error: $error');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    loadProducts();
  }

  void selectBudget(int index) {
    selectedBudgetIndex.value = index;
    loadProducts();
  }

  void toggleOccasion(String occasion) {
    if (selectedOccasions.contains(occasion)) {
      selectedOccasions.remove(occasion);
    } else {
      selectedOccasions.add(occasion);
    }
    loadProducts();
  }

  void toggleCustomisation(String value) {
    if (selectedCustomisations.contains(value)) {
      selectedCustomisations.remove(value);
    } else {
      selectedCustomisations.add(value);
    }

    loadProducts();
  }

  void searchProducts(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () => loadProducts(),
    );
  }

  void clearFilters() {
    selectedCategory.value = 'All Gifts';
    selectedOccasions.clear();
    selectedCustomisations.clear();
    selectedBudgetIndex.value = 0;
    searchController.clear();
    _searchDebounce?.cancel();
    loadProducts();
  }

  Future<void> loadMore() async {
    await loadProducts(reset: false);
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
