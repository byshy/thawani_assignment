import 'package:explorer/use_cases/get_characters_page_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  test('delegates page fetch to the character repository', () async {
    final repository = FakeCharacterRepository();
    final useCase = GetCharactersPageUseCase(repository);

    final result = await useCase(query: 'rick', page: 2);

    expect(repository.pageCalls, [(query: 'rick', page: 2)]);
    expect(result.page.results, isNotEmpty);
  });
}
