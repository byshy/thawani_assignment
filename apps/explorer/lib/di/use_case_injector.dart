import 'package:needle/needle.dart';

import '../use_cases/get_character_use_case.dart';
import '../use_cases/get_characters_page_use_case.dart';
import '../use_cases/get_favourites_use_case.dart';
import '../use_cases/toggle_favourite_use_case.dart';

void registerUseCases() {
  sl.registerLazySingleton<GetCharactersPageUseCase>(
    () => GetCharactersPageUseCase(sl()),
  );
  sl.registerLazySingleton<GetCharacterUseCase>(
    () => GetCharacterUseCase(sl()),
  );
  sl.registerLazySingleton<GetFavouritesUseCase>(
    () => GetFavouritesUseCase(sl()),
  );
  sl.registerLazySingleton<ToggleFavouriteUseCase>(
    () => ToggleFavouriteUseCase(sl()),
  );
}
