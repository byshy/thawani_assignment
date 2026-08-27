import 'package:explorer/core/state/network_state.dart';
import 'package:explorer/widgets/network_offline_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:thawani_ui/thawani_ui.dart';

import '../support/fakes.dart';

void main() {
  Future<void> pumpBanner(
    WidgetTester tester, {
    required FakeNetwork network,
    required DateTime fetchedAt,
  }) {
    return tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: network.provider,
        child: MaterialApp(
          home: Scaffold(body: NetworkOfflineBanner(fetchedAt: fetchedAt)),
        ),
      ),
    );
  }

  testWidgets('hides while online even if data is stale', (tester) async {
    final network = FakeNetwork();
    addTearDown(network.dispose);

    await pumpBanner(
      tester,
      network: network,
      fetchedAt: DateTime.now().subtract(const Duration(minutes: 12)),
    );

    expect(find.byType(OfflineBanner), findsNothing);
  });

  testWidgets('hides while connectivity is still unknown', (tester) async {
    final network = FakeNetwork(initialStatus: NetworkStatus.unknown);
    addTearDown(network.dispose);

    await pumpBanner(tester, network: network, fetchedAt: DateTime.now());

    expect(find.byType(OfflineBanner), findsNothing);
  });

  testWidgets('shows when the network drops even if data is fresh', (
    tester,
  ) async {
    final network = FakeNetwork();
    addTearDown(network.dispose);

    await pumpBanner(
      tester,
      network: network,
      fetchedAt: DateTime.now().subtract(const Duration(minutes: 3)),
    );

    network.emit(false);
    await tester.pump();

    expect(find.byType(OfflineBanner), findsOneWidget);
    expect(find.textContaining('Offline'), findsOneWidget);
  });
}
