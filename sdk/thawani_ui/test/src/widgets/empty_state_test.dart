import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thawani_ui/thawani_ui.dart';

void main() {
  testWidgets('forQuery names the search term', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: EmptyState.forQuery('morty')),
      ),
    );

    expect(find.textContaining('"morty"'), findsOneWidget);
  });
}
