import 'package:dio/dio.dart';

import '../failures/remote_failure.dart';

RemoteFailure mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.cancel:
      return CancelledFailure(message: error.message);
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.connectionError:
      return NetworkFailure(message: error.message);
    case DioExceptionType.badResponse:
      return ServerFailure(
        message: error.message,
        statusCode: error.response?.statusCode,
      );
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return NetworkFailure(message: error.message);
  }
}

Map<String, dynamic> requireJsonMap(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data;
  }
  throw const ParseFailure(message: 'Expected a JSON object');
}

List<dynamic> requireJsonList(dynamic data) {
  if (data is List<dynamic>) {
    return data;
  }
  throw const ParseFailure(message: 'Expected a JSON array');
}
