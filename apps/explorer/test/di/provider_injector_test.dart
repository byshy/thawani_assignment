import 'package:explorer/di/provider_injector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registerProviders is a no-op until Phase 3', () {
    expect(registerProviders, returnsNormally);
  });
}
