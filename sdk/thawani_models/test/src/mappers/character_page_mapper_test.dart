import 'package:flutter_test/flutter_test.dart';
import 'package:thawani_models/thawani_models.dart';

import 'rick_json.dart';

void main() {
  group('happy path', () {
    test('maps page JSON and next page number from URL', () {
      final page = CharacterPageDto.fromJson({
        'info': {
          'count': 826,
          'pages': 42,
          'next': 'https://rickandmortyapi.com/api/character?page=2',
          'prev': null,
        },
        'results': [rickJson],
      }).toEntity();

      expect(page.info.nextPage, 2);
      expect(page.info.hasNext, isTrue);
      expect(page.results.single.name, 'Rick Sanchez');
    });

    test('page entity toDto round-trips page numbers', () {
      final page = CharacterPageDto.fromJson({
        'info': {
          'count': 826,
          'pages': 42,
          'next': 'https://rickandmortyapi.com/api/character?page=2',
          'prev': 'https://rickandmortyapi.com/api/character?page=1',
        },
        'results': [rickJson],
      }).toEntity();

      final restored = page.toDto().toEntity();
      expect(restored.info.nextPage, 2);
      expect(restored.info.prevPage, 1);
      expect(restored.results.single, page.results.single);
    });
  });

  group('edge cases', () {
    test('last page has no next and empty results stay empty', () {
      final page = CharacterPageDto.fromJson({
        'info': {'count': 0, 'pages': 1, 'next': null, 'prev': null},
        'results': <Map<String, dynamic>>[],
      }).toEntity();

      expect(page.info.hasNext, isFalse);
      expect(page.results, isEmpty);
    });
  });
}
