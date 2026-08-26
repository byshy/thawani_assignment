import 'package:needle/needle.dart';
import 'package:thawani/thawani.dart';

void registerDataSources() {
  sl.registerLazySingleton<CharacterRemoteDataSource>(
    () => CharacterRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<CharacterLocalDataSource>(
    () => CharacterLocalDataSource(sl()),
  );
  sl.registerLazySingleton<FavouritesLocalDataSource>(
    () => FavouritesLocalDataSource(sl()),
  );
  sl.registerLazySingleton<EpisodeRemoteDataSource>(
    () => EpisodeRemoteDataSourceImpl(sl()),
  );
}
