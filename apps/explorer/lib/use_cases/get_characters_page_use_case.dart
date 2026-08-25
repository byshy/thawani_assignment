import 'package:thawani/thawani.dart';

class GetCharactersPageUseCase {
  GetCharactersPageUseCase(this._repository);

  final CharacterRepository _repository;

  Future<CharacterPageResult> call({String query = '', int page = 1}) {
    return _repository.getPage(query: query, page: page);
  }
}
