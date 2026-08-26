import 'package:thawani_models/thawani_models.dart';

class EpisodeMemoryCache {
  final _byId = <int, Episode>{};

  Episode? get(int id) => _byId[id];

  void putAll(Iterable<Episode> episodes) {
    for (final episode in episodes) {
      _byId[episode.id] = episode;
    }
  }

  void clear() => _byId.clear();
}
