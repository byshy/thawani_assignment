import 'package:networking/networking.dart';

import 'results.dart';

abstract interface class CharacterRepository {
  Future<CharacterPageResult> getPage({
    String query = '',
    int page = 1,
    CancelToken? cancelToken,
  });

  Future<CharacterResult> getCharacter(
    int id, {
    CancelToken? cancelToken,
  });
}
