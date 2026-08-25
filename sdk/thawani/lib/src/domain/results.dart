import 'package:thawani_models/thawani_models.dart';

class CharacterPageResult {
  const CharacterPageResult({
    required this.page,
    required this.meta,
  });

  final CharacterPage page;
  final CacheMeta meta;
}

class CharacterResult {
  const CharacterResult({
    required this.character,
    required this.meta,
  });

  final Character character;
  final CacheMeta meta;
}
