import 'package:explorer/features/favourites/state/favourites_provider.dart';
import 'package:explorer/use_cases/get_favourites_use_case.dart';
import 'package:explorer/use_cases/toggle_favourite_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fakes.dart';
import '../../../support/test_characters.dart';

void main() {
  test('toggle adds and removes a favourite and persists it', () async {
    final repository = FakeFavouritesRepository();
    final provider = FavouritesProvider(
      getFavourites: GetFavouritesUseCase(repository),
      toggleFavourite: ToggleFavouriteUseCase(repository),
    );
    final character = testCharacter();

    await provider.toggle(character);
    expect(provider.contains(character.id), isTrue);
    expect(repository.stored, contains(character.id));

    await provider.toggle(character);
    expect(provider.contains(character.id), isFalse);
    expect(repository.stored, isEmpty);
    provider.dispose();
  });
}
