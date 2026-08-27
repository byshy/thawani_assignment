import 'package:needle/needle.dart';
import 'package:networking/networking.dart';

import '../core/state/network_provider.dart';
import '../features/detail/state/character_detail_provider.dart';
import '../features/favourites/state/favourites_provider.dart';
import '../features/list/state/characters_list_provider.dart';
import '../use_cases/get_character_use_case.dart';
import '../use_cases/get_characters_page_use_case.dart';
import '../use_cases/get_episodes_use_case.dart';
import '../use_cases/get_favourites_use_case.dart';
import '../use_cases/toggle_favourite_use_case.dart';

void registerProviders() {
  sl.registerLazySingleton<NetworkProvider>(
    () => NetworkProvider.fromChecker(sl<ConnectivityChecker>()),
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
