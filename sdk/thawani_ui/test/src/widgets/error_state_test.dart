import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thawani_ui/thawani_ui.dart';

void main() {
  testWidgets('retry invokes callback', (tester) async {
    var retries = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorState(
            message: 'Something went wrong',
            onRetry: () => retries++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(retries, 1);
  });
}
