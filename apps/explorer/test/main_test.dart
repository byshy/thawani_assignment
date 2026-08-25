import 'package:explorer/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the scaffold placeholder', (tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('Hello World!'), findsOneWidget);
  });
}
