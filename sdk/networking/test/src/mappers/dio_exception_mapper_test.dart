import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:networking/networking.dart';

void main() {
  group('happy path', () {
    test('requireJsonMap accepts a JSON object', () {
      expect(requireJsonMap({'id': 1}), {'id': 1});
    });

    test('requireJsonMap accepts Map with dynamic keys from Dio', () {
      final dynamic payload = <dynamic, dynamic>{'id': 1, 'name': 'Rick'};
      expect(requireJsonMap(payload), {'id': 1, 'name': 'Rick'});
    });
  });

  group('failure path', () {
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
