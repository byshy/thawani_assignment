import 'package:thawani_models/thawani_models.dart';

class CharacterDetailState {
  const CharacterDetailState({
    this.character,
    this.loading = false,
    this.errorMessage,
    this.fromCache = false,
    this.fetchedAt,
    this.episodes = const [],
    this.episodesLoading = false,
    this.failedEpisodeIds = const {},
    this.episodesErrorMessage,
    this.episodeHttpCalls = 0,
  });

  final Character? character;
  final bool loading;
  final String? errorMessage;
  final bool fromCache;
  final DateTime? fetchedAt;
  final List<Episode> episodes;
  final bool episodesLoading;
  final Set<int> failedEpisodeIds;
  final String? episodesErrorMessage;
  final int episodeHttpCalls;

  CharacterDetailState copyWith({
    Character? character,
    bool? loading,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? fromCache,
    DateTime? fetchedAt,
    List<Episode>? episodes,
    bool? episodesLoading,
    Set<int>? failedEpisodeIds,
    String? episodesErrorMessage,
    bool clearEpisodesError = false,
    int? episodeHttpCalls,
  }) {
    return CharacterDetailState(
      character: character ?? this.character,
      loading: loading ?? this.loading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      fromCache: fromCache ?? this.fromCache,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      episodes: episodes ?? this.episodes,
      episodesLoading: episodesLoading ?? this.episodesLoading,
      failedEpisodeIds: failedEpisodeIds ?? this.failedEpisodeIds,
      episodesErrorMessage: clearEpisodesError
          ? null
          : (episodesErrorMessage ?? this.episodesErrorMessage),
      episodeHttpCalls: episodeHttpCalls ?? this.episodeHttpCalls,
    );
  }
}
