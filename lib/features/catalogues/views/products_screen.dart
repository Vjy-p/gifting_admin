// import 'package:flutter/material.dart';
// import 'package:gifting_admin/features/products/services/product_services.dart';

// class AdminProductsView extends StatefulWidget {
//   const AdminProductsView({super.key});

//   @override
//   State<AdminProductsView> createState() => _AdminProductsViewState();
// }

// class _AdminProductsViewState extends State<AdminProductsView> {

//   @override
//   void initState() {
//     super.initState();
//   }

//   Future<void> _editProduct([Map<String, dynamic>? product]) async {

//     try {
//       await showDialog<void>(
//         context: context,
//         builder: (dialogContext) => StatefulBuilder(
//           builder: (context, setDialogState) => AlertDialog(
//             title: Text(product == null ? 'Add product' : 'Edit product'),
//             content: SizedBox(
//               width: 460,
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       controller: name,
//                       decoration: const InputDecoration(labelText: 'Name'),
//                     ),
//                     const SizedBox(height: 12),
//                     DropdownButtonFormField<String>(
//                       initialValue: category,
//                       decoration: const InputDecoration(labelText: 'Category'),
//                       items: _categories
//                           .map(
//                             (c) => DropdownMenuItem(value: c, child: Text(c)),
//                           )
//                           .toList(),
//                       onChanged: (value) {
//                         if (value != null) {
//                           setDialogState(() => category = value);
//                         }
//                       },
//                     ),
//                     const SizedBox(height: 12),
//                     TextField(
//                       controller: minPrice,
//                       keyboardType: TextInputType.number,
//                       decoration: const InputDecoration(
//                         labelText: 'Minimum price (₹)',
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     TextField(
//                       controller: maxPrice,
//                       keyboardType: TextInputType.number,
//                       decoration: const InputDecoration(
//                         labelText: 'Maximum price (₹)',
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     TextField(
//                       controller: description,
//                       maxLines: 3,
//                       decoration: const InputDecoration(
//                         labelText: 'Description',
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     TextField(
//                       controller: imageUrl,
//                       decoration: const InputDecoration(labelText: 'Image URL'),
//                     ),
//                     SwitchListTile(
//                       contentPadding: EdgeInsets.zero,
//                       title: const Text('Active in catalogue'),
//                       value: isActive,
//                       onChanged: (value) {
//                         setDialogState(() => isActive = value);
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: saving ? null : () => Navigator.pop(dialogContext),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: saving
//                     ? null
//                     : () async {
//                         final low = int.tryParse(minPrice.text.trim());
//                         final high = int.tryParse(maxPrice.text.trim());

//                         if (name.text.trim().isEmpty ||
//                             low == null ||
//                             high == null ||
//                             low < 0 ||
//                             high < low) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('Check the name and price range.'),
//                             ),
//                           );
//                           return;
//                         }

//                         setDialogState(() => saving = true);

//                         try {
//                           await _repository.saveProduct(
//                             id: product?['id'] as String?,
//                             name: name.text,
//                             category: category,
//                             minPrice: low,
//                             maxPrice: high,
//                             description: description.text,
//                             imageUrl: imageUrl.text,
//                             occasions: List<String>.from(
//                               product?['occasions'] ?? const [],
//                             ),
//                             customisations: List<String>.from(
//                               product?['customisations'] ?? const [],
//                             ),
//                             isActive: isActive,
//                           );

//                           if (dialogContext.mounted) {
//                             Navigator.pop(dialogContext);
//                           }

//                           await _loadProducts();
//                         } catch (_) {
//                           if (context.mounted) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text(
//                                   'Could not save product. Check for a duplicate name or slug.',
//                                 ),
//                               ),
//                             );
//                           }
//                         } finally {
//                           if (dialogContext.mounted) {
//                             setDialogState(() => saving = false);
//                           }
//                         }
//                       },
//                 child: Text(saving ? 'Saving...' : 'Save'),
//               ),
//             ],
//           ),
//         ),
//       );
//     } finally {
//       name.dispose();
//       minPrice.dispose();
//       maxPrice.dispose();
//       description.dispose();
//       imageUrl.dispose();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Manage Products'),
//         actions: [
//           IconButton(onPressed: _loadProducts, icon: const Icon(Icons.refresh)),
//           Padding(
//             padding: const EdgeInsets.only(right: 12),
//             child: FilledButton.icon(
//               onPressed: () => _editProduct(),
//               icon: const Icon(Icons.add),
//               label: const Text('Add product'),
//             ),
//           ),
//         ],
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : _error != null
//           ? Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(_error!),
//                   const SizedBox(height: 12),
//                   ElevatedButton(
//                     onPressed: _loadProducts,
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             )
//           : ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: _products.length,
//               itemBuilder: (context, index) {
//                 final product = _products[index];
//                 final active = product['is_active'] as bool? ?? false;
//                 final url = product['image_url'] as String?;

//                 return Card(
//                   child: ListTile(
//                     leading: SizedBox(
//                       width: 56,
//                       height: 56,
//                       child: url != null && url.isNotEmpty
//                           ? Image.network(
//                               url,
//                               fit: BoxFit.cover,
//                               errorBuilder: (_, _, _) =>
//                                   const Icon(Icons.image_not_supported),
//                             )
//                           : const Icon(Icons.card_giftcard),
//                     ),
//                     title: Text(product['name'] as String? ?? ''),
//                     subtitle: Text(
//                       '${product['category']} • ₹${product['min_price']}–₹${product['max_price']} • ${active ? 'Active' : 'Inactive'}',
//                     ),
//                     trailing: IconButton(
//                       tooltip: 'Edit product',
//                       icon: const Icon(Icons.edit_outlined),
//                       onPressed: () => _editProduct(product),
//                     ),
//                     onLongPress: () async {
//                       try {
//                         await _repository.setActive(
//                           id: product['id'] as String,
//                           isActive: !active,
//                         );
//                         await _loadProducts();
//                       } catch (_) {
//                         if (mounted) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('Could not update product.'),
//                             ),
//                           );
//                         }
//                       }
//                     },
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
