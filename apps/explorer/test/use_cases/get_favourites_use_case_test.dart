import 'package:explorer/use_cases/get_favourites_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';
import '../support/test_characters.dart';

void main() {
  test('returns favourites from the repository', () async {
    final repository = FakeFavouritesRepository()..stored[1] = testCharacter();
    final useCase = GetFavouritesUseCase(repository);

    final result = await useCase();

    expect(result, [testCharacter()]);
  });
}
