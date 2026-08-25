import 'package:explorer/features/detail/state/character_detail_provider.dart';
import 'package:explorer/use_cases/get_character_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:networking/networking.dart';

import '../../../support/fakes.dart';
import '../../../support/test_characters.dart';

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

  test('reloads cached detail when connectivity returns', () async {
    final network = FakeNetwork();
    final repository = FakeCharacterRepository()
      ..onGetCharacter = (id) async {
        return testCharacterResult(fromCache: true);
      };
    final provider = CharacterDetailProvider(
      getCharacter: GetCharacterUseCase(repository),
      network: network.provider,
    );

    await provider.load(7);
    expect(repository.detailCalls, [7]);

    network.emit(false);
    network.emit(true);
    await Future<void>.delayed(Duration.zero);

    expect(repository.detailCalls, [7, 7]);
    provider.dispose();
    await network.dispose();
  });
}
