import 'package:dio/dio.dart';
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

    test('requireJsonMap accepts a JSON object', () {
      expect(requireJsonMap({'id': 1}), {'id': 1});
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

    test('connection timeout becomes NetworkFailure', () {
      final failure = mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/api/character'),
          type: DioExceptionType.connectionTimeout,
          message: 'timed out',
        ),
      );

      expect(failure, isA<NetworkFailure>());
      expect(failure.message, 'timed out');
    });

    test('requireJsonMap rejects non-objects', () {
      expect(
        () => requireJsonMap(['not', 'a', 'map']),
        throwsA(isA<ParseFailure>()),
      );
    });
  });

  group('edge cases', () {
    test('cancelled request becomes CancelledFailure', () {
      final failure = mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/api/character'),
          type: DioExceptionType.cancel,
          message: 'cancelled',
        ),
      );

      expect(failure, isA<CancelledFailure>());
    });

    test('404 still maps to ServerFailure for the caller to interpret', () {
      final failure = mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/api/character'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/api/character'),
            statusCode: 404,
          ),
          message: 'not found',
        ),
      );

      expect(
        failure,
        isA<ServerFailure>().having((e) => e.statusCode, 'statusCode', 404),
      );
    });
  });
}
