import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:networking/networking.dart';
import 'package:thawani/thawani.dart';
import 'package:thawani_models/thawani_models.dart';

void main() {
  late FakeEpisodeRemote remote;
  late EpisodeMemoryCache cache;
  late bool online;

  EpisodeRepositoryImpl buildRepo({
    int chunkSize = 20,
    int maxConcurrency = 2,
  }) {
    return EpisodeRepositoryImpl(
      remote: remote,
      cache: cache,
      isOnline: () async => online,
      chunkSize: chunkSize,
      maxConcurrency: maxConcurrency,
    );
  }

  setUp(() {
    remote = FakeEpisodeRemote();
    cache = EpisodeMemoryCache();
    online = true;
  });

  group('happy path', () {
    test('51 uncached ids make 3 HTTP calls at chunk size 20', () async {
      final ids = [for (var i = 1; i <= 51; i++) i];

      final snapshot = await buildRepo().watchEpisodes(ids).last;

      expect(remote.calls, 3);
      expect(remote.requestSizes.map((chunk) => chunk.length), [20, 20, 11]);
      expect(snapshot.episodes, hasLength(51));
      expect(snapshot.httpCalls, 3);
      expect(snapshot.inFlight, isFalse);
      expect(snapshot.failedIds, isEmpty);
    });

    test('cache hits are not fetched again', () async {
      cache.putAll([_episode(1), _episode(2)]);

      final snapshot = await buildRepo().watchEpisodes(const [1, 2, 3]).last;

      expect(remote.calls, 1);
      expect(remote.requestSizes, [
        [3],
      ]);
      expect(snapshot.episodes.map((e) => e.id), [1, 2, 3]);
      expect(snapshot.httpCalls, 1);
    });
  });

  group('edge cases', () {
    test('two concurrent watchers share one in-flight request', () async {
      remote.delay = const Duration(milliseconds: 40);
      final repo = buildRepo();

      final first = repo.watchEpisodes(const [12]);
      final second = repo.watchEpisodes(const [12]);
      final results = await Future.wait([first.last, second.last]);

      expect(remote.calls, 1);
      expect(results[0].episodes.single.id, 12);
      expect(results[1].episodes.single.id, 12);
    });

    test('caps concurrent chunk requests', () async {
      remote.delay = const Duration(milliseconds: 30);
      final ids = [for (var i = 1; i <= 60; i++) i];

      await buildRepo(maxConcurrency: 2).watchEpisodes(ids).last;

      expect(remote.maxConcurrent, lessThanOrEqualTo(2));
      expect(remote.calls, 3);
    });

    test('offline missing ids are failed without a remote call', () async {
      online = false;
      cache.putAll([_episode(1)]);

      final snapshot = await buildRepo().watchEpisodes(const [1, 2, 3]).last;

      expect(remote.calls, 0);
      expect(snapshot.episodes.single.id, 1);
      expect(snapshot.failedIds, {2, 3});
    });

    test('emits cache hits before remote chunks finish', () async {
      cache.putAll([_episode(1)]);
      remote.delay = const Duration(milliseconds: 40);

      final snapshots = await buildRepo().watchEpisodes(const [1, 2]).toList();

      expect(snapshots.first.episodes.map((e) => e.id), [1]);
      expect(snapshots.first.inFlight, isTrue);
      expect(snapshots.last.episodes.map((e) => e.id), [1, 2]);
      expect(snapshots.last.inFlight, isFalse);
    });
  });

  group('failure path', () {
    test('failed chunk keeps successes and records missing ids', () async {
      remote.failIfContains.add(21);
      final ids = [for (var i = 1; i <= 25; i++) i];

      final snapshot = await buildRepo().watchEpisodes(ids).last;

      expect(snapshot.episodes, hasLength(20));
      expect(snapshot.failedIds, {21, 22, 23, 24, 25});
      expect(remote.calls, 2);
    });

    test('cancel stops in-flight work', () async {
      remote.delay = const Duration(milliseconds: 80);
      final token = CancelToken();
      final errors = <Object>[];

      final done = Completer<void>();
      buildRepo()
          .watchEpisodes(const [1, 2, 3], cancelToken: token)
          .listen((_) {}, onError: errors.add, onDone: done.complete);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      token.cancel();
      await done.future;

      expect(errors, isNotEmpty);
      expect(errors.first, isA<CancelledFailure>());
    });
  });
}

class FakeEpisodeRemote implements EpisodeRemoteDataSource {
  var calls = 0;
  var current = 0;
  var maxConcurrent = 0;
  Duration delay = Duration.zero;
  final requestSizes = <List<int>>[];
  final failIfContains = <int>{};

  @override
  Future<List<EpisodeDto>> fetchByIds(
    List<int> ids, {
    CancelToken? cancelToken,
  }) async {
    calls++;
    current++;
    if (current > maxConcurrent) {
      maxConcurrent = current;
    }
    requestSizes.add(List<int>.of(ids));
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    current--;
    if (cancelToken?.isCancelled ?? false) {
      throw const CancelledFailure();
    }
    if (ids.any(failIfContains.contains)) {
      throw const ServerFailure(statusCode: 500);
    }
    return [for (final id in ids) _episode(id).toDto()];
  }
}

Episode _episode(int id) {
  final season = ((id - 1) ~/ 11) + 1;
  final number = ((id - 1) % 11) + 1;
  return Episode(
    id: id,
    name: 'Episode $id',
    airDate: 'January $id, 2014',
    code:
        'S${season.toString().padLeft(2, '0')}E${number.toString().padLeft(2, '0')}',
    url: 'https://example.com/api/episode/$id',
  );
}
