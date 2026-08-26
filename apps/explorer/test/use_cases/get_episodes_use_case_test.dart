import 'package:explorer/use_cases/get_episodes_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  test('delegates episode fetch to the episode repository', () async {
    final repository = FakeEpisodeRepository();
    final useCase = GetEpisodesUseCase(repository);

    final snapshot = await useCase(const [1, 2]).first;

    expect(repository.watchedIds, [
      [1, 2],
    ]);
    expect(snapshot.episodes.map((episode) => episode.id), [1, 2]);
  });
}
