import 'package:thawani_models/thawani_models.dart';

class EpisodesSnapshot {
  const EpisodesSnapshot({
    required this.episodes,
    this.failedIds = const {},
    this.inFlight = false,
    this.httpCalls = 0,
  });

  final List<Episode> episodes;
  final Set<int> failedIds;
  final bool inFlight;
  final int httpCalls;
}
