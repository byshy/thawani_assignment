import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:networking/networking.dart';
import 'package:thawani/thawani.dart';
import 'package:thawani_models/thawani_models.dart';

import '../../../core/failure_message.dart';
import '../../../core/state/network_provider.dart';
import '../../../core/state/network_state.dart';
import '../../../use_cases/get_character_use_case.dart';
import '../../../use_cases/get_episodes_use_case.dart';
import 'character_detail_state.dart';

/// Owns character-detail UI state: one character plus its episode fan-out.
///
/// ## Typical flow (open detail from the list)
///
/// 1. Router creates this provider and calls [load] with the list row's
///    `id` and `episodeUrls` so the screen can paint immediately.
/// 2. [load] starts episode watching from those URLs right away (fast path),
///    then refreshes the character via [GetCharacterUseCase] (network or cache).
/// 3. If the refreshed character's episode ids differ from the route snapshot,
///    episode watching restarts with the authoritative list.
/// 4. [GetEpisodesUseCase] returns a stream of [EpisodesSnapshot]s as chunks
///    arrive; [_onSnapshot] maps each into [CharacterDetailState].
///
/// ## Episode session bookkeeping
///
/// Only one episode watch runs at a time. Starting a new watch cancels the
/// previous [CancelToken] and subscription. Snapshots from a cancelled token
/// are ignored via [_episodeToken] identity checks.
///
/// - [_mergeEpisodes]: `false` on a full reload (replace list); `true` on
///   [retryMissingEpisodes] (keep successes, fill gaps).
/// - [_episodeHttpBase]: when merging a retry, keep the HTTP call count from
///   the earlier session and add the new session's counts on top.
/// - [_requestedEpisodeIds]: ids asked for in the current watch (used when
///   merging failed-id sets after a retry).
///
/// ## Connectivity
///
/// If we showed a cached character while offline and connectivity returns,
/// [load] runs again to refresh.
class CharacterDetailProvider extends ChangeNotifier {
  CharacterDetailProvider({
    required GetCharacterUseCase getCharacter,
    required GetEpisodesUseCase getEpisodes,
    NetworkProvider? network,
  }) : _getCharacter = getCharacter,
       _getEpisodes = getEpisodes,
       _network = network,
       _lastNetworkStatus = network?.state.status ?? NetworkStatus.unknown {
    _network?.addListener(_onNetworkChanged);
  }

  final GetCharacterUseCase _getCharacter;
  final GetEpisodesUseCase _getEpisodes;
  final NetworkProvider? _network;
  NetworkStatus _lastNetworkStatus;

  CharacterDetailState _state = const CharacterDetailState();
  CharacterDetailState get state => _state;

  /// Character id for the open screen; used by [retry] and connectivity refresh.
  int? _id;
  bool _disposed = false;
  StreamSubscription<EpisodesSnapshot>? _episodesSub;

  /// Active episode [CancelToken]; replaced when a new watch starts.
  CancelToken? _episodeToken;

  /// HTTP calls already counted before the current (possibly merged) watch.
  int _episodeHttpBase = 0;

  /// Whether incoming snapshots should merge into existing episode state.
  bool _mergeEpisodes = false;

  /// Episode ids requested by the current watch (for failed-id merge on retry).
  Set<int> _requestedEpisodeIds = const {};

  void _emit(CharacterDetailState next) {
    if (_disposed) {
      return;
    }
    _state = next;
    notifyListeners();
  }

  /// Loads / refreshes [id], optionally kicking off episodes from [episodeUrls].
  ///
  /// [episodeUrls] usually come from the list/favourites row so episodes can
  /// start before the detail fetch finishes.
  Future<void> load(int id, {List<String> episodeUrls = const []}) async {
    _id = id;
    _emit(
      _state.copyWith(
        characterLoading:
            _state.character == null || _state.character?.id != id,
        clearCharacterError: true,
      ),
    );

    final List<int> idsFromRoute = episodeIdsFromUrls(episodeUrls);
    if (idsFromRoute.isNotEmpty) {
      _watchEpisodes(idsFromRoute, merge: false);
    }

    try {
      final CharacterResult result = await _getCharacter(id);
      _emit(
        _state.copyWith(
          character: result.character,
          characterFromCache: result.meta.fromCache,
          characterFetchedAt: result.meta.fetchedAt,
          characterLoading: false,
          clearCharacterError: true,
        ),
      );
      final List<int> ids = episodeIdsFromUrls(result.character.episodeUrls);
      final bool alreadyStarted = idsFromRoute.isNotEmpty;
      final bool sameIds =
          ids.length == idsFromRoute.length &&
          ids.join(',') == idsFromRoute.join(',');
      // Avoid a second fan-out when the route already started the same ids.
      if (ids.isNotEmpty && (!alreadyStarted || !sameIds)) {
        _watchEpisodes(ids, merge: false);
      }
    } on CancelledFailure {
      _emit(_state.copyWith(characterLoading: false));
    } catch (error) {
      if (_state.character == null) {
        _emit(
          _state.copyWith(
            characterLoading: false,
            characterErrorMessage: failureMessage(error),
          ),
        );
      } else {
        // Keep the existing character (e.g. list snapshot / stale cache) visible.
        _emit(_state.copyWith(characterLoading: false));
      }
    }
  }

