import 'dart:io';

import 'package:explorer/config/flavor_config.dart';
import 'package:explorer/di/injection_container.dart';
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
    expect(sl.isRegistered<ConnectivityChecker>(), isTrue);
  });
}
