import 'package:needle/needle.dart';
import 'package:networking/networking.dart';

import '../core/state/network_provider.dart';
import '../features/detail/state/character_detail_provider.dart';
import '../features/favourites/state/favourites_provider.dart';
import '../features/list/state/characters_list_provider.dart';

void registerProviders() {
  sl.registerLazySingleton<NetworkProvider>(
    () => NetworkProvider.fromChecker(sl<ConnectivityChecker>()),
  );
  sl.registerLazySingleton<FavouritesProvider>(
    () => FavouritesProvider(getFavourites: sl(), toggleFavourite: sl()),
  );
  sl.registerFactory<CharactersListProvider>(
    () => CharactersListProvider(getPage: sl(), network: sl()),
  );
  sl.registerFactory<CharacterDetailProvider>(
    () => CharacterDetailProvider(getCharacter: sl(), network: sl()),
  );
}
