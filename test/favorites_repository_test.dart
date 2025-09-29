import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shoplite/data/repositories/favorite_repository.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:hive/hive.dart';

// Mock PathProviderPlatform
class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp'; // Return a temporary path for testing
  }

  @override
  Future<String?> getApplicationSupportPath() async => '';

  @override
  Future<String?> getTemporaryPath() async => '';

  @override
  Future<String?> getLibraryPath() async => '';

  @override
  Future<String?> getExternalStoragePath() async => '';

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async =>
      <String>[];

  @override
  Future<String?> getDownloadsPath() async => '';

  @override
  Future<String?> getApplicationCachePath() async => '';

  @override
  Future<List<String>?> getExternalCachePaths({
    StorageDirectory? type,
  }) async =>
      <String>[];
}

// Mock Hive Box
class MockBox<T> extends Mock implements Box<T> {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = MockPathProviderPlatform();

  group('FavoritesRepository', () {
    late FavoritesRepository favoritesRepository;
    late MockBox<int> mockFavoritesBox;

    setUp(() async {
      // Initialize Hive for testing, using a temporary path
      await Hive.initFlutter();
      mockFavoritesBox = MockBox<int>();
      when(Hive.openBox<int>('favoritesBox'))
          .thenAnswer((_) async => mockFavoritesBox);
      favoritesRepository = FavoritesRepository();
      await favoritesRepository.init();
    });

    tearDown(() async {
      await Hive.deleteFromDisk(); // Clean up Hive data after tests
    });

    test('FavoritesRepository toggles favorites - add', () async {
      when(mockFavoritesBox.containsKey(1)).thenReturn(false);
      when(mockFavoritesBox.add(1)).thenAnswer((_) async => 0);
      when(mockFavoritesBox.values).thenReturn([]);
      when(mockFavoritesBox.delete(any)).thenAnswer((_) async => {});

      final before = favoritesRepository.getFavorites();
      expect(before, isEmpty);

      await favoritesRepository.toggleFavorite(1);

      when(mockFavoritesBox.values).thenReturn([1]); // Simulate adding
      final after = favoritesRepository.getFavorites();
      expect(after, contains(1));
      expect(after.length, equals(1));
    });

    test('FavoritesRepository toggles favorites - remove', () async {
      when(mockFavoritesBox.containsKey(1)).thenReturn(true);
      when(mockFavoritesBox.delete(1)).thenAnswer((_) async => {});
      when(mockFavoritesBox.values).thenReturn([1]);

      // Simulate initial state with an item
      when(mockFavoritesBox.values).thenReturn([1]);
      final before = favoritesRepository.getFavorites();
      expect(before, contains(1));

      await favoritesRepository.toggleFavorite(1);

      when(mockFavoritesBox.values).thenReturn([]); // Simulate removing
      final after = favoritesRepository.getFavorites();
      expect(after, isEmpty);
    });
  });
}
