import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shoplite/data/repositories/auth_repository.dart';

import 'auth_repository_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthRepository', () {
    late AuthRepository authRepository;
    late MockFlutterSecureStorage mockFlutterSecureStorage;

    setUp(() {
      mockFlutterSecureStorage = MockFlutterSecureStorage();
      authRepository = AuthRepository(storage: mockFlutterSecureStorage);
    });

    test('AuthRepository stores and reads token roundtrip', () async {
      const testToken = 'test_token';
      when(mockFlutterSecureStorage.read(key: 'auth_token'))
          .thenAnswer((_) async => testToken);
      when(mockFlutterSecureStorage.write(key: 'auth_token', value: testToken))
          .thenAnswer((_) async => {});
      when(mockFlutterSecureStorage.delete(key: 'auth_token'))
          .thenAnswer((_) async => {});

      await authRepository.saveToken(testToken);
      expect(await authRepository.getToken(), testToken);
      expect(await authRepository.isLoggedIn(), true);

      await authRepository.logout();
      when(mockFlutterSecureStorage.read(key: 'auth_token'))
          .thenAnswer((_) async => null);
      expect(await authRepository.isLoggedIn(), false);
    });
  });
}
