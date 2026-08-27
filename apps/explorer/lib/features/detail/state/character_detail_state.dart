import 'package:thawani_models/thawani_models.dart';

class CharacterDetailState {
  const CharacterDetailState({
    this.character,
    this.characterLoading = false,
    this.characterErrorMessage,
    this.characterFromCache = false,
    this.characterFetchedAt,
    this.episodes = const [],
    this.episodesLoading = false,
    this.failedEpisodeIds = const {},
    this.episodesErrorMessage,
    this.episodeHttpCalls = 0,
  });

  final Character? character;
  final bool characterLoading;
  final String? characterErrorMessage;
  final bool characterFromCache;
  final DateTime? characterFetchedAt;

  final List<Episode> episodes;
  final bool episodesLoading;
  final Set<int> failedEpisodeIds;
  final String? episodesErrorMessage;
  final int episodeHttpCalls;

  CharacterDetailState copyWith({
    Character? character,
    bool? characterLoading,
    String? characterErrorMessage,
    bool clearCharacterError = false,
    bool? characterFromCache,
    DateTime? characterFetchedAt,
    List<Episode>? episodes,
    bool? episodesLoading,
    Set<int>? failedEpisodeIds,
    String? episodesErrorMessage,
    bool clearEpisodesError = false,
    int? episodeHttpCalls,
  }) {
    return CharacterDetailState(
      character: character ?? this.character,
      characterLoading: characterLoading ?? this.characterLoading,
      characterErrorMessage: clearCharacterError
          ? null
          : (characterErrorMessage ?? this.characterErrorMessage),
      characterFromCache: characterFromCache ?? this.characterFromCache,
      characterFetchedAt: characterFetchedAt ?? this.characterFetchedAt,
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
