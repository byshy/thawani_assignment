import 'package:networking/networking.dart';
import 'package:thawani_models/thawani_models.dart';

abstract interface class EpisodeRemoteDataSource {
  Future<List<EpisodeDto>> fetchByIds(
    List<int> ids, {
    CancelToken? cancelToken,
  });
}

class EpisodeRemoteDataSourceImpl implements EpisodeRemoteDataSource {
  EpisodeRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<EpisodeDto>> fetchByIds(
    List<int> ids, {
    CancelToken? cancelToken,
  }) async {
    if (ids.isEmpty) {
      return const [];
    }

    try {
      final response = await _client.get<dynamic>(
        '/api/episode/${ids.join(',')}',
        cancelToken: cancelToken,
      );
      return episodeDtosFromByIdResponse(response.data);
    } on FormatException {
      throw const ParseFailure(message: 'Expected episode object or list');
    } on ServerFailure catch (error) {
      if (error.statusCode == 404) {
        return const [];
      }
      rethrow;
    }
  }
}
