import 'package:thawani/thawani.dart';
import 'package:thawani_models/thawani_models.dart';

class GetFavouritesUseCase {
  GetFavouritesUseCase(this._repository);

  final FavouritesRepository _repository;

  Future<List<Character>> call() => _repository.getFavourites();
}
