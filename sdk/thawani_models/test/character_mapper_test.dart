import 'package:flutter_test/flutter_test.dart';
import 'package:thawani_models/thawani_models.dart';

void main() {
  group('happy path', () {
    test('maps character JSON to entity', () {
      final character = CharacterDto.fromJson(_rickJson).toEntity();

      expect(character.id, 1);
      expect(character.name, 'Rick Sanchez');
      expect(character.status, CharacterStatus.alive);
      expect(character.gender, CharacterGender.male);
      expect(character.origin.name, 'Earth (C-137)');
      expect(character.episodeCount, 2);
      expect(character.created, DateTime.parse('2017-11-04T18:48:46.250Z'));
    });

    test('maps page JSON and next page number from URL', () {
      final page = CharacterPageDto.fromJson({
        'info': {
          'count': 826,
          'pages': 42,
          'next': 'https://rickandmortyapi.com/api/character?page=2',
          'prev': null,
        },
        'results': [_rickJson],
      }).toEntity();

      expect(page.info.nextPage, 2);
      expect(page.info.hasNext, isTrue);
      expect(page.results.single.name, 'Rick Sanchez');
    });

    test('toJson round-trips for cache write/read', () {
      final dto = CharacterDto.fromJson(_rickJson);
      final restored = CharacterDto.fromJson(dto.toJson());

      expect(restored.id, dto.id);
      expect(restored.name, dto.name);
      expect(restored.status, dto.status);
      expect(restored.origin.toJson(), dto.origin.toJson());
      expect(restored.episode, dto.episode);
      expect(restored.toEntity(), dto.toEntity());
    });

    test('character entity toDto round-trips through toEntity', () {
      final entity = CharacterDto.fromJson(_rickJson).toEntity();
      expect(entity.toDto().toEntity(), entity);
    });

    test('page entity toDto round-trips page numbers', () {
      final page = CharacterPageDto.fromJson({
        'info': {
          'count': 826,
          'pages': 42,
          'next': 'https://rickandmortyapi.com/api/character?page=2',
          'prev': 'https://rickandmortyapi.com/api/character?page=1',
        },
        'results': [_rickJson],
      }).toEntity();

      final restored = page.toDto().toEntity();
      expect(restored.info.nextPage, 2);
      expect(restored.info.prevPage, 1);
      expect(restored.results.single, page.results.single);
    });
  });

  group('edge cases', () {
    test('unknown status and gender map to unknown', () {
      final character = CharacterDto.fromJson({
        ..._rickJson,
        'status': 'not-a-status',
        'gender': 'not-a-gender',
      }).toEntity();

      expect(character.status, CharacterStatus.unknown);
      expect(character.gender, CharacterGender.unknown);
    });

    test('last page has no next and empty results stay empty', () {
      final page = CharacterPageDto.fromJson({
        'info': {
          'count': 0,
          'pages': 1,
          'next': null,
          'prev': null,
        },
        'results': <Map<String, dynamic>>[],
      }).toEntity();

      expect(page.info.hasNext, isFalse);
      expect(page.results, isEmpty);
    });

    test('invalid created date becomes null', () {
      final character = CharacterDto.fromJson({
        ..._rickJson,
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

const _rickJson = {
  'id': 1,
  'name': 'Rick Sanchez',
  'status': 'Alive',
  'species': 'Human',
  'type': '',
  'gender': 'Male',
  'origin': {
    'name': 'Earth (C-137)',
    'url': 'https://rickandmortyapi.com/api/location/1',
  },
  'location': {
    'name': 'Citadel of Ricks',
    'url': 'https://rickandmortyapi.com/api/location/3',
  },
  'image': 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
  'episode': [
    'https://rickandmortyapi.com/api/episode/1',
    'https://rickandmortyapi.com/api/episode/2',
  ],
  'created': '2017-11-04T18:48:46.250Z',
};
