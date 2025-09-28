import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class CartRepository {
  static const _boxName = 'shoplite_cart';

  Future<Box> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<Map<String, dynamic>> getCart() async {
    final box = await _openBox();
    final raw = box.get('items');
    if (raw == null) return {};
    if (raw is String) {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return {};
      }
      return Map<String, dynamic>.from(decoded as Map);
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw as Map);
    }
    return {};
  }

  Future<void> saveCart(Map<String, dynamic> cart) async {
    final box = await _openBox();
    await box.put('items', jsonEncode(cart));
  }

  Future<void> clearCart() async {
    final box = await _openBox();
    await box.delete('items');
  }
}
