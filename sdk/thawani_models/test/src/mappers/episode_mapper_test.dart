import 'package:flutter_test/flutter_test.dart';
import 'package:thawani_models/thawani_models.dart';

import 'episode_json.dart';

void main() {
  group('happy path', () {
    test('maps episode JSON to entity', () {
      final episode = EpisodeDto.fromJson(pilotJson).toEntity();

      expect(episode.id, 1);
      expect(episode.name, 'Pilot');
      expect(episode.airDate, 'December 2, 2013');
      expect(episode.code, 'S01E01');
      expect(episode.season, 1);
      expect(episode.episodeNumber, 1);
    });

    test('toJson round-trips', () {
      final dto = EpisodeDto.fromJson(pilotJson);
      final restored = EpisodeDto.fromJson(dto.toJson());

      expect(restored.id, dto.id);
      expect(restored.name, dto.name);
      expect(restored.airDate, dto.airDate);
      expect(restored.episode, dto.episode);
      expect(restored.toEntity(), dto.toEntity());
    });

    test('entity toDto round-trips through toEntity', () {
      final entity = EpisodeDto.fromJson(pilotJson).toEntity();
      expect(entity.toDto().toEntity(), entity);
    });

    test('parses a single-id JSON object', () {
      final dtos = episodeDtosFromByIdResponse(pilotJson);

      expect(dtos, hasLength(1));
      expect(dtos.single.id, 1);
    });

    test('parses a multi-id JSON array', () {
      final dtos = episodeDtosFromByIdResponse([pilotJson, lawnmowerJson]);

      expect(dtos.map((dto) => dto.id), [1, 2]);
    });
  });

  group('edge cases', () {
    test('unknown episode code maps season to 0', () {
      final episode = EpisodeDto.fromJson({
        ...pilotJson,
        'episode': 'special',
      }).toEntity();

      expect(episode.season, 0);
      expect(episode.episodeNumber, 1);
    });

    test('episodeIdsFromUrls keeps order and drops duplicates', () {
      expect(
        episodeIdsFromUrls(const [
          'https://rickandmortyapi.com/api/episode/3',
          'https://rickandmortyapi.com/api/episode/1',
          'https://rickandmortyapi.com/api/episode/3',
          'not-a-url',
        ]),
        [3, 1],
      );
    });
  });

  group('failure path', () {
    test('missing episode id throws', () {
      expect(
        () => EpisodeDto.fromJson({'name': 'Pilot'}),
        throwsA(isA<TypeError>()),
      );
    });

    test('by-id parser rejects paginated list shape as a map of results', () {
      expect(
        () => episodeDtosFromByIdResponse('not-json'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
