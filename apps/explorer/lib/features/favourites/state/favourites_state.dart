import 'package:thawani_models/thawani_models.dart';

class FavouritesState {
  const FavouritesState({
    this.items = const [],
    this.loading = false,
    this.errorMessage,
  });

  final List<Character> items;
  final bool loading;
  final String? errorMessage;

  FavouritesState copyWith({
    List<Character>? items,
    bool? loading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return FavouritesState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}
