import 'package:thawani_models/thawani_models.dart';

abstract interface class FavouritesRepository {
  Future<List<Character>> getFavourites();

  Future<bool> isFavourite(int id);

  Future<void> add(Character character);

  Future<void> remove(int id);

  Future<void> toggle(Character character);
}
