import 'package:dio/dio.dart';

import '../mappers/dio_exception_mapper.dart';

/// Thin Dio wrapper. Feature endpoints live in `thawani`, not here.
/// [baseUrl] is supplied by the app (flavors / DI), not hardcoded here.
class ApiClient {
  ApiClient({
    required String baseUrl,
    Dio? dio,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 15),
  }) : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: connectTimeout,
                receiveTimeout: receiveTimeout,
                headers: const {'Accept': 'application/json'},
                responseType: ResponseType.json,
              ),
            );

  final Dio dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) {
    return _guard(
      () => dio.get<T>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      ),
    );
  }

  Future<Response<T>> _guard<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
