import 'package:networking/networking.dart';
import 'package:thawani_models/thawani_models.dart';

class CharacterRemoteDataSource {
  CharacterRemoteDataSource(this._client);

  final ApiClient _client;

  Future<CharacterPageDto> fetchPage({
    String query = '',
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    final response = await _client.get<dynamic>(
      '/api/character',
      queryParameters: {
        'page': page,
        if (query.trim().isNotEmpty) 'name': query.trim(),
      },
      cancelToken: cancelToken,
    );

    return CharacterPageDto.fromJson(requireJsonMap(response.data));
  }

  Future<CharacterDto> fetchCharacter(
    int id, {
    CancelToken? cancelToken,
  }) async {
    final response = await _client.get<dynamic>(
      '/api/character/$id',
      cancelToken: cancelToken,
    );

    return CharacterDto.fromJson(requireJsonMap(response.data));
  }
}
