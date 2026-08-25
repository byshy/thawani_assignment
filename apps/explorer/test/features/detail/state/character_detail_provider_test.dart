import 'package:explorer/features/detail/state/character_detail_provider.dart';
import 'package:explorer/use_cases/get_character_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:networking/networking.dart';

import '../../../support/fakes.dart';

void main() {
  test('load sets the character from the use case', () async {
    final repository = FakeCharacterRepository();
    final provider = CharacterDetailProvider(
      getCharacter: GetCharacterUseCase(repository),
    );

    await provider.load(7);

    expect(provider.state.character?.id, 7);
    expect(provider.state.loading, isFalse);
    expect(provider.state.errorMessage, isNull);
    provider.dispose();
  });

  test('load without cache maps the failure for the UI', () async {
    final repository = FakeCharacterRepository()
      ..detailError = const NetworkFailure();
    final provider = CharacterDetailProvider(
      getCharacter: GetCharacterUseCase(repository),
    );

    await provider.load(7);

    expect(provider.state.character, isNull);
    expect(provider.state.errorMessage, contains('internet'));
    provider.dispose();
  });
}
