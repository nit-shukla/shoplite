import 'package:flutter_test/flutter_test.dart';
import 'package:shoplite/data/repositories/product_repository.dart';

void main() {
  test('ProductRepository fetchCategories returns a list', () async {
    final repo = ProductRepository();
    final cats = await repo.fetchCategories();
    expect(cats, isA<List<String>>());
  });
}
