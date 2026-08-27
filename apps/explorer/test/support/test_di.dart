import 'dart:async';

import 'package:explorer/core/state/network_provider.dart';
import 'package:explorer/core/state/network_state.dart';
import 'package:explorer/di/use_case_injector.dart';
import 'package:explorer/features/detail/state/character_detail_provider.dart';
import 'package:explorer/features/favourites/state/favourites_provider.dart';
import 'package:explorer/features/list/state/characters_list_provider.dart';
import 'package:explorer/use_cases/get_character_use_case.dart';
import 'package:explorer/use_cases/get_characters_page_use_case.dart';
import 'package:explorer/use_cases/get_episodes_use_case.dart';
import 'package:explorer/use_cases/get_favourites_use_case.dart';
import 'package:explorer/use_cases/toggle_favourite_use_case.dart';
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
    () => FavouritesProvider(
      getFavourites: sl<GetFavouritesUseCase>(),
      toggleFavourite: sl<ToggleFavouriteUseCase>(),
    ),
  );
  sl.registerFactory<CharactersListProvider>(
    () => CharactersListProvider(
      getPage: sl<GetCharactersPageUseCase>(),
      network: sl<NetworkProvider>(),
      searchDebouncer: Debouncer(delay: Duration.zero),
    ),
  );
  sl.registerFactory<CharacterDetailProvider>(
    () => CharacterDetailProvider(
      getCharacter: sl<GetCharacterUseCase>(),
      getEpisodes: sl<GetEpisodesUseCase>(),
      network: sl<NetworkProvider>(),
    ),
  );
}
