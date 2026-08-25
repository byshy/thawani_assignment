import 'character_dto.dart';
import 'page_info_dto.dart';

class CharacterPageDto {
  const CharacterPageDto({
    required this.info,
    required this.results,
  });

  final PageInfoDto info;
  final List<CharacterDto> results;

  factory CharacterPageDto.fromJson(Map<String, dynamic> json) {
    return CharacterPageDto(
      info: PageInfoDto.fromJson(json['info'] as Map<String, dynamic>),
      results: (json['results'] as List<dynamic>?)
              ?.map((item) => CharacterDto.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
