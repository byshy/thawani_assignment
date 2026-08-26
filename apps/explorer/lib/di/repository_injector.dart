import 'package:needle/needle.dart';
import 'package:networking/networking.dart';
import 'package:thawani/thawani.dart';

void registerRepositories() {
  sl.registerLazySingleton<CharacterRepository>(
    () => CharacterRepositoryImpl(
      remote: sl(),
      local: sl(),
      isOnline: () => sl<ConnectivityChecker>().isOnline,
    ),
  );
  sl.registerLazySingleton<FavouritesRepository>(
    () => FavouritesRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<EpisodeRepository>(
    () => EpisodeRepositoryImpl(
      remote: sl(),
      isOnline: () => sl<ConnectivityChecker>().isOnline,
    ),
  );
}
