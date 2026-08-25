import 'package:explorer/routing/screens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('names the shell and character detail routes', () {
    expect(Screens.shell, '/');
    expect(Screens.characterDetail, '/character');
  });
}
