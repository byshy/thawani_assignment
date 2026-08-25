import 'dart:async';

import 'package:explorer/core/state/network_provider.dart';
import 'package:explorer/core/state/network_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seeds the current status then follows stream updates', () async {
    final statuses = StreamController<bool>.broadcast(sync: true);
    final seed = Completer<bool>();
    final provider = NetworkProvider(
      onStatusChanged: statuses.stream,
      currentStatus: seed.future,
    );

    expect(provider.state.status, NetworkStatus.unknown);

    seed.complete(true);
    await seed.future;
    await Future<void>.delayed(Duration.zero);
    expect(provider.state.isOnline, isTrue);

    statuses.add(false);
    expect(provider.state.isOffline, isTrue);

    statuses.add(true);
    expect(provider.state.isOnline, isTrue);

    provider.dispose();
    await statuses.close();
  });

  test('does not notify when the status is unchanged', () async {
    final statuses = StreamController<bool>.broadcast(sync: true);
    final provider = NetworkProvider(
      onStatusChanged: statuses.stream,
      initialStatus: NetworkStatus.online,
    );

    var notifications = 0;
    provider.addListener(() => notifications++);

    statuses.add(true);
    expect(notifications, 0);

    statuses.add(false);
    expect(notifications, 1);
    expect(provider.state.isOffline, isTrue);

    provider.dispose();
    await statuses.close();
  });

  test('ignores a late seed after dispose', () async {
    final seed = Completer<bool>();
    final provider = NetworkProvider(
      onStatusChanged: const Stream.empty(),
      currentStatus: seed.future,
    );

    provider.dispose();
    seed.complete(false);
    await seed.future;
    await Future<void>.delayed(Duration.zero);

    expect(provider.state.status, NetworkStatus.unknown);
  });
}
