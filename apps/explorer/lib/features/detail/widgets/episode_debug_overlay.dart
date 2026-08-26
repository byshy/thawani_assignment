import 'package:flutter/material.dart';
import 'package:thawani_ui/thawani_ui.dart';

class EpisodeDebugOverlay extends StatelessWidget {
  const EpisodeDebugOverlay({super.key, required this.httpCalls});

  final int httpCalls;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ThawaniSpacing.md,
        ThawaniSpacing.sm,
        ThawaniSpacing.md,
        0,
      ),
      child: Text(
        'episode HTTP calls this screen: $httpCalls',
        key: const Key('episode-http-calls'),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
