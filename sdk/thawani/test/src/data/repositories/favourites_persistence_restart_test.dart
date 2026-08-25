import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:local_storage/local_storage.dart';
import 'package:thawani/thawani.dart';
import 'package:thawani_models/thawani_models.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('thawani_fav_restart_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  const character = Character(
    id: 1,
    name: 'Rick Sanchez',
    status: CharacterStatus.alive,
    species: 'Human',
    type: '',
    gender: CharacterGender.male,
    origin: CharacterLocation(name: 'Earth', url: 'https://example.com'),
    location: CharacterLocation(name: 'Citadel', url: ''),
    image: '',
    episodeUrls: ['https://example.com/api/episode/1'],
  );

  test('favourite survives reopening storage on the same path', () async {
    final storage1 = LocalStorage()..initPath(tempDir.path);
    addTearDown(storage1.close);
    final repo1 = FavouritesRepositoryImpl(FavouritesLocalDataSource(storage1));
    await repo1.toggle(character);
    await storage1.close();

    final storage2 = LocalStorage()..initPath(tempDir.path);
    addTearDown(storage2.close);
    final repo2 = FavouritesRepositoryImpl(FavouritesLocalDataSource(storage2));

    expect(await repo2.getFavourites(), [character]);
  });
}
