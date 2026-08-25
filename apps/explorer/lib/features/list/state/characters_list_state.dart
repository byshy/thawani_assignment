import 'package:thawani_models/thawani_models.dart';

enum CharactersListStatus { initialLoading, data, empty, error }

class CharactersListState {
  const CharactersListState({
    this.status = CharactersListStatus.initialLoading,
    this.characters = const [],
    this.query = '',
    this.errorMessage,
    this.paginationErrorMessage,
    this.loadingMore = false,
    this.fromCache = false,
    this.fetchedAt,
    this.hasMore = true,
  });

  final CharactersListStatus status;
  final List<Character> characters;
  final String query;
  final String? errorMessage;
  final String? paginationErrorMessage;
  final bool loadingMore;
  final bool fromCache;
  final DateTime? fetchedAt;
  final bool hasMore;

  CharactersListState copyWith({
    CharactersListStatus? status,
    List<Character>? characters,
    String? query,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? paginationErrorMessage,
    bool clearPaginationError = false,
    bool? loadingMore,
    bool? fromCache,
    DateTime? fetchedAt,
    bool? hasMore,
  }) {
    return CharactersListState(
      status: status ?? this.status,
      characters: characters ?? this.characters,
      query: query ?? this.query,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      paginationErrorMessage: clearPaginationError
          ? null
          : (paginationErrorMessage ?? this.paginationErrorMessage),
      loadingMore: loadingMore ?? this.loadingMore,
      fromCache: fromCache ?? this.fromCache,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
