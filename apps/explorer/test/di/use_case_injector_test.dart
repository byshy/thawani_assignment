import 'package:explorer/di/use_case_injector.dart';
import 'package:explorer/use_cases/get_character_use_case.dart';
import 'package:explorer/use_cases/get_characters_page_use_case.dart';
import 'package:explorer/use_cases/get_favourites_use_case.dart';
import 'package:explorer/use_cases/toggle_favourite_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:needle/needle.dart';
import 'package:thawani/thawani.dart';

import '../support/fakes.dart';

void main() {
  setUp(() async {
    await sl.reset();
    sl.registerSingleton<CharacterRepository>(FakeCharacterRepository());
    sl.registerSingleton<FavouritesRepository>(FakeFavouritesRepository());
  });

  tearDown(() async {
    await sl.reset();
  });

  test('registerUseCases registers the explorer use cases', () {
    registerUseCases();

    expect(sl<GetCharactersPageUseCase>(), isA<GetCharactersPageUseCase>());
    expect(sl<GetCharacterUseCase>(), isA<GetCharacterUseCase>());
    expect(sl<GetFavouritesUseCase>(), isA<GetFavouritesUseCase>());
    expect(sl<ToggleFavouriteUseCase>(), isA<ToggleFavouriteUseCase>());
  });
}
