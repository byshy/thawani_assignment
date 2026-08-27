import 'package:thawani_models/thawani_models.dart';

/// In-memory `id → Episode` store for the episode fan-out bonus.
///
/// Shared by [EpisodeRepositoryImpl] across character-detail opens so a second
/// character who overlaps episodes does not repeat HTTP for warm ids.
///
/// Does **not** survive process restart — disk persistence would be a separate
/// adapter behind the same repository API.
class EpisodeMemoryCache {
  final Map<int, Episode> _byId = <int, Episode>{};

  /// Returns a cached episode, or `null` if this id has not been fetched yet.
  Episode? get(int id) => _byId[id];

  /// Inserts or replaces episodes by [Episode.id].
  void putAll(Iterable<Episode> episodes) {
    for (final Episode episode in episodes) {
      _byId[episode.id] = episode;
    }
  }

  /// Clears all entries (mainly for tests).
  void clear() => _byId.clear();
}
