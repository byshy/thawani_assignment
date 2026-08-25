import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thawani_ui/thawani_ui.dart';

void main() {
  group('happy path', () {
    testWidgets('ErrorState retry invokes callback', (tester) async {
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

    testWidgets('FavouriteButton reports presses', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FavouriteButton(
              isFavourite: false,
              onPressed: () => taps++,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FavouriteButton));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('Debouncer runs only the last action after delay', (tester) async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 400));
      final calls = <String>[];

      debouncer.run(() => calls.add('a'));
      await tester.pump(const Duration(milliseconds: 100));
      debouncer.run(() => calls.add('b'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(calls, ['b']);
      debouncer.dispose();
    });
  });

  group('edge cases', () {
    testWidgets('EmptyState.forQuery names the search term', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: EmptyState.forQuery('morty')),
        ),
      );

      expect(find.textContaining('"morty"'), findsOneWidget);
    });

    testWidgets('OfflineBanner includes relative age', (tester) async {
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
  });
}
