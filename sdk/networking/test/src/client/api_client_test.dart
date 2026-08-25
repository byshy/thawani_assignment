import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:networking/networking.dart';

void main() {
  group('happy path', () {
    test('ApiClient get returns response body', () async {
      final client = ApiClient(baseUrl: 'https://example.com');
      final adapter = DioAdapter(dio: client.dio);
      adapter.onGet(
        '/api/character',
        (server) => server.reply(200, {'ok': true}),
      );

      final response = await client.get<Map<String, dynamic>>('/api/character');

      expect(response.statusCode, 200);
      expect(response.data, {'ok': true});
    });
  });

  group('failure path', () {
    test('HTTP 500 becomes ServerFailure', () async {
      final client = ApiClient(baseUrl: 'https://example.com');
      final adapter = DioAdapter(dio: client.dio);
      adapter.onGet(
        '/api/character',
        (server) => server.reply(500, {'error': 'boom'}),
      );

      expect(
        () => client.get('/api/character'),
        throwsA(
          isA<ServerFailure>().having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });
  });
}
