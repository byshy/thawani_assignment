import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thawani_ui/thawani_ui.dart';

void main() {
  testWidgets('includes relative age', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OfflineBanner(
            fetchedAt: DateTime.now().subtract(const Duration(minutes: 12)),
          ),
        ),
      ),
    );

    expect(find.textContaining('Offline'), findsOneWidget);
    expect(find.textContaining('12 minutes ago'), findsOneWidget);
  });
}
