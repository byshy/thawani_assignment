import 'package:needle/needle.dart';
import 'package:thawani/thawani.dart';

import '../use_cases/get_character_use_case.dart';
import '../use_cases/get_characters_page_use_case.dart';
import '../use_cases/get_episodes_use_case.dart';
import '../use_cases/get_favourites_use_case.dart';
import '../use_cases/toggle_favourite_use_case.dart';

void registerUseCases() {
  sl.registerLazySingleton<GetCharactersPageUseCase>(
    () => GetCharactersPageUseCase(sl<CharacterRepository>()),
  );
  sl.registerLazySingleton<GetCharacterUseCase>(
    () => GetCharacterUseCase(sl<CharacterRepository>()),
  );
  sl.registerLazySingleton<GetFavouritesUseCase>(
    () => GetFavouritesUseCase(sl<FavouritesRepository>()),
  );
  sl.registerLazySingleton<ToggleFavouriteUseCase>(
    () => ToggleFavouriteUseCase(sl<FavouritesRepository>()),
  );
  sl.registerLazySingleton<GetEpisodesUseCase>(
    () => GetEpisodesUseCase(sl<EpisodeRepository>()),
  );
}
