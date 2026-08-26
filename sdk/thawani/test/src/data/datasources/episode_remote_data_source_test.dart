import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:networking/networking.dart';
import 'package:thawani/thawani.dart';
import 'package:thawani_models/thawani_models.dart';

void main() {
  late ApiClient client;
  late DioAdapter adapter;
  late EpisodeRemoteDataSourceImpl remote;

  setUp(() {
    client = ApiClient(baseUrl: 'https://example.com');
    adapter = DioAdapter(dio: client.dio);
    remote = EpisodeRemoteDataSourceImpl(client);
  });

  group('happy path', () {
    test('single id parses a JSON object', () async {
      adapter.onGet('/api/episode/1', (server) => server.reply(200, _pilot));

      final dtos = await remote.fetchByIds(const [1]);

      expect(dtos, hasLength(1));
      expect(dtos.single.toEntity().name, 'Pilot');
    });

    test('several ids parse a top-level JSON array', () async {
      adapter.onGet(
        '/api/episode/1,2',
        (server) => server.reply(200, [_pilot, _lawnmower]),
      );

      final dtos = await remote.fetchByIds(const [1, 2]);

      expect(dtos.map((dto) => dto.id), [1, 2]);
    });
  });

  group('edge cases', () {
    test('empty id list does not hit the network', () async {
      final dtos = await remote.fetchByIds(const []);
      expect(dtos, isEmpty);
    });

    test('single unknown id 404 becomes an empty list', () async {
      adapter.onGet(
        '/api/episode/99999',
        (server) => server.reply(404, {'error': 'Episode not found'}),
      );

      final dtos = await remote.fetchByIds(const [99999]);
      expect(dtos, isEmpty);
    });
  });

  group('failure path', () {
    test('non-json body becomes ParseFailure', () async {
      adapter.onGet('/api/episode/1', (server) => server.reply(200, 'nope'));

      expect(() => remote.fetchByIds(const [1]), throwsA(isA<ParseFailure>()));
    });

    test('server 500 is a ServerFailure', () async {
      adapter.onGet(
        '/api/episode/1',
        (server) => server.reply(500, {'error': 'boom'}),
      );

      expect(() => remote.fetchByIds(const [1]), throwsA(isA<ServerFailure>()));
    });
  });
}

const _pilot = {
  'id': 1,
  'name': 'Pilot',
  'air_date': 'December 2, 2013',
  'episode': 'S01E01',
  'url': 'https://example.com/api/episode/1',
};

const _lawnmower = {
  'id': 2,
  'name': 'Lawnmower Dog',
  'air_date': 'December 9, 2013',
  'episode': 'S01E02',
  'url': 'https://example.com/api/episode/2',
};
