import 'package:flutter_test/flutter_test.dart';
import 'package:thawani_models/thawani_models.dart';

void main() {
  group('CharacterDtoMapper', () {
    test('maps API character JSON to a domain Character', () {
      final character = CharacterDto.fromJson(_rickJson).toEntity();

      expect(character.id, 1);
      expect(character.name, 'Rick Sanchez');
      expect(character.status, CharacterStatus.alive);
      expect(character.species, 'Human');
      expect(character.type, '');
      expect(character.gender, CharacterGender.male);
      expect(character.origin.name, 'Earth (C-137)');
      expect(
        character.origin.url,
        'https://rickandmortyapi.com/api/location/1',
      );
      expect(character.location.name, 'Citadel of Ricks');
      expect(character.image, 'https://rickandmortyapi.com/api/character/avatar/1.jpeg');
      expect(character.episodeCount, 2);
      expect(character.episodeUrls, [
        'https://rickandmortyapi.com/api/episode/1',
        'https://rickandmortyapi.com/api/episode/2',
      ]);
      expect(character.created, DateTime.parse('2017-11-04T18:48:46.250Z'));
    });

    test('maps unknown status and gender instead of throwing', () {
      final character = CharacterDto.fromJson({
        ..._rickJson,
        'status': 'not-a-status',
        'gender': 'not-a-gender',
      }).toEntity();

      expect(character.status, CharacterStatus.unknown);
      expect(character.gender, CharacterGender.unknown);
    });

    test('treats missing origin and episode as empty defaults', () {
      final character = CharacterDto.fromJson({
        'id': 2,
        'name': 'Morty Smith',
      }).toEntity();

      expect(character.origin, const CharacterLocation(name: '', url: ''));
      expect(character.location, const CharacterLocation(name: '', url: ''));
      expect(character.episodeUrls, isEmpty);
      expect(character.created, isNull);
    });
  });

  group('CharacterPageDtoMapper', () {
    test('maps page JSON and parses next/prev page numbers from URLs', () {
      final page = CharacterPageDto.fromJson({
        'info': {
          'count': 826,
          'pages': 42,
          'next': 'https://rickandmortyapi.com/api/character?page=2',
          'prev': null,
        },
        'results': [_rickJson],
      }).toEntity();

      expect(page.info.count, 826);
      expect(page.info.pages, 42);
      expect(page.info.nextPage, 2);
      expect(page.info.prevPage, isNull);
      expect(page.info.hasNext, isTrue);
      expect(page.results, hasLength(1));
      expect(page.results.first.name, 'Rick Sanchez');
    });

    test('hasNext is false when next is null', () {
      final page = CharacterPageDto.fromJson({
        'info': {
          'count': 1,
          'pages': 1,
          'next': null,
          'prev': 'https://rickandmortyapi.com/api/character?page=1',
        },
        'results': <Map<String, dynamic>>[],
      }).toEntity();

      expect(page.info.hasNext, isFalse);
      expect(page.info.prevPage, 1);
      expect(page.results, isEmpty);
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
  'url': 'https://rickandmortyapi.com/api/character/1',
  'created': '2017-11-04T18:48:46.250Z',
};
