import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:local_storage/local_storage.dart';
import 'package:thawani/thawani.dart';
import 'package:thawani_models/thawani_models.dart';

void main() {
  late Directory tempDir;
  late LocalStorage storage;
  late FavouritesRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('thawani_fav_');
    storage = LocalStorage()..initPath(tempDir.path);
    repository = FavouritesRepositoryImpl(FavouritesLocalDataSource(storage));
  });

  tearDown(() async {
    await storage.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('toggle adds and removes a favourite', () async {
    const character = Character(
      id: 1,
      name: 'Rick Sanchez',
      status: CharacterStatus.alive,
      species: 'Human',
      type: '',
      gender: CharacterGender.male,
      origin: CharacterLocation(name: 'Earth', url: ''),
      location: CharacterLocation(name: 'Earth', url: ''),
      image: '',
    );

    await repository.toggle(character);
    expect(await repository.isFavourite(1), isTrue);
    expect(await repository.getFavourites(), [character]);

    await repository.toggle(character);
    expect(await repository.isFavourite(1), isFalse);
    expect(await repository.getFavourites(), isEmpty);
  });
}
