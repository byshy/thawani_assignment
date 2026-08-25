import '../enums/character_gender.dart';
import '../enums/character_status.dart';
import 'character_location.dart';

class Character {
  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.origin,
    required this.location,
    required this.image,
    this.episodeUrls = const [],
    this.created,
  });

  final int id;
  final String name;
  final CharacterStatus status;
  final String species;
  final String type;
  final CharacterGender gender;
  final CharacterLocation origin;
  final CharacterLocation location;
  final String image;
  final List<String> episodeUrls;
  final DateTime? created;

  int get episodeCount => episodeUrls.length;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Character &&
            id == other.id &&
            name == other.name &&
            status == other.status &&
            species == other.species &&
            type == other.type &&
            gender == other.gender &&
            origin == other.origin &&
            location == other.location &&
            image == other.image &&
            _listEquals(episodeUrls, other.episodeUrls) &&
            created == other.created;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        status,
        species,
        type,
        gender,
        origin,
        location,
        image,
        Object.hashAll(episodeUrls),
        created,
      );
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}
