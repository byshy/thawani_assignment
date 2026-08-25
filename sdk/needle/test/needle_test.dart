import 'package:flutter_test/flutter_test.dart';
import 'package:needle/needle.dart';

void main() {
  tearDown(() async {
    await sl.reset();
  });

  test('sl is the GetIt singleton', () {
    expect(sl, same(GetIt.instance));
  });

  test('registers and resolves through sl', () {
    sl.registerSingleton<String>('needle');
    expect(sl<String>(), 'needle');
  });
}
