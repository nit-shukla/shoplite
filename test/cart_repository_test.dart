import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shoplite/data/repositories/cart_repository.dart';

void main() {
  test('CartRepository saves and loads items', () async {
    await Hive.initFlutter();
    final repo = CartRepository();
    await repo.saveCart({
      '1': {
        'product': {'id': 1, 'price': 10},
        'qty': 2
      }
    });
    final m = await repo.getCart();
    expect(m['1']['qty'], 2);
  });
}
