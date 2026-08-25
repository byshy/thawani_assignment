import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:networking/networking.dart';

import '../../../core/failure_message.dart';
import '../../../core/state/network_provider.dart';
import '../../../core/state/network_state.dart';
import '../../../use_cases/get_character_use_case.dart';
import 'character_detail_state.dart';

class CharacterDetailProvider extends ChangeNotifier {
  CharacterDetailProvider({
    required GetCharacterUseCase getCharacter,
    NetworkProvider? network,
  }) : _getCharacter = getCharacter,
       _network = network,
       _lastNetworkStatus = network?.state.status ?? NetworkStatus.unknown {
    _network?.addListener(_onNetworkChanged);
  }

  final GetCharacterUseCase _getCharacter;
  final NetworkProvider? _network;
  NetworkStatus _lastNetworkStatus;

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

  void _onNetworkChanged() {
    final status = _network!.state.status;
    final id = _id;
    if (status == NetworkStatus.online &&
        _lastNetworkStatus == NetworkStatus.offline &&
        _state.fromCache &&
        id != null) {
      unawaited(load(id));
    }
    if (status != NetworkStatus.unknown) {
      _lastNetworkStatus = status;
    }
  }

  @override
  void dispose() {
    _network?.removeListener(_onNetworkChanged);
    super.dispose();
  }
}
