import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:thawani_models/thawani_models.dart';
import 'package:thawani_ui/thawani_ui.dart';

import '../../../core/failure_message.dart';
import '../../../core/state/network_provider.dart';
import '../../../core/state/network_state.dart';
import '../../../use_cases/get_characters_page_use_case.dart';
import 'characters_list_state.dart';

class CharactersListProvider extends ChangeNotifier {
  CharactersListProvider({
    required GetCharactersPageUseCase getPage,
    NetworkProvider? network,
    Debouncer? searchDebouncer,
  }) : _getPage = getPage,
       _network = network,
       _debouncer = searchDebouncer ?? Debouncer(),
       _lastNetworkStatus = network?.state.status ?? NetworkStatus.unknown {
    _network?.addListener(_onNetworkChanged);
  }

  final GetCharactersPageUseCase _getPage;
  final NetworkProvider? _network;
  final Debouncer _debouncer;
  NetworkStatus _lastNetworkStatus;

  CharactersListState _state = const CharactersListState();
  CharactersListState get state => _state;

  int _page = 0;
  bool _inFlight = false;
  int _epoch = 0;
  bool _started = false;

  void _emit(CharactersListState next) {
    _state = next;
    notifyListeners();
  }

  void onQueryChanged(String value) {
    if (value == _state.query) {
      return;
    }
    _emit(_state.copyWith(query: value));
    _debouncer.run(() => unawaited(refresh()));
  }

  Future<void> search(String query) {
    _debouncer.cancel();
    if (query != _state.query) {
      _state = _state.copyWith(query: query);
    }
    return refresh();
  }

  Future<void> loadInitialIfNeeded() async {
    if (_started) {
      return;
    }
    _started = true;
    await refresh();
  }

  Future<void> retry() => refresh();

  Future<void> refresh({bool clear = true}) {
    _started = true;
    return _load(reset: true, clear: clear);
  }

  Future<void> loadNextPage() async {
    if (!state.hasMore ||
        _inFlight ||
        state.status != CharactersListStatus.data ||
        state.loadingMore) {
      return;
    }
    await _load(reset: false, clear: false);
  }

  Future<void> _load({required bool reset, required bool clear}) async {
    if (!reset && _inFlight) {
      return;
    }

    if (reset) {
      _page = 0;
      if (clear || _state.characters.isEmpty) {
        _emit(
          _state.copyWith(
            characters: const [],
            status: CharactersListStatus.initialLoading,
            hasMore: true,
            loadingMore: false,
            clearErrorMessage: true,
            clearPaginationError: true,
          ),
        );
      } else {
        _emit(
          _state.copyWith(
            hasMore: true,
            loadingMore: false,
            clearPaginationError: true,
          ),
        );
      }
    } else {
      _emit(_state.copyWith(loadingMore: true, clearPaginationError: true));
    }

    final epoch = ++_epoch;
    final requestedQuery = _state.query;
    final requestedPage = _page + 1;
    _inFlight = true;

    try {
      final result = await _getPage(query: requestedQuery, page: requestedPage);
      if (epoch != _epoch || requestedQuery != _state.query) {
        return;
      }

      final characters = reset
          ? List<Character>.of(result.page.results)
          : [..._state.characters, ...result.page.results];
      _page = requestedPage;
      _emit(
        _state.copyWith(
          characters: characters,
          fromCache: result.meta.fromCache,
          fetchedAt: result.meta.fetchedAt,
          hasMore: result.page.info.hasNext,
          status: characters.isEmpty
              ? CharactersListStatus.empty
              : CharactersListStatus.data,
          loadingMore: false,
          clearErrorMessage: true,
          clearPaginationError: true,
        ),
      );
    } catch (error) {
      if (epoch != _epoch) {
        return;
      }
      if (reset && (clear || _state.characters.isEmpty)) {
        _emit(
          _state.copyWith(
            status: CharactersListStatus.error,
            errorMessage: failureMessage(error),
            loadingMore: false,
          ),
        );
      } else if (!reset) {
        _emit(
          _state.copyWith(
            loadingMore: false,
            paginationErrorMessage: failureMessage(error),
          ),
        );
      }
    } finally {
      if (epoch == _epoch) {
        _inFlight = false;
      }
    }
  }

  void _onNetworkChanged() {
    final status = _network!.state.status;
    if (status == NetworkStatus.online &&
        _lastNetworkStatus == NetworkStatus.offline &&
        _state.fromCache) {
      unawaited(refresh(clear: false));
    }
    if (status != NetworkStatus.unknown) {
      _lastNetworkStatus = status;
    }
  }

  @override
  void dispose() {
    _network?.removeListener(_onNetworkChanged);
    _debouncer.dispose();
    super.dispose();
  }
}
