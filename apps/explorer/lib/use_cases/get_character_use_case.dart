import 'package:thawani/thawani.dart';

class GetCharacterUseCase {
  GetCharacterUseCase(this._repository);

  final CharacterRepository _repository;

  Future<CharacterResult> call(int id) {
    return _repository.getCharacter(id);
  }
}
