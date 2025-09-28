// lib/data/repositories/product_repository.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_model.dart';

class ProductRepository {
  final Dio _dio;
  final Duration ttl;
  static const _catalogBoxName = 'shoplite_catalog';
  static const _productBoxName = 'shoplite_product';

  ProductRepository({Dio? dio, this.ttl = const Duration(minutes: 30)})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://dummyjson.com'));

  Future<Box> _openCatalogBox() async {
    if (!Hive.isBoxOpen(_catalogBoxName)) {
      return await Hive.openBox(_catalogBoxName);
    }
    return Hive.box(_catalogBoxName);
  }

  Future<Box> _openProductBox() async {
    if (!Hive.isBoxOpen(_productBoxName)) {
      return await Hive.openBox(_productBoxName);
    }
    return Hive.box(_productBoxName);
  }

  String _pageKey(int skip, int limit, String? query, String? category) {
    return 'p_${skip}_${limit}_${query ?? ''}_${category ?? ''}';
  }

  Future<List<ProductModel>> fetchProducts(
      {int limit = 20, int skip = 0, String? query, String? category}) async {
    final box = await _openCatalogBox();
    final key = _pageKey(skip, limit, query, category);

    try {
      Response resp;
      if (query != null && query.isNotEmpty) {
        resp =
            await _dio.get('/products/search', queryParameters: {'q': query});
      } else if (category != null && category.isNotEmpty) {
        resp = await _dio.get('/products/category/$category',
            queryParameters: {'limit': limit, 'skip': skip});
      } else {
        resp = await _dio
            .get('/products', queryParameters: {'limit': limit, 'skip': skip});
      }
      final productsList = resp.data['products'];
      if (productsList is! List) {
        throw Exception('Invalid response format');
      }
      final productsJson = productsList
          .cast<dynamic>()
          .map((e) => e as Map<String, dynamic>)
          .toList();
      await box.put(
          key,
          jsonEncode(
              {'ts': DateTime.now().toIso8601String(), 'data': productsJson}));
      return productsJson.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      final cached = box.get(key);
      if (cached != null) {
        Map<String, dynamic> m;
        if (cached is String) {
          m = Map<String, dynamic>.from(jsonDecode(cached) as Map);
        } else if (cached is Map) {
          m = Map<String, dynamic>.from(cached as Map);
        } else {
          rethrow;
        }

        // Check for cache staleness
        final cachedTimestamp = DateTime.parse(m['ts'] as String);
        if (DateTime.now().difference(cachedTimestamp) > ttl) {
          await box.delete(key); // Invalidate stale cache
          rethrow; // Treat as if no cache was found
        }

        final dataList = m['data'];
        if (dataList is! List) {
          rethrow;
        }
        final data = dataList
            .cast<dynamic>()
            .map((e) => e as Map<String, dynamic>)
            .toList();
        return data.map((e) => ProductModel.fromJson(e)).toList();
      }
      rethrow;
    }
  }

  Future<ProductModel> fetchProductById(int id) async {
    final box = await _openProductBox();
    final key = 'product_$id';
    try {
      final resp = await _dio.get('/products/$id');
      final json = resp.data as Map<String, dynamic>;
      await box.put(key,
          jsonEncode({'ts': DateTime.now().toIso8601String(), 'data': json}));
      return ProductModel.fromJson(json);
    } catch (e) {
      final cached = box.get(key);
      if (cached != null) {
        Map<String, dynamic> m;
        if (cached is String) {
          m = Map<String, dynamic>.from(jsonDecode(cached) as Map);
        } else if (cached is Map) {
          m = Map<String, dynamic>.from(cached as Map);
        } else {
          rethrow;
        }

        // Check for cache staleness
        final cachedTimestamp = DateTime.parse(m['ts'] as String);
        if (DateTime.now().difference(cachedTimestamp) > ttl) {
          await box.delete(key); // Invalidate stale cache
          rethrow; // Treat as if no cache was found
        }

        final productData = m['data'];
        if (productData is! Map) {
          rethrow;
        }
        return ProductModel.fromJson(
            Map<String, dynamic>.from(productData as Map));
      }
      rethrow;
    }
  }

  Future<List<String>> fetchCategories() async {
    final resp = await _dio.get('/products/categories');
    final data = resp.data;
    if (data is! List) {
      throw Exception('Invalid categories response format');
    }
    return data.cast<String>();
  }
}
