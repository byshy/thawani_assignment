import 'package:thawani_models/thawani_models.dart';

import '../../domain/episodes_snapshot.dart';
import 'episode_memory_cache.dart';

/// Mutable progress for one episode watch/collection run.
class EpisodeWatchState {
  EpisodeWatchState({
    required List<int> uniqueIds,
    required EpisodeMemoryCache cache,
  }) : uniqueIds = List<int>.unmodifiable(uniqueIds),
       arrived = <int, Episode>{
         for (final int id in uniqueIds) id: ?cache.get(id),
       };

  final List<int> uniqueIds;
  final Map<int, Episode> arrived;
  final Set<int> failed = <int>{};
  int httpCalls = 0;

  EpisodesSnapshot toSnapshot({required bool inFlight}) {
    return EpisodesSnapshot(
      episodes: [for (final int id in uniqueIds) ?arrived[id]],
      failedIds: Set<int>.unmodifiable(Set<int>.of(failed)),
      inFlight: inFlight,
      httpCalls: httpCalls,
    );
  }
}
