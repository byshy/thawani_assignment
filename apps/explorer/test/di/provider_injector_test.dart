import 'package:explorer/core/state/network_provider.dart';
import 'package:explorer/di/provider_injector.dart';
import 'package:explorer/di/use_case_injector.dart';
import 'package:explorer/features/detail/state/character_detail_provider.dart';
import 'package:explorer/features/favourites/state/favourites_provider.dart';
import 'package:explorer/features/list/state/characters_list_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:needle/needle.dart';
import 'package:thawani/thawani.dart';

import '../support/fakes.dart';

void main() {
  setUp(() async {
    await sl.reset();
    sl.registerSingleton<CharacterRepository>(FakeCharacterRepository());
    sl.registerSingleton<FavouritesRepository>(FakeFavouritesRepository());
    registerUseCases();
  });

  tearDown(() async {
    await sl.reset();
  });

  test(
    'registerProviders registers network, favourites, list, and detail notifiers',
    () {
      registerProviders();

      expect(sl.isRegistered<NetworkProvider>(), isTrue);
      expect(sl<FavouritesProvider>(), isA<FavouritesProvider>());
      expect(sl.isRegistered<CharactersListProvider>(), isTrue);
      expect(sl.isRegistered<CharacterDetailProvider>(), isTrue);
    },
  );
}
