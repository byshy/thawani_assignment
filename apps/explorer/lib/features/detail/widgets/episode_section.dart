import 'package:flutter/material.dart';
import 'package:thawani_models/thawani_models.dart';
import 'package:thawani_ui/thawani_ui.dart';

import 'episode_debug_overlay.dart';

class EpisodeSection extends StatelessWidget {
  const EpisodeSection({
    super.key,
    required this.episodes,
    required this.loading,
    required this.failedCount,
    required this.httpCalls,
    this.errorMessage,
    this.onRetryMissing,
  });

  final List<Episode> episodes;
  final bool loading;
  final int failedCount;
  final int httpCalls;
  final String? errorMessage;
  final VoidCallback? onRetryMissing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            ThawaniSpacing.md,
            ThawaniSpacing.md,
            ThawaniSpacing.md,
            0,
          ),
          child: Text('Appearances', style: theme.textTheme.titleMedium),
        ),
        EpisodeDebugOverlay(httpCalls: httpCalls),
        if (loading && episodes.isEmpty) const ListLoadingFooter(),
        for (final group in groupEpisodesBySeason(episodes)) ...[
          ListTile(
            title: Text(
              group.key == 0 ? 'Other' : 'Season ${group.key}',
              style: theme.textTheme.titleSmall,
            ),
          ),
          for (final episode in group.value)
            ListTile(
              title: Text(episode.name),
              subtitle: Text('${episode.code} · ${episode.airDate}'),
              dense: true,
            ),
        ],
        if (failedCount > 0)
          ListTile(
            title: Text(errorMessage ?? 'Could not load some episodes.'),
            trailing: TextButton(
              onPressed: onRetryMissing,
              child: const Text('Retry missing'),
            ),
          ),
        if (loading && episodes.isNotEmpty) const ListLoadingFooter(),
      ],
    );
  }
}

List<MapEntry<int, List<Episode>>> groupEpisodesBySeason(
  List<Episode> episodes,
) {
  final grouped = <int, List<Episode>>{};
  for (final episode in episodes) {
    grouped.putIfAbsent(episode.season, () => []).add(episode);
  }
  for (final seasonEpisodes in grouped.values) {
    seasonEpisodes.sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
  }
  final seasons = grouped.keys.toList()..sort();
  return [for (final season in seasons) MapEntry(season, grouped[season]!)];
}
