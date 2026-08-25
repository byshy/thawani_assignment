import 'package:thawani_models/thawani_models.dart';

class CharacterDetailState {
  const CharacterDetailState({
    this.character,
    this.loading = false,
    this.errorMessage,
    this.fromCache = false,
    this.fetchedAt,
  });

  final Character? character;
  final bool loading;
  final String? errorMessage;
  final bool fromCache;
  final DateTime? fetchedAt;

  CharacterDetailState copyWith({
    Character? character,
    bool? loading,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? fromCache,
    DateTime? fetchedAt,
  }) {
    return CharacterDetailState(
      character: character ?? this.character,
      loading: loading ?? this.loading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      fromCache: fromCache ?? this.fromCache,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}
