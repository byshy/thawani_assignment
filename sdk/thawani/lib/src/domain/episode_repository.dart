import 'package:networking/networking.dart';

import 'episodes_snapshot.dart';

abstract interface class EpisodeRepository {
  /// Emits cache hits first, then accumulated successes as chunks complete.
  Stream<EpisodesSnapshot> watchEpisodes(
    List<int> ids, {
    CancelToken? cancelToken,
  });
}
