import 'dart:developer';

import 'package:gifting_admin/features/catalogues/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductServices {
  ProductServices({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<ProductModel>> fetchProducts({
    int page = 0,
    int limit = 8,
    String search = '',
    String category = 'All Gifts',
    int? minPrice,
    int? maxPrice,
    List<String> occasions = const [],
    List<String> customisations = const [],
  }) async {
    try {
      final from = page * limit;
      final to = from + limit - 1;

      var query = _client.from('products').select().eq('is_active', true);

      if (category != 'All Gifts') {
        query = query.eq('category', category);
      }

      if (search.trim().isNotEmpty) {
        query = query.ilike('name', '%${search.trim()}%');
      }

      // Price ranges must overlap the selected price range.
      if (minPrice != null) {
        query = query.gte('max_price', minPrice);
      }

      if (maxPrice != null) {
        query = query.lte('min_price', maxPrice);
      }

      // Match at least one selected occasion.
      if (occasions.isNotEmpty) {
        query = query.overlaps('occasions', occasions);
      }

      // Match at least one selected customisation.
      if (customisations.isNotEmpty) {
        query = query.overlaps('customisations', customisations);
      }

      final response = await query.order('sort_order').range(from, to);

      return response.map((json) => ProductModel.fromJson(json)).toList();
    } on PostgrestException catch (error, stackTrace) {
      log('Supabase product query error: ${error.message}, $stackTrace');
      log('Code: ${error.code}');
      rethrow;
    } catch (error, stackTrace) {
      log('Unexpected product query error: $error, $stackTrace');

      rethrow;
    }
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
    try {
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
    } on PostgrestException catch (error, stackTrace) {
      log('Supabase save product error: ${error.message}, $stackTrace');
      log('Code: ${error.code}');
      rethrow;
    } catch (error, stackTrace) {
      log('Unexpected save product error: $error, $stackTrace');

      rethrow;
    }
  }

  Future<void> setActive({required String id, required bool isActive}) async {
    try {
      await _client
          .from('products')
          .update({'is_active': isActive})
          .eq('id', id);
    } on PostgrestException catch (error, stackTrace) {
      log('Supabase set actvive product error: ${error.message}, $stackTrace');
      log('Code: ${error.code}');
      rethrow;
    } catch (error, stackTrace) {
      log('Unexpected set active product error: $error, $stackTrace');

      rethrow;
    }
  }
}
