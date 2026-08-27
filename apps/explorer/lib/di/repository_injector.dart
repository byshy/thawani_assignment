import 'package:needle/needle.dart';
import 'package:networking/networking.dart';
import 'package:thawani/thawani.dart';

void registerRepositories() {
  sl.registerLazySingleton<CharacterRepository>(
    () => CharacterRepositoryImpl(
      remote: sl<CharacterRemoteDataSource>(),
      local: sl<CharacterLocalDataSource>(),
      isOnline: () => sl<ConnectivityChecker>().isOnline,
    ),
  );
  sl.registerLazySingleton<FavouritesRepository>(
    () => FavouritesRepositoryImpl(sl<FavouritesLocalDataSource>()),
  );
  sl.registerLazySingleton<EpisodeRepository>(
    () => EpisodeRepositoryImpl(
      remote: sl<EpisodeRemoteDataSource>(),
      isOnline: () => sl<ConnectivityChecker>().isOnline,
    ),
  );
}
