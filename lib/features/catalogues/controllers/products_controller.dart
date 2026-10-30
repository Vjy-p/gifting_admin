// import 'dart:developer';

// import 'package:get/state_manager.dart';
// import 'package:gifting_admin/features/products/services/product_services.dart';

// class ProductsController extends GetxController {
//   final _repository = ProductServices();
//   RxBool loading = true.obs;
//   RxBool error = false.obs;

//   RxList<ProductModel> products = [].obs;

//   static const categories = [
//     'Drinkware',
//     'Apparel',
//     'Work Essentials',
//     'Wellness',
//   ];

//   Future<void> loadProducts() async {
//     loading.value = true;
//     error.value = false;
//     try {
//       final products = await _repository.fetchProducts();

//       loading.value = false;
//       error.value = false;
//     } catch (e, stackTree) {
//       log("Error load products $e, $stackTree");
//       loading.value = false;
//       error.value = true;
//     } finally {
//       loading.value = false;
//     }
//   }
// }
