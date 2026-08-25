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

extension CharacterEntityMapper on Character {
  CharacterDto toDto() {
    return CharacterDto(
      id: id,
      name: name,
      status: status.toApi(),
      species: species,
      type: type,
      gender: gender.toApi(),
      origin: origin.toDto(),
      location: location.toDto(),
      image: image,
      episode: List<String>.unmodifiable(episodeUrls),
      created: created?.toIso8601String(),
    );
  }
}

extension CharacterLocationDtoMapper on CharacterLocationDto {
  CharacterLocation toEntity() {
    return CharacterLocation(name: name, url: url);
  }
}

extension CharacterLocationEntityMapper on CharacterLocation {
  CharacterLocationDto toDto() {
    return CharacterLocationDto(name: name, url: url);
  }
}
