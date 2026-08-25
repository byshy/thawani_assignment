import 'package:thawani/thawani.dart';
import 'package:thawani_models/thawani_models.dart';

class ToggleFavouriteUseCase {
  ToggleFavouriteUseCase(this._repository);

  final FavouritesRepository _repository;

  Future<void> call(Character character) => _repository.toggle(character);
}
