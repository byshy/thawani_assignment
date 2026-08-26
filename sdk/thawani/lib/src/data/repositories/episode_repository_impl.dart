import 'dart:async';

import 'package:networking/networking.dart';
import 'package:thawani_models/thawani_models.dart';

import '../../domain/episode_repository.dart';
import '../../domain/episodes_snapshot.dart';
import '../datasources/episode_remote_data_source.dart';
import '../episodes/concurrency_gate.dart';
import '../episodes/episode_memory_cache.dart';
import '../episodes/episode_watch_state.dart';

class EpisodeRepositoryImpl implements EpisodeRepository {
  EpisodeRepositoryImpl({
    required EpisodeRemoteDataSource remote,
    EpisodeMemoryCache? cache,
    Future<bool> Function()? isOnline,
    this.chunkSize = 20,
    this.maxConcurrency = 2,
  }) : _remote = remote,
       _cache = cache ?? EpisodeMemoryCache(),
       _isOnline = isOnline ?? (() async => true);

  final EpisodeRemoteDataSource _remote;
  final EpisodeMemoryCache _cache;
  final Future<bool> Function() _isOnline;
  final int chunkSize;
  final int maxConcurrency;

  final Map<int, Future<Episode?>> _inFlight = <int, Future<Episode?>>{};

  @override
  Stream<EpisodesSnapshot> watchEpisodes(
    List<int> ids, {
    CancelToken? cancelToken,
  }) {
    final List<int> uniqueIds = _dedupe(ids);
    final StreamController<EpisodesSnapshot> controller =
        StreamController<EpisodesSnapshot>();
    unawaited(
      _collectEpisodes(
        uniqueIds: uniqueIds,
        controller: controller,
        cancelToken: cancelToken,
      ),
    );
    return controller.stream;
  }

  Future<void> _collectEpisodes({
    required List<int> uniqueIds,
    required StreamController<EpisodesSnapshot> controller,
    CancelToken? cancelToken,
  }) async {
    final EpisodeWatchState state = EpisodeWatchState(
      uniqueIds: uniqueIds,
      cache: _cache,
    );

    try {
      if (uniqueIds.isEmpty) {
        _emitSnapshot(controller, state, inFlight: false);
        return;
      }

      final List<int> missing = [
        for (final int id in uniqueIds)
          if (!state.arrived.containsKey(id)) id,
      ];

      if (missing.isEmpty) {
        _emitSnapshot(controller, state, inFlight: false);
        return;
      }

      _emitSnapshot(controller, state, inFlight: true);

      if (cancelToken?.isCancelled ?? false) {
        throw const CancelledFailure();
      }

      final bool online = await _isOnline();
      if (!online) {
        state.failed.addAll(missing);
        _emitSnapshot(controller, state, inFlight: false);
        return;
      }

      final List<List<int>> chunks = _chunk(missing, chunkSize);
      final ConcurrencyGate gate = ConcurrencyGate(maxConcurrency);

      await Future.wait(
        chunks.map(
          (List<int> chunk) => gate.run(
            () => _fetchChunk(
              chunk: chunk,
              state: state,
              controller: controller,
              cancelToken: cancelToken,
            ),
          ),
        ),
      );

      _emitSnapshot(controller, state, inFlight: false);
    } on CancelledFailure catch (error, stack) {
      if (!controller.isClosed) {
        controller.addError(error, stack);
      }
    } catch (error, stack) {
      if (!controller.isClosed) {
        controller.addError(error, stack);
      }
    } finally {
      if (!controller.isClosed) {
        await controller.close();
      }
    }
  }

  Future<void> _fetchChunk({
    required List<int> chunk,
    required EpisodeWatchState state,
    required StreamController<EpisodesSnapshot> controller,
    CancelToken? cancelToken,
  }) async {
    if (cancelToken?.isCancelled ?? false) {
      throw const CancelledFailure();
    }
    try {
      final ({List<Episode> episodes, int httpCalls}) fetched =
          await _fetchOrJoin(chunk, cancelToken);
      state.httpCalls += fetched.httpCalls;
      for (final Episode episode in fetched.episodes) {
        state.arrived[episode.id] = episode;
      }
    } on CancelledFailure {
      rethrow;
    } on RemoteFailure {
      state.failed.addAll(
        chunk.where((int id) => !state.arrived.containsKey(id)),
      );
    }
    _emitSnapshot(controller, state, inFlight: true);
  }

  void _emitSnapshot(
    StreamController<EpisodesSnapshot> controller,
    EpisodeWatchState state, {
    required bool inFlight,
  }) {
    if (controller.isClosed) {
      return;
    }
    controller.add(state.toSnapshot(inFlight: inFlight));
  }

  Future<({List<Episode> episodes, int httpCalls})> _fetchOrJoin(
    List<int> ids,
    CancelToken? cancelToken,
  ) {
    final List<Future<Episode?>> pending = <Future<Episode?>>[];
    final List<int> toFetch = <int>[];

    for (final int id in ids) {
      final Episode? cached = _cache.get(id);
      if (cached != null) {
        pending.add(Future<Episode?>.value(cached));
        continue;
      }
      final Future<Episode?>? existing = _inFlight[id];
      if (existing != null) {
        pending.add(existing);
      } else {
        toFetch.add(id);
      }
    }

    int httpCalls = 0;
    if (toFetch.isNotEmpty) {
      final Future<List<Episode>> fetchFuture = _remote
          .fetchByIds(toFetch, cancelToken: cancelToken)
          .then((List<EpisodeDto> dtos) {
            final List<Episode> episodes =
                dtos.map((EpisodeDto dto) => dto.toEntity()).toList();
            _cache.putAll(episodes);
            return episodes;
          });
      httpCalls = 1;
      for (final int id in toFetch) {
        final Future<Episode?> perId = fetchFuture
            .then((List<Episode> episodes) {
              for (final Episode episode in episodes) {
                if (episode.id == id) {
                  return episode;
                }
              }
              return null;
            })
            .whenComplete(() {
              _inFlight.remove(id);
            });
        _inFlight[id] = perId;
        pending.add(perId);
      }
    }

    return Future.wait(pending).then((List<Episode?> episodes) {
      return (
        episodes: episodes.whereType<Episode>().toList(),
        httpCalls: httpCalls,
      );
    });
  }

  List<int> _dedupe(List<int> ids) {
    final Set<int> seen = <int>{};
    final List<int> unique = <int>[];
    for (final int id in ids) {
      if (seen.add(id)) {
        unique.add(id);
      }
    }
    return unique;
  }

  List<List<int>> _chunk(List<int> ids, int size) {
    if (ids.isEmpty) {
      return const <List<int>>[];
    }
    return [
      for (int i = 0; i < ids.length; i += size)
        ids.sublist(i, i + size > ids.length ? ids.length : i + size),
    ];
  }
}
