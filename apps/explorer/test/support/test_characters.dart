import 'package:thawani_models/thawani_models.dart';
import 'package:thawani/thawani.dart';

Character testCharacter({
  int id = 1,
  String name = 'Rick Sanchez',
  String species = 'Human',
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
    episodeUrls: const ['https://example.com/api/episode/1'],
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
