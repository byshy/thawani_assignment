import 'dart:async';

import 'package:explorer/core/state/network_provider.dart';
import 'package:explorer/core/state/network_state.dart';
import 'package:explorer/di/use_case_injector.dart';
import 'package:explorer/features/detail/state/character_detail_provider.dart';
import 'package:explorer/features/favourites/state/favourites_provider.dart';
import 'package:explorer/features/list/state/characters_list_provider.dart';
import 'package:needle/needle.dart';
import 'package:thawani/thawani.dart';
import 'package:thawani_ui/thawani_ui.dart';

import 'fakes.dart';

Future<void> registerTestDependencies({
  FakeCharacterRepository? characters,
  FakeFavouritesRepository? favourites,
  FakeEpisodeRepository? episodes,
  NetworkProvider? network,
}) async {
  await sl.reset();
  sl.registerSingleton<CharacterRepository>(
    characters ?? FakeCharacterRepository(),
  );
  sl.registerSingleton<FavouritesRepository>(
    favourites ?? FakeFavouritesRepository(),
  );
  sl.registerSingleton<EpisodeRepository>(episodes ?? FakeEpisodeRepository());
  registerUseCases();
  sl.registerLazySingleton<NetworkProvider>(
    () =>
        network ??
        NetworkProvider(
          onStatusChanged: const Stream.empty(),
          initialStatus: NetworkStatus.online,
        ),
  );
  sl.registerLazySingleton<FavouritesProvider>(
    () => FavouritesProvider(getFavourites: sl(), toggleFavourite: sl()),
  );
  sl.registerFactory<CharactersListProvider>(
    () => CharactersListProvider(
      getPage: sl(),
      network: sl(),
      searchDebouncer: Debouncer(delay: Duration.zero),
    ),
  );
  sl.registerFactory<CharacterDetailProvider>(
    () => CharacterDetailProvider(
      getCharacter: sl(),
      getEpisodes: sl(),
      network: sl(),
    ),
  );
}
