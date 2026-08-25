import 'character_location_dto.dart';

class CharacterDto {
  const CharacterDto({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.origin,
    required this.location,
    required this.image,
    this.episode = const [],
    this.created,
  });

  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final CharacterLocationDto origin;
  final CharacterLocationDto location;
  final String image;
  final List<String> episode;
  final String? created;

  factory CharacterDto.fromJson(Map<String, dynamic> json) {
    return CharacterDto(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? '',
      species: json['species'] as String? ?? '',
      type: json['type'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      origin: CharacterLocationDto.fromJson(
        json['origin'] as Map<String, dynamic>?,
      ),
      location: CharacterLocationDto.fromJson(
        json['location'] as Map<String, dynamic>?,
      ),
      image: json['image'] as String? ?? '',
      episode: (json['episode'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          const [],
      created: json['created'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'type': type,
      'gender': gender,
      'origin': origin.toJson(),
      'location': location.toJson(),
      'image': image,
      'episode': episode,
      'created': created,
    };
  }
}
