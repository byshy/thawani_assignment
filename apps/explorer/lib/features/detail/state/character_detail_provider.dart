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
  int? _id;
  bool _disposed = false;
  StreamSubscription<EpisodesSnapshot>? _episodesSub;
  CancelToken? _episodeToken;
  int _episodeHttpBase = 0;
  bool _mergeEpisodes = false;
  Set<int> _requestedEpisodeIds = const {};

  void _emit(CharacterDetailState next) {
    if (_disposed) {
      return;
    }
    _state = next;
    notifyListeners();
  }

  Future<void> load(int id, {List<String> episodeUrls = const []}) async {
    _id = id;
    _emit(
      _state.copyWith(
        loading: _state.character == null || _state.character?.id != id,
        clearErrorMessage: true,
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
          fromCache: result.meta.fromCache,
          fetchedAt: result.meta.fetchedAt,
          loading: false,
          clearErrorMessage: true,
        ),
      );
      final List<int> ids = episodeIdsFromUrls(result.character.episodeUrls);
      final bool alreadyStarted = idsFromRoute.isNotEmpty;
      final bool sameIds =
          ids.length == idsFromRoute.length &&
          ids.join(',') == idsFromRoute.join(',');
      if (ids.isNotEmpty && (!alreadyStarted || !sameIds)) {
        _watchEpisodes(ids, merge: false);
      }
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
    final int? id = _id;
    if (id == null) {
      return;
    }
    await load(id, episodeUrls: _state.character?.episodeUrls ?? const []);
  }

  Future<void> retryMissingEpisodes() async {
    final List<int> missing = _state.failedEpisodeIds.toList();
    if (missing.isEmpty) {
      return;
    }
    _watchEpisodes(missing, merge: true);
  }

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

  void _onSnapshot(EpisodesSnapshot snapshot, {required CancelToken token}) {
    if (_disposed || !identical(_episodeToken, token)) {
      return;
    }
    final List<Episode> episodes = _mergeEpisodes
        ? _merge(_state.episodes, snapshot.episodes)
        : snapshot.episodes;
    final Set<int> failed = _mergeEpisodes
        ? {
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

  List<Episode> _merge(List<Episode> current, List<Episode> incoming) {
    final Map<int, Episode> byId = {
      for (final Episode episode in current) episode.id: episode,
    };
    for (final Episode episode in incoming) {
      byId[episode.id] = episode;
    }
    return byId.values.toList();
  }

  void _onNetworkChanged() {
    final NetworkStatus status = _network!.state.status;
    final int? id = _id;
    if (status == NetworkStatus.online &&
        _lastNetworkStatus == NetworkStatus.offline &&
        _state.fromCache &&
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
