import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thawani_ui/thawani_ui.dart';

import '../core/state/network_provider.dart';

/// Shows [OfflineBanner] only while [NetworkProvider] reports offline.
class NetworkOfflineBanner extends StatelessWidget {
  const NetworkOfflineBanner({super.key, this.fetchedAt});

  final DateTime? fetchedAt;

  @override
  Widget build(BuildContext context) {
    final network = context.watch<NetworkProvider>();
    final fetchedAt = this.fetchedAt;
    if (fetchedAt == null || !network.state.isOffline) {
      return const SizedBox.shrink();
    }
    return OfflineBanner(fetchedAt: fetchedAt);
  }
}
