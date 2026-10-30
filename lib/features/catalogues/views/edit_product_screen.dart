// import 'package:flutter/material.dart';

// class EditProductScreen extends StatefulWidget {
//   const new({super.key});

//   @override
//   State<EditProductScreen> createState() => _EditProductScreenState();
// }

// class _EditProductScreenState extends State<EditProductScreen> {
//   final name = TextEditingController(text: product?['name'] ?? '');
//   final minPrice = TextEditingController(
//     text: product?['min_price']?.toString() ?? '',
//   );
//   final maxPrice = TextEditingController(
//     text: product?['max_price']?.toString() ?? '',
//   );
//   final description = TextEditingController(
//     text: product?['description'] ?? '',
//   );
//   final imageUrl = TextEditingController(text: product?['image_url'] ?? '');

//   String category = product?['category'] ?? _categories.first;
//   bool isActive = product?['is_active'] as bool? ?? true;
//   bool saving = false;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 460,
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: name,
//               decoration: const InputDecoration(labelText: 'Name'),
//             ),
//             const SizedBox(height: 12),
//             DropdownButtonFormField<String>(
//               initialValue: category,
//               decoration: const InputDecoration(labelText: 'Category'),
//               items: _categories
//                   .map((c) => DropdownMenuItem(value: c, child: Text(c)))
//                   .toList(),
//               onChanged: (value) {
//                 if (value != null) {
//                   setDialogState(() => category = value);
//                 }
//               },
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: minPrice,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(labelText: 'Minimum price (₹)'),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: maxPrice,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(labelText: 'Maximum price (₹)'),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: description,
//               maxLines: 3,
//               decoration: const InputDecoration(labelText: 'Description'),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: imageUrl,
//               decoration: const InputDecoration(labelText: 'Image URL'),
//             ),
//             SwitchListTile(
//               contentPadding: EdgeInsets.zero,
//               title: const Text('Active in catalogue'),
//               value: isActive,
//               onChanged: (value) {
//                 setDialogState(() => isActive = value);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
