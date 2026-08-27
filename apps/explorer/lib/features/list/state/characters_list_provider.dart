import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:thawani_models/thawani_models.dart';
import 'package:thawani_ui/thawani_ui.dart';

import '../../../core/failure_message.dart';
import '../../../core/state/network_provider.dart';
import '../../../core/state/network_state.dart';
import '../../../use_cases/get_characters_page_use_case.dart';
import 'characters_list_state.dart';

/// Owns the characters list / search screen state.
///
/// ## Typical flows
///
/// **First open:** router calls [loadInitialIfNeeded] once → [refresh] → page 1.
///
/// **Search typing:** [onQueryChanged] updates [CharactersListState.query]
/// immediately and schedules a debounced [refresh] so keystrokes do not each
/// hit the network.
///
/// **Submit / explicit search:** [search] cancels the debounce and refreshes
/// immediately with the given query.
///
/// **Infinite scroll:** [loadNextPage] appends page `_page + 1` when
/// [CharactersListState.hasMore] and nothing is already in flight.
///
/// **Pull / retry:** [refresh] / [retry] reset to page 1.
///
/// ## Stale-response guards
///
/// - [_epoch] increments on every [_load]. When a response returns, it is
///   ignored if a newer load has started (new search or refresh).
/// - Responses are also ignored if [CharactersListState.query] changed while
///   the request was in flight.
/// - [_inFlight] blocks overlapping pagination; a [reset] load may still start
///   and supersede via [_epoch].
///
/// ## Connectivity
///
/// If the list is showing cached data and we go offline → online,
/// [refresh] runs with `clear: false` so existing rows stay visible while
/// page 1 reloads.
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

  /// Last successfully applied page number (`0` = none yet).
  int _page = 0;

  /// True while a [_load] request is awaiting its use-case result.
  bool _inFlight = false;

  /// Bumped on each [_load]; outdated responses bail out when it no longer matches.
  int _epoch = 0;

  /// Ensures [loadInitialIfNeeded] only kicks off the first fetch once.
  bool _started = false;

  void _emit(CharactersListState next) {
    _state = next;
    notifyListeners();
  }

  /// Updates the search box text and debounces a network [refresh].
  void onQueryChanged(String value) {
    if (value == _state.query) {
      return;
    }
    _emit(_state.copyWith(query: value));
    _debouncer.run(() => unawaited(refresh()));
  }

  /// Applies [query] immediately (no debounce) and reloads page 1.
  Future<void> search(String query) {
    _debouncer.cancel();
    if (query != _state.query) {
      _state = _state.copyWith(query: query);
    }
    return refresh();
  }

  /// First-entry load used by the shell/router; no-ops after the first call.
  Future<void> loadInitialIfNeeded() async {
    if (_started) {
      return;
    }
    _started = true;
    await refresh();
  }

  /// Alias for [refresh] after a full-list error.
  Future<void> retry() => refresh();

  /// Reloads page 1 for the current query.
  ///
  /// When [clear] is true (default), the list is emptied and status goes to
  /// [CharactersListStatus.initialLoading]. When false, existing rows stay
  /// on screen (soft refresh after reconnect).
  Future<void> refresh({bool clear = true}) {
    _started = true;
    return _load(reset: true, clear: clear);
  }

  /// Fetches the next page when more data exists and nothing is loading.
  Future<void> loadNextPage() async {
    if (!state.hasMore ||
        _inFlight ||
        state.status != CharactersListStatus.data ||
        state.loadingMore) {
      return;
    }
    await _load(reset: false, clear: false);
  }

  /// Shared fetch path for page-1 reset and append-next-page.
  ///
  /// [reset] true → page 1 (replace or soft-refresh).  
  /// [reset] false → append `_page + 1`.  
  /// [clear] only matters on reset: wipe rows vs keep them while reloading.
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
      // Drop stale results from an older search/refresh or a superseded page.
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
        // Keep existing rows; surface a footer/pagination error only.
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

  /// Soft-refreshes when coming back online after showing cached list data.
  void _onNetworkChanged() {
    final status = _network!.state.status;
    if (status == NetworkStatus.online &&
        _lastNetworkStatus != NetworkStatus.online &&
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
