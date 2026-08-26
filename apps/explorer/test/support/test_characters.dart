import 'package:thawani_models/thawani_models.dart';
import 'package:thawani/thawani.dart';

Episode testEpisode({
  int id = 1,
  String name = 'Pilot',
  String code = 'S01E01',
  String airDate = 'December 2, 2013',
}) {
  return Episode(
    id: id,
    name: name,
    airDate: airDate,
    code: code,
    url: 'https://example.com/api/episode/$id',
  );
}

Character testCharacter({
  int id = 1,
  String name = 'Rick Sanchez',
  String species = 'Human',
  List<String> episodeUrls = const ['https://example.com/api/episode/1'],
}) {
  return Character(
    id: id,
    name: name,
    status: CharacterStatus.alive,
    species: species,
    type: '',
    gender: CharacterGender.male,
    origin: const CharacterLocation(name: 'Earth', url: ''),
    location: const CharacterLocation(name: 'Citadel', url: ''),
    image: '',
    episodeUrls: episodeUrls,
  );
}

CharacterPageResult testPageResult({
  List<Character>? results,
  int? nextPage,
  bool fromCache = false,
  DateTime? fetchedAt,
}) {
  final items = results ?? [testCharacter()];
  return CharacterPageResult(
    page: CharacterPage(
      info: PageInfo(
        count: items.length,
        pages: nextPage == null ? 1 : 2,
        nextPage: nextPage,
      ),
      results: items,
    ),
    meta: CacheMeta(
      fetchedAt: fetchedAt ?? DateTime.utc(2024),
      fromCache: fromCache,
    ),
  );
}

CharacterResult testCharacterResult({
  Character? character,
  bool fromCache = false,
}) {
  return CharacterResult(
    character: character ?? testCharacter(),
    meta: CacheMeta(fetchedAt: DateTime.utc(2024), fromCache: fromCache),
  );
}
