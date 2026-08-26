import 'package:thawani_models/thawani_models.dart';

import '../../domain/episodes_snapshot.dart';
import 'episode_memory_cache.dart';

/// Mutable progress for one [EpisodeRepositoryImpl.watchEpisodes] run.
///
/// Seeded from [EpisodeMemoryCache] so cache hits appear in the first snapshot
/// without a network round-trip. Updated as chunks complete; converted to
/// immutable [EpisodesSnapshot]s via [toSnapshot].
class EpisodeWatchState {
  EpisodeWatchState({
    required List<int> uniqueIds,
    required EpisodeMemoryCache cache,
  }) : uniqueIds = List<int>.unmodifiable(uniqueIds),
       arrived = <int, Episode>{
         for (final int id in uniqueIds) id: ?cache.get(id),
       };

  /// Requested ids in first-seen order (after repository dedupe).
  final List<int> uniqueIds;

  /// Episodes resolved so far, keyed by id (includes cache hits at construction).
  final Map<int, Episode> arrived;

  /// Ids that could not be fetched (offline or chunk failure).
  final Set<int> failed = <int>{};

  /// HTTP batch calls made during this watch (one per multi-id fetch).
  int httpCalls = 0;

  /// Builds an immutable snapshot for stream subscribers.
  ///
  /// [EpisodesSnapshot.episodes] lists only ids that have arrived, in
  /// [uniqueIds] order — missing ids are skipped, not emitted as nulls.
  EpisodesSnapshot toSnapshot({required bool inFlight}) {
    return EpisodesSnapshot(
      episodes: [for (final int id in uniqueIds) ?arrived[id]],
      failedIds: Set<int>.unmodifiable(Set<int>.of(failed)),
      inFlight: inFlight,
      httpCalls: httpCalls,
    );
  }
}
