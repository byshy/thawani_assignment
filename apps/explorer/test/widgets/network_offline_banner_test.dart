import 'package:explorer/widgets/network_offline_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:thawani_ui/thawani_ui.dart';

import '../support/fakes.dart';

void main() {
  testWidgets('hides while online with fresh data', (tester) async {
    final network = FakeNetwork();
    addTearDown(network.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: network.provider,
        child: MaterialApp(
          home: Scaffold(
            body: NetworkOfflineBanner(
              fromCache: false,
              fetchedAt: DateTime.now(),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(OfflineBanner), findsNothing);
  });

  testWidgets('shows when the network drops even if data is fresh', (
    tester,
  ) async {
    final network = FakeNetwork();
    addTearDown(network.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: network.provider,
        child: MaterialApp(
          home: Scaffold(
            body: NetworkOfflineBanner(
              fromCache: false,
              fetchedAt: DateTime.now().subtract(const Duration(minutes: 3)),
            ),
          ),
        ),
      ),
    );

    network.emit(false);
    await tester.pump();

    expect(find.byType(OfflineBanner), findsOneWidget);
    expect(find.textContaining('Offline'), findsOneWidget);
  });

  testWidgets('shows cached data while still marked online', (tester) async {
    final network = FakeNetwork();
    addTearDown(network.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: network.provider,
        child: MaterialApp(
          home: Scaffold(
            body: NetworkOfflineBanner(
              fromCache: true,
              fetchedAt: DateTime.now().subtract(const Duration(minutes: 12)),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(OfflineBanner), findsOneWidget);
    expect(find.textContaining('12 minutes ago'), findsOneWidget);
  });
}
