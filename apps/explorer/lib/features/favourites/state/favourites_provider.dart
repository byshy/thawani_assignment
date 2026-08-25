import 'package:flutter/foundation.dart';
import 'package:thawani_models/thawani_models.dart';

import '../../../core/failure_message.dart';
import '../../../use_cases/get_favourites_use_case.dart';
import '../../../use_cases/toggle_favourite_use_case.dart';
import 'favourites_state.dart';

class FavouritesProvider extends ChangeNotifier {
  FavouritesProvider({
    required GetFavouritesUseCase getFavourites,
    required ToggleFavouriteUseCase toggleFavourite,
  }) : _getFavourites = getFavourites,
       _toggleFavourite = toggleFavourite;

  final GetFavouritesUseCase _getFavourites;
  final ToggleFavouriteUseCase _toggleFavourite;

  FavouritesState _state = const FavouritesState();
  FavouritesState get state => _state;

  bool contains(int id) => _state.items.any((character) => character.id == id);

  void _emit(FavouritesState next) {
    _state = next;
    notifyListeners();
  }

  Future<void> load() async {
    _emit(_state.copyWith(loading: _state.items.isEmpty));
    try {
      _emit(
        _state.copyWith(
          items: await _getFavourites(),
          loading: false,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      _emit(
        _state.copyWith(loading: false, errorMessage: failureMessage(error)),
      );
    }
  }

  Future<void> toggle(Character character) async {
    final removing = contains(character.id);
    final List<Character> items;
    if (removing) {
      items = _state.items.where((item) => item.id != character.id).toList();
    } else {
      items = [..._state.items, character]
        ..sort((a, b) => a.name.compareTo(b.name));
    }
    _emit(_state.copyWith(items: items));

    try {
      await _toggleFavourite(character);
    } catch (_) {
      await load();
    }
  }
}
