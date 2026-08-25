import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:local_storage/local_storage.dart';
import 'package:networking/networking.dart';
import 'package:thawani/thawani.dart';
import 'package:thawani_models/thawani_models.dart';

void main() {
  late Directory tempDir;
  late LocalStorage storage;
  late ApiClient client;
  late DioAdapter adapter;
  late CharacterRemoteDataSource remote;
  late CharacterLocalDataSource local;
  late bool online;

  CharacterRepositoryImpl buildRepo() {
    return CharacterRepositoryImpl(
      remote: remote,
      local: local,
      isOnline: () async => online,
    );
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('thawani_repo_');
    storage = LocalStorage()..initPath(tempDir.path);
    client = ApiClient(baseUrl: 'https://example.com');
    adapter = DioAdapter(dio: client.dio);
    remote = CharacterRemoteDataSource(client);
    local = CharacterLocalDataSource(storage);
    online = true;
  });

  tearDown(() async {
    await storage.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('happy path', () {
    test('success maps page and writes cache', () async {
      adapter.onGet(
        '/api/character',
        (server) => server.reply(200, _pageJson),
        queryParameters: {'page': 1},
      );

      final result = await buildRepo().getPage(page: 1);

      expect(result.meta.fromCache, isFalse);
      expect(result.page.results.single.name, 'Rick Sanchez');
      expect(result.page.info.nextPage, 2);

      final cached = await local.readPage(query: '', page: 1);
      expect(cached, isNotNull);
      expect(cached!.page.results.single.name, 'Rick Sanchez');
    });
  });

  group('failure path', () {
    test('failure without cache throws ServerFailure', () async {
      adapter.onGet(
        '/api/character',
        (server) => server.reply(500, {'error': 'boom'}),
        queryParameters: {'page': 1},
      );

      expect(
        () => buildRepo().getPage(page: 1),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('failure with cache returns cached page', () async {
      await local.savePage(
        query: '',
        page: 1,
        dto: CharacterPageDto.fromJson(_pageJson),
        fetchedAt: DateTime.utc(2020),
      );

      adapter.onGet(
        '/api/character',
        (server) => server.reply(500, {'error': 'boom'}),
        queryParameters: {'page': 1},
      );

      final result = await buildRepo().getPage(page: 1);

      expect(result.meta.fromCache, isTrue);
      expect(result.page.results.single.name, 'Rick Sanchez');
    });
  });

  group('edge cases', () {
    test('search 404 becomes empty page', () async {
      adapter.onGet(
        '/api/character',
        (server) => server.reply(404, {'error': 'There is nothing here'}),
        queryParameters: {'page': 1, 'name': 'zzzz'},
      );

      final result = await buildRepo().getPage(query: 'zzzz', page: 1);

      expect(result.page.results, isEmpty);
      expect(result.meta.fromCache, isFalse);
    });

    test('offline serves cache without remote call', () async {
      online = false;
      await local.savePage(
        query: '',
        page: 1,
        dto: CharacterPageDto.fromJson(_pageJson),
        fetchedAt: DateTime.utc(2021),
      );

      final result = await buildRepo().getPage(page: 1);

      expect(result.meta.fromCache, isTrue);
      expect(result.page.results.single.id, 1);
    });

    test('offline without cache throws NoCachedDataFailure', () async {
      online = false;

      expect(
        () => buildRepo().getPage(page: 1),
        throwsA(isA<NoCachedDataFailure>()),
      );
    });
  });
}

const _pageJson = {
  'info': {
    'count': 1,
    'pages': 2,
    'next': 'https://example.com/api/character?page=2',
    'prev': null,
  },
  'results': [
    {
      'id': 1,
      'name': 'Rick Sanchez',
      'status': 'Alive',
      'species': 'Human',
      'type': '',
      'gender': 'Male',
      'origin': {'name': 'Earth', 'url': ''},
      'location': {'name': 'Earth', 'url': ''},
      'image': 'https://example.com/avatar/1.jpeg',
      'episode': ['https://example.com/api/episode/1'],
      'created': '2017-11-04T18:48:46.250Z',
    },
  ],
};
