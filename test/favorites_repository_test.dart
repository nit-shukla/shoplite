import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shoplite/data/repositories/favorite_repository.dart';

void main() {
  test('FavoritesRepository toggles favorites', () async {
    await Hive.initFlutter();
    final repo = FavoritesRepository();
    await repo.init();
    final before = repo.getFavorites();
    await repo.toggleFavorite(1);
    final after = repo.getFavorites();
    expect(
        after.length == before.length + 1 ||
            after.length == (before.length - 1),
        true);
  });
}
