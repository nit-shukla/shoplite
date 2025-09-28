// lib/data/repositories/favorites_repository.dart
import 'package:hive_flutter/hive_flutter.dart';

class FavoritesRepository {
  static const _boxName = 'shoplite_favorites';
  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  List<int> getFavorites() {
    final raw = _box.get('favorites', defaultValue: <int>[]);
    if (raw is List) {
      return raw.cast<int>();
    }
    return <int>[];
  }

  Future<void> toggleFavorite(int productId) async {
    final favorites = getFavorites();
    if (favorites.contains(productId)) {
      favorites.remove(productId);
    } else {
      favorites.add(productId);
    }
    await _box.put('favorites', favorites);
  }

  bool isFavorite(int productId) {
    return getFavorites().contains(productId);
  }
}
