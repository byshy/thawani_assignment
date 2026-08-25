import 'package:local_storage/local_storage.dart';
import 'package:thawani_models/thawani_models.dart';

import '../storage_boxes.dart';

class FavouritesLocalDataSource {
  FavouritesLocalDataSource(this._storage);

  final LocalStorage _storage;

  Future<List<Character>> getAll() async {
    final all = await _storage.getAllMaps(StorageBoxes.favourites);
    final characters = all.values
        .map((json) => CharacterDto.fromJson(json).toEntity())
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return characters;
  }

  Future<bool> contains(int id) {
    return _storage.containsKey(StorageBoxes.favourites, id.toString());
  }

  Future<void> put(Character character) {
    return _storage.putMap(
      StorageBoxes.favourites,
      character.id.toString(),
      character.toDto().toJson(),
    );
  }

  Future<void> remove(int id) {
    return _storage.delete(StorageBoxes.favourites, id.toString());
  }
}
