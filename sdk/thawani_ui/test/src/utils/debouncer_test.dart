import 'package:flutter_test/flutter_test.dart';
import 'package:thawani_ui/thawani_ui.dart';

void main() {
  testWidgets('runs only the last action after delay', (tester) async {
    final debouncer = Debouncer(delay: const Duration(milliseconds: 400));
    final calls = <String>[];

    debouncer.run(() => calls.add('a'));
    await tester.pump(const Duration(milliseconds: 100));
    debouncer.run(() => calls.add('b'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(calls, ['b']);
    debouncer.dispose();
  });
}
