import 'dart:io';

import 'package:explorer/config/flavor_config.dart';
import 'package:explorer/di/injection_container.dart';
import 'package:explorer/features/favourites/state/favourites_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_storage/local_storage.dart';
import 'package:needle/needle.dart';
import 'package:thawani/thawani.dart';

import '../../support/test_characters.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('explorer_fav_persist_');
  });

  tearDown(() async {
    if (sl.isRegistered<LocalStorage>()) {
      await sl<LocalStorage>().close();
    }
    await sl.reset();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('favourite survives storage restart through provider toggle', () async {
    await initSL(config: FlavorConfig.dev(), storagePath: tempDir.path);
    final provider = sl<FavouritesProvider>();
    await provider.toggle(testCharacter());
    expect(await sl<FavouritesRepository>().isFavourite(1), isTrue);

    await sl<LocalStorage>().close();
    await sl.reset();

    await initSL(config: FlavorConfig.dev(), storagePath: tempDir.path);
    final reloaded = sl<FavouritesProvider>();
    await reloaded.load();
    expect(reloaded.contains(1), isTrue);
  });

  test('startup load does not undo a persisted favourite', () async {
    await initSL(config: FlavorConfig.dev(), storagePath: tempDir.path);
    final repository = sl<FavouritesRepository>();
    await repository.toggle(testCharacter());

    final provider = sl<FavouritesProvider>();
    await provider.load();

    expect(provider.contains(1), isTrue);
  });
}
