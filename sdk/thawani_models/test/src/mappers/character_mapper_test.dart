import 'package:flutter_test/flutter_test.dart';
import 'package:thawani_models/thawani_models.dart';

import 'rick_json.dart';

void main() {
  group('happy path', () {
    test('maps character JSON to entity', () {
      final character = CharacterDto.fromJson(rickJson).toEntity();

      expect(character.id, 1);
      expect(character.name, 'Rick Sanchez');
      expect(character.status, CharacterStatus.alive);
      expect(character.gender, CharacterGender.male);
      expect(character.origin.name, 'Earth (C-137)');
      expect(character.episodeCount, 2);
      expect(character.created, DateTime.parse('2017-11-04T18:48:46.250Z'));
    });

    test('toJson round-trips for cache write/read', () {
      final dto = CharacterDto.fromJson(rickJson);
      final restored = CharacterDto.fromJson(dto.toJson());

      expect(restored.id, dto.id);
      expect(restored.name, dto.name);
      expect(restored.status, dto.status);
      expect(restored.origin.toJson(), dto.origin.toJson());
      expect(restored.episode, dto.episode);
      expect(restored.toEntity(), dto.toEntity());
    });

    test('character entity toDto round-trips through toEntity', () {
      final entity = CharacterDto.fromJson(rickJson).toEntity();
      expect(entity.toDto().toEntity(), entity);
    });
  });

  group('edge cases', () {
    test('unknown status and gender map to unknown', () {
      final character = CharacterDto.fromJson({
        ...rickJson,
        'status': 'not-a-status',
        'gender': 'not-a-gender',
      }).toEntity();

      expect(character.status, CharacterStatus.unknown);
      expect(character.gender, CharacterGender.unknown);
    });

    test('invalid created date becomes null', () {
      final character = CharacterDto.fromJson({
        ...rickJson,
        'created': 'not-a-date',
      }).toEntity();

      expect(character.created, isNull);
    });
  });

  group('failure path', () {
    test('missing character id throws', () {
      expect(
        () => CharacterDto.fromJson({'name': 'Rick Sanchez'}),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
