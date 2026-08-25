import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thawani_ui/thawani_ui.dart';

import '../core/state/network_provider.dart';

/// Shows [OfflineBanner] when the device is offline or the data is cached.
class NetworkOfflineBanner extends StatelessWidget {
  const NetworkOfflineBanner({
    super.key,
    required this.fromCache,
    this.fetchedAt,
  });

  final bool fromCache;
  final DateTime? fetchedAt;

  @override
  Widget build(BuildContext context) {
    final network = context.watch<NetworkProvider>();
    final fetchedAt = this.fetchedAt;
    if (fetchedAt == null) {
      return const SizedBox.shrink();
    }
    if (!network.state.isOffline && !fromCache) {
      return const SizedBox.shrink();
    }
    return OfflineBanner(fetchedAt: fetchedAt);
  }
}
