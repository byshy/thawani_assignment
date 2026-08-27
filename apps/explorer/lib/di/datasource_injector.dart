import 'package:local_storage/local_storage.dart';
import 'package:needle/needle.dart';
import 'package:networking/networking.dart';
import 'package:thawani/thawani.dart';

void registerDataSources() {
  sl.registerLazySingleton<CharacterRemoteDataSource>(
    () => CharacterRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<CharacterLocalDataSource>(
    () => CharacterLocalDataSource(sl<LocalStorage>()),
  );
  sl.registerLazySingleton<FavouritesLocalDataSource>(
    () => FavouritesLocalDataSource(sl<LocalStorage>()),
  );
  sl.registerLazySingleton<EpisodeRemoteDataSource>(
    () => EpisodeRemoteDataSourceImpl(sl<ApiClient>()),
  );
}
