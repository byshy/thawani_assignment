import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:local_storage/local_storage.dart';

void main() {
  late Directory tempDir;
  late LocalStorage storage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('local_storage_');
    storage = LocalStorage();
    storage.initPath(tempDir.path);
  });

  tearDown(() async {
    await storage.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('happy path', () {
    test('putMap and getMap round-trip', () async {
      await storage.putMap('favourites', '1', {
        'id': 1,
        'name': 'Rick Sanchez',
        'fetchedAt': '2017-11-04T18:48:46.250Z',
      });

      final cached = await storage.getMap('favourites', '1');

      expect(cached, {
        'id': 1,
        'name': 'Rick Sanchez',
        'fetchedAt': '2017-11-04T18:48:46.250Z',
      });
      expect(await storage.containsKey('favourites', '1'), isTrue);
    });

    test('nested maps round-trip with string keys after Hive read', () async {
      await storage.putMap('favourites', '1', {
        'id': 1,
        'name': 'Rick Sanchez',
        'origin': {'name': 'Earth', 'url': 'https://example.com'},
        'episode': ['https://example.com/api/episode/1'],
      });

      final cached = await storage.getMap('favourites', '1');

      expect(cached?['origin'], {
        'name': 'Earth',
        'url': 'https://example.com',
      });
      expect(cached?['episode'], ['https://example.com/api/episode/1']);
    });

    test('getAllMaps returns every map entry', () async {
      await storage.putMap('cache', 'page-1', {'page': 1});
      await storage.putMap('cache', 'page-2', {'page': 2});

      final all = await storage.getAllMaps('cache');

      expect(all.keys, containsAll(['page-1', 'page-2']));
      expect(all['page-1'], {'page': 1});
      expect(all['page-2'], {'page': 2});
    });
  });

  group('failure path', () {
    test('non-map value becomes StorageFailure', () async {
      final box = await Hive.openBox<dynamic>('bad-types');
      await box.put('broken', 'not-a-map');

      expect(
        () => storage.getMap('bad-types', 'broken'),
        throwsA(isA<StorageFailure>()),
      );
    });
  });

  group('edge cases', () {
    test('missing key returns null', () async {
      expect(await storage.getMap('empty', 'missing'), isNull);
      expect(await storage.containsKey('empty', 'missing'), isFalse);
    });

    test('delete removes a key', () async {
      await storage.putMap('favourites', '2', {'id': 2});
      await storage.delete('favourites', '2');

      expect(await storage.getMap('favourites', '2'), isNull);
    });

    test('clear empties a box', () async {
      await storage.putMap('cache', 'a', {'v': 1});
      await storage.putMap('cache', 'b', {'v': 2});
      await storage.clear('cache');

      expect(await storage.getAllMaps('cache'), isEmpty);
    });
  });
}
