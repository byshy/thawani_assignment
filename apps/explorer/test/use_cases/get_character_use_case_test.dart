import 'package:explorer/use_cases/get_character_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  test('delegates detail fetch to the character repository', () async {
    final repository = FakeCharacterRepository();
    final useCase = GetCharacterUseCase(repository);

    final result = await useCase(42);

    expect(repository.detailCalls, [42]);
    expect(result.character.id, 42);
  });
}