  /// Reloads the current character (and its episodes) after a character error.
  Future<void> retry() async {
    final int? id = _id;
    if (id == null) {
      return;
    }
    await load(id, episodeUrls: _state.character?.episodeUrls ?? const []);
  }

  /// Re-fetches only [CharacterDetailState.failedEpisodeIds], keeping successes.
  Future<void> retryMissingEpisodes() async {
    final List<int> missing = _state.failedEpisodeIds.toList();
    if (missing.isEmpty) {
      return;
    }
    _watchEpisodes(missing, merge: true);
  }

  /// Starts (or replaces) the episode stream for [ids].
  ///
  /// Cancels any in-flight watch first. When [merge] is true, snapshots are
  /// combined with existing episodes / failed ids (retry-missing path).
  void _watchEpisodes(List<int> ids, {required bool merge}) {
    unawaited(_episodesSub?.cancel());
    final CancelToken? previous = _episodeToken;
    if (previous != null && !previous.isCancelled) {
      previous.cancel();
    }
    final CancelToken token = CancelToken();
    _episodeToken = token;
    _mergeEpisodes = merge;
    _requestedEpisodeIds = ids.toSet();
    _episodeHttpBase = merge ? _state.episodeHttpCalls : 0;

    if (ids.isEmpty) {
      _emit(
        _state.copyWith(
          episodes: merge ? _state.episodes : const [],
          episodesLoading: false,
          failedEpisodeIds: merge ? _state.failedEpisodeIds : const {},
          episodeHttpCalls: merge ? _state.episodeHttpCalls : 0,
          clearEpisodesError: true,
        ),
      );
      return;
    }

    _emit(
      _state.copyWith(
        episodesLoading: true,
        failedEpisodeIds: merge ? _state.failedEpisodeIds : const {},
        clearEpisodesError: true,
        episodeHttpCalls: merge ? _state.episodeHttpCalls : 0,
      ),
    );

    _episodesSub = _getEpisodes(ids, cancelToken: token).listen(
      (EpisodesSnapshot snapshot) => _onSnapshot(snapshot, token: token),
      onError: (Object error, StackTrace _) {
        _onEpisodesError(error, token: token);
      },
    );
  }

  /// Applies a repository snapshot if it still belongs to the active watch.
  void _onSnapshot(EpisodesSnapshot snapshot, {required CancelToken token}) {
    if (_disposed || !identical(_episodeToken, token)) {
      return;
    }
    final List<Episode> episodes = _mergeEpisodes
        ? _merge(_state.episodes, snapshot.episodes)
        : snapshot.episodes;
    final Set<int> failed = _mergeEpisodes
        ? {
            // Drop ids we just retried; keep other failures; add new ones.
            for (final int id in _state.failedEpisodeIds)
              if (!_requestedEpisodeIds.contains(id)) id,
            ...snapshot.failedIds,
          }
        : snapshot.failedIds;
    _emit(
      _state.copyWith(
        episodes: episodes,
        episodesLoading: snapshot.inFlight,
        failedEpisodeIds: failed,
        episodeHttpCalls: _episodeHttpBase + snapshot.httpCalls,
        clearEpisodesError: failed.isEmpty,
        episodesErrorMessage: failed.isEmpty
            ? null
            : 'Could not load ${failed.length} '
                  'episode${failed.length == 1 ? '' : 's'}.',
      ),
    );
  }

  void _onEpisodesError(Object error, {required CancelToken token}) {
    if (_disposed || !identical(_episodeToken, token)) {
      return;
    }
    if (error is CancelledFailure) {
      _emit(_state.copyWith(episodesLoading: false));
      return;
    }
    _emit(
      _state.copyWith(
        episodesLoading: false,
        episodesErrorMessage: failureMessage(error),
      ),
    );
  }

  /// Union of [current] and [incoming] by episode id (incoming wins on clash).
  List<Episode> _merge(List<Episode> current, List<Episode> incoming) {
    final Map<int, Episode> byId = {
      for (final Episode episode in current) episode.id: episode,
    };
    for (final Episode episode in incoming) {
      byId[episode.id] = episode;
    }
    return byId.values.toList();
  }

  /// Soft-refreshes when coming back online after showing cached character data.
  void _onNetworkChanged() {
    final NetworkStatus status = _network!.state.status;
    final int? id = _id;
    if (status == NetworkStatus.online &&
        _lastNetworkStatus == NetworkStatus.offline &&
        _state.characterFromCache &&
        id != null) {
      unawaited(
        load(id, episodeUrls: _state.character?.episodeUrls ?? const []),
      );
    }
    if (status != NetworkStatus.unknown) {
      _lastNetworkStatus = status;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_episodesSub?.cancel());
    final CancelToken? token = _episodeToken;
    if (token != null && !token.isCancelled) {
      token.cancel();
    }
    _network?.removeListener(_onNetworkChanged);
    super.dispose();
  }
}
