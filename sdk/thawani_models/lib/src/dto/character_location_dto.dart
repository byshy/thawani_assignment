class CharacterLocationDto {
  const CharacterLocationDto({
    required this.name,
    required this.url,
  });

  final String name;
  final String url;

  factory CharacterLocationDto.fromJson(Map<String, dynamic>? json) {
    return CharacterLocationDto(
      name: json?['name'] as String? ?? '',
      url: json?['url'] as String? ?? '',
    );
  }
}
