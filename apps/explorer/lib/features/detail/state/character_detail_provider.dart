import 'package:flutter/foundation.dart';
import 'package:networking/networking.dart';

import '../../../core/failure_message.dart';
import '../../../use_cases/get_character_use_case.dart';
import 'character_detail_state.dart';

class CharacterDetailProvider extends ChangeNotifier {
  CharacterDetailProvider({required GetCharacterUseCase getCharacter})
    : _getCharacter = getCharacter;

  final GetCharacterUseCase _getCharacter;

  CharacterDetailState _state = const CharacterDetailState();
  CharacterDetailState get state => _state;
  int? _id;

  void _emit(CharacterDetailState next) {
    _state = next;
    notifyListeners();
  }

  Future<void> load(int id) async {
    _id = id;
    _emit(
      _state.copyWith(
        loading: _state.character == null,
        clearErrorMessage: true,
      ),
    );

    try {
      final result = await _getCharacter(id);
      _emit(
        _state.copyWith(
          character: result.character,
          fromCache: result.meta.fromCache,
          fetchedAt: result.meta.fetchedAt,
          loading: false,
          clearErrorMessage: true,
        ),
      );
    } on CancelledFailure {
      _emit(_state.copyWith(loading: false));
    } catch (error) {
      if (_state.character == null) {
        _emit(
          _state.copyWith(loading: false, errorMessage: failureMessage(error)),
        );
      } else {
        _emit(_state.copyWith(loading: false));
      }
    }
  }

  Future<void> retry() async {
    final id = _id;
    if (id == null) {
      return;
    }
    await load(id);
  }
}
