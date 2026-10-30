import 'package:supabase_flutter/supabase_flutter.dart';

class ProductServices {
  ProductServices({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final rows = await _client.from('products').select().order('sort_order');

    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  Future<void> saveProduct({
    String? id,
    required String name,
    required String category,
    required int minPrice,
    required int maxPrice,
    required String description,
    required String imageUrl,
    required List<String> occasions,
    required List<String> customisations,
    required bool isActive,
  }) async {
    final slug = name
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');

    final data = <String, dynamic>{
      'name': name.trim(),
      'slug': slug,
      'category': category,
      'min_price': minPrice,
      'max_price': maxPrice,
      'description': description.trim(),
      'image_url': imageUrl.trim().isEmpty ? null : imageUrl.trim(),
      'occasions': occasions,
      'customisations': customisations,
      'is_active': isActive,
    };

    if (id == null) {
      await _client.from('products').insert(data);
    } else {
      await _client.from('products').update(data).eq('id', id);
    }
  }

  Future<void> setActive({required String id, required bool isActive}) async {
    await _client.from('products').update({'is_active': isActive}).eq('id', id);
  }
}
