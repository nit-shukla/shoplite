import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shoplite/data/repositories/cart_repository.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:hive/hive.dart';

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

// Mock Hive Box for Cart
class MockCartBox extends Mock implements Box<Map<String, dynamic>> {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = MockPathProviderPlatform();

  group('CartRepository', () {
    late CartRepository cartRepository;
    late MockCartBox mockCartBox;

    setUp(() async {
      mockCartBox = MockCartBox();
      when(Hive.openBox<Map<String, dynamic>>('cartBox'))
          .thenAnswer((_) async => mockCartBox);
      cartRepository = CartRepository();
    });

    tearDown(() async {
      // No need to delete from disk for mocked Hive
    });

    test('CartRepository saves and loads items', () async {
      final testCart = {
        '1': {
          'product': {'id': 1, 'price': 10},
          'qty': 2
        }
      };
      // Move when calls inside the test block
      when(mockCartBox.get('cart')).thenReturn(testCart);
      when(mockCartBox.put('cart', testCart)).thenAnswer((_) async => {});

      await cartRepository.saveCart(testCart);
      final retrievedCart = await cartRepository.getCart();
      expect(retrievedCart['1']['qty'], 2);
    });
  });
}
