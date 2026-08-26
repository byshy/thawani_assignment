import 'dart:io';

import 'package:explorer/config/flavor_config.dart';
import 'package:explorer/core/state/network_provider.dart';
import 'package:explorer/di/injection_container.dart';
import 'package:explorer/features/favourites/state/favourites_provider.dart';
import 'package:explorer/use_cases/get_characters_page_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_storage/local_storage.dart';
import 'package:needle/needle.dart';
import 'package:networking/networking.dart';
import 'package:thawani/thawani.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    await sl.reset();
    tempDir = await Directory.systemTemp.createTemp('explorer_di_');
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

  test('initSL registers flavor config, client, and repositories', () async {
    final config = FlavorConfig.dev();
    await initSL(config: config, storagePath: tempDir.path);

    expect(sl<FlavorConfig>(), same(config));
    expect(sl<ApiClient>().dio.options.baseUrl, config.baseUrl);
    expect(sl<CharacterRepository>(), isA<CharacterRepositoryImpl>());
    expect(sl<FavouritesRepository>(), isA<FavouritesRepositoryImpl>());
    expect(sl<EpisodeRepository>(), isA<EpisodeRepositoryImpl>());
    expect(sl.isRegistered<ConnectivityChecker>(), isTrue);
    expect(sl.isRegistered<GetCharactersPageUseCase>(), isTrue);
    expect(sl.isRegistered<NetworkProvider>(), isTrue);
    expect(sl.isRegistered<FavouritesProvider>(), isTrue);
  });
}
