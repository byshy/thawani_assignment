import 'dart:async';

import 'package:networking/networking.dart';
import 'package:thawani_models/thawani_models.dart';

import '../../domain/episode_repository.dart';
import '../../domain/episodes_snapshot.dart';
import '../datasources/episode_remote_data_source.dart';
import '../episodes/episode_memory_cache.dart';

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

  final _inFlight = <int, Future<Episode?>>{};

  @override
  Stream<EpisodesSnapshot> watchEpisodes(
    List<int> ids, {
    CancelToken? cancelToken,
  }) {
    final uniqueIds = _dedupe(ids);
    final controller = StreamController<EpisodesSnapshot>();

    Future<void> run() async {
      final arrived = <int, Episode>{
        for (final id in uniqueIds) id: ?_cache.get(id),
      };
      final failed = <int>{};
      var httpCalls = 0;

      EpisodesSnapshot snapshot({required bool inFlight}) {
        return EpisodesSnapshot(
          episodes: [for (final id in uniqueIds) ?arrived[id]],
          failedIds: Set<int>.unmodifiable(Set<int>.of(failed)),
          inFlight: inFlight,
          httpCalls: httpCalls,
        );
      }

      void emit({required bool inFlight}) {
        if (!controller.isClosed) {
          controller.add(snapshot(inFlight: inFlight));
        }
      }

      try {
        if (uniqueIds.isEmpty) {
          emit(inFlight: false);
          return;
        }

        final missing = [
          for (final id in uniqueIds)
            if (!arrived.containsKey(id)) id,
        ];

        if (missing.isEmpty) {
          emit(inFlight: false);
          return;
        }

        emit(inFlight: true);

        if (cancelToken?.isCancelled ?? false) {
          throw const CancelledFailure();
        }

        final online = await _isOnline();
        if (!online) {
          failed.addAll(missing);
          emit(inFlight: false);
          return;
        }

        final chunks = _chunk(missing, chunkSize);
        final gate = _ConcurrencyGate(maxConcurrency);

        await Future.wait(
          chunks.map((chunk) {
            return gate.run(() async {
              if (cancelToken?.isCancelled ?? false) {
                throw const CancelledFailure();
              }
              try {
                final fetched = await _fetchOrJoin(chunk, cancelToken);
                httpCalls += fetched.httpCalls;
                for (final episode in fetched.episodes) {
                  arrived[episode.id] = episode;
                }
              } on CancelledFailure {
                rethrow;
              } on RemoteFailure {
                failed.addAll(chunk.where((id) => !arrived.containsKey(id)));
              }
              emit(inFlight: true);
            });
          }),
        );

        emit(inFlight: false);
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

    unawaited(run());
    return controller.stream;
  }

  Future<({List<Episode> episodes, int httpCalls})> _fetchOrJoin(
    List<int> ids,
    CancelToken? cancelToken,
  ) {
    final pending = <Future<Episode?>>[];
    final toFetch = <int>[];

    for (final id in ids) {
      final cached = _cache.get(id);
      if (cached != null) {
        pending.add(Future<Episode?>.value(cached));
        continue;
      }
      final existing = _inFlight[id];
      if (existing != null) {
        pending.add(existing);
      } else {
        toFetch.add(id);
      }
    }

    var httpCalls = 0;
    if (toFetch.isNotEmpty) {
      final fetchFuture = _remote
          .fetchByIds(toFetch, cancelToken: cancelToken)
          .then((dtos) {
            final episodes = dtos.map((dto) => dto.toEntity()).toList();
            _cache.putAll(episodes);
            return episodes;
          });
      httpCalls = 1;
      for (final id in toFetch) {
        final perId = fetchFuture
            .then((episodes) {
              for (final episode in episodes) {
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

    return Future.wait(pending).then((episodes) {
      return (
        episodes: episodes.whereType<Episode>().toList(),
        httpCalls: httpCalls,
      );
    });
  }

  List<int> _dedupe(List<int> ids) {
    final seen = <int>{};
    final unique = <int>[];
    for (final id in ids) {
      if (seen.add(id)) {
        unique.add(id);
      }
    }
    return unique;
  }

  List<List<int>> _chunk(List<int> ids, int size) {
    if (ids.isEmpty) {
      return const [];
    }
    return [
      for (var i = 0; i < ids.length; i += size)
        ids.sublist(i, i + size > ids.length ? ids.length : i + size),
    ];
  }
}

class _ConcurrencyGate {
  _ConcurrencyGate(this._max);

  final int _max;
  var _active = 0;
  final _waiters = <Completer<void>>[];

  Future<T> run<T>(Future<T> Function() action) async {
    if (_active >= _max) {
      final waiter = Completer<void>();
      _waiters.add(waiter);
      await waiter.future;
    }
    _active++;
    try {
      return await action();
    } finally {
      _active--;
      if (_waiters.isNotEmpty) {
        _waiters.removeAt(0).complete();
      }
    }
  }
}
