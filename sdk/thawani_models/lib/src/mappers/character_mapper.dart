import '../dto/character_dto.dart';
import '../dto/character_location_dto.dart';
import '../entities/character.dart';
import '../entities/character_location.dart';
import '../enums/character_gender.dart';
import '../enums/character_status.dart';

extension CharacterDtoMapper on CharacterDto {
  Character toEntity() {
    return Character(
      id: id,
      name: name,
      status: CharacterStatus.fromApi(status),
      species: species,
      type: type,
      gender: CharacterGender.fromApi(gender),
      origin: origin.toEntity(),
      location: location.toEntity(),
      image: image,
      episodeUrls: List<String>.unmodifiable(episode),
      created: created == null ? null : DateTime.tryParse(created!),
    );
  }
}

extension CharacterLocationDtoMapper on CharacterLocationDto {
  CharacterLocation toEntity() {
    return CharacterLocation(name: name, url: url);
  }
}
