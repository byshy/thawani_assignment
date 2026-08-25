import 'package:thawani_models/thawani_models.dart';

import '../../domain/favourites_repository.dart';
import '../datasources/favourites_local_data_source.dart';

class FavouritesRepositoryImpl implements FavouritesRepository {
  FavouritesRepositoryImpl(this._local);

  final FavouritesLocalDataSource _local;

  @override
  Future<List<Character>> getFavourites() => _local.getAll();

  @override
  Future<bool> isFavourite(int id) => _local.contains(id);

  @override
  Future<void> add(Character character) => _local.put(character);

  @override
  Future<void> remove(int id) => _local.remove(id);

  @override
  Future<void> toggle(Character character) async {
    final favourite = await _local.contains(character.id);
    if (favourite) {
      await _local.remove(character.id);
    } else {
      await _local.put(character);
    }
  }
}
