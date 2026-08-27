import 'package:explorer/core/state/network_state.dart';
import 'package:explorer/features/detail/state/character_detail_provider.dart';
import 'package:explorer/use_cases/get_character_use_case.dart';
import 'package:explorer/use_cases/get_episodes_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:networking/networking.dart';

import '../../../support/fakes.dart';
import '../../../support/test_characters.dart';

void main() {
  CharacterDetailProvider buildProvider({
    FakeCharacterRepository? characters,
    FakeEpisodeRepository? episodes,
    FakeNetwork? network,
  }) {
    return CharacterDetailProvider(
      getCharacter: GetCharacterUseCase(
        characters ?? FakeCharacterRepository(),
      ),
      getEpisodes: GetEpisodesUseCase(episodes ?? FakeEpisodeRepository()),
      network: network?.provider,
    );
  }

  test('load sets the character from the use case', () async {
    final repository = FakeCharacterRepository();
    final provider = buildProvider(characters: repository);

    await provider.load(7);

    expect(provider.state.character?.id, 7);
    expect(provider.state.characterLoading, isFalse);
    expect(provider.state.characterErrorMessage, isNull);
    provider.dispose();
  });

  test('load without cache maps the failure for the UI', () async {
    final repository = FakeCharacterRepository()
      ..detailError = const NetworkFailure();
    final provider = buildProvider(characters: repository);

    await provider.load(7);

    expect(provider.state.character, isNull);
    expect(provider.state.characterErrorMessage, contains('internet'));
    provider.dispose();
  });

  test('reloads cached detail when connectivity returns', () async {
    final network = FakeNetwork();
    final repository = FakeCharacterRepository()
      ..onGetCharacter = (id) async {
        return testCharacterResult(fromCache: true);
      };
    final provider = buildProvider(characters: repository, network: network);

    await provider.load(7);
    expect(repository.detailCalls, [7]);

    network.emit(false);
    network.emit(true);
    await Future<void>.delayed(Duration.zero);

    expect(repository.detailCalls, [7, 7]);
    provider.dispose();
    await network.dispose();
  });

  test('reloads cached detail when connectivity is first resolved', () async {
    final network = FakeNetwork(initialStatus: NetworkStatus.unknown);
    final repository = FakeCharacterRepository()
      ..onGetCharacter = (id) async {
        return testCharacterResult(fromCache: true);
      };
    final provider = buildProvider(characters: repository, network: network);

    await provider.load(7);
    expect(repository.detailCalls, [7]);

    network.emit(true);
    await Future<void>.delayed(Duration.zero);

    expect(repository.detailCalls, [7, 7]);
    provider.dispose();
    await network.dispose();
  });

  test('load fetches episodes from character URLs', () async {
    final episodes = FakeEpisodeRepository();
    final provider = buildProvider(episodes: episodes);

    await provider.load(
      1,
      episodeUrls: const ['https://example.com/api/episode/1'],
    );
    await Future<void>.delayed(Duration.zero);

    expect(episodes.watchCalls, 1);
    expect(episodes.watchedIds.single, [1]);
    expect(provider.state.episodes.single.name, 'Pilot');
    expect(provider.state.episodeHttpCalls, 1);
    provider.dispose();
  });

  test(
    'retry missing keeps arrived episodes and asks only for failed ids',
    () async {
      const urls = [
        'https://example.com/api/episode/1',
        'https://example.com/api/episode/2',
      ];
      final characters = FakeCharacterRepository()
        ..onGetCharacter = (id) async {
          return testCharacterResult(
            character: testCharacter(id: id, episodeUrls: urls),
          );
        };
      final episodes = FakeEpisodeRepository()..failedIds = {2};
      final provider = buildProvider(
        characters: characters,
        episodes: episodes,
      );

      await provider.load(1, episodeUrls: urls);
      await Future<void>.delayed(Duration.zero);
      expect(provider.state.failedEpisodeIds, {2});
      expect(provider.state.episodes.single.id, 1);

      episodes.failedIds = {};
      await provider.retryMissingEpisodes();
      await Future<void>.delayed(Duration.zero);

      expect(episodes.watchedIds.last, [2]);
      expect(provider.state.episodes.map((e) => e.id), containsAll([1, 2]));
      expect(provider.state.failedEpisodeIds, isEmpty);
      provider.dispose();
    },
  );
}
