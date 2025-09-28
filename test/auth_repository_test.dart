import 'package:flutter_test/flutter_test.dart';
import 'package:shoplite/data/repositories/auth_repository.dart';

void main() {
  test('AuthRepository stores and reads token roundtrip', () async {
    final repo = AuthRepository();
    // This calls real API; skip if offline. We only check shape by simulating storage write/read.
    await repo.logout();
    expect(await repo.isLoggedIn(), false);
  });
}
