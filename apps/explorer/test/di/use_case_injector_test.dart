import 'package:explorer/di/use_case_injector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registerUseCases is a no-op until Phase 3', () {
    expect(registerUseCases, returnsNormally);
  });
}
