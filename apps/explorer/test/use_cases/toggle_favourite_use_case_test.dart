import 'package:explorer/use_cases/toggle_favourite_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';
import '../support/test_characters.dart';

void main() {
  test('toggles the character in the favourites repository', () async {
    final repository = FakeFavouritesRepository();
    final useCase = ToggleFavouriteUseCase(repository);
    final character = testCharacter();

    await useCase(character);
    expect(repository.stored, contains(character.id));

    await useCase(character);
    expect(repository.stored, isEmpty);
  });
}
