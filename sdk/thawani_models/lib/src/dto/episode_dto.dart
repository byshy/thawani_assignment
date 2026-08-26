class EpisodeDto {
  const EpisodeDto({
    required this.id,
    required this.name,
    required this.airDate,
    required this.episode,
    this.url = '',
    this.created,
  });

  final int id;
  final String name;
  final String airDate;
  final String episode;
  final String url;
  final String? created;

  factory EpisodeDto.fromJson(Map<String, dynamic> json) {
    return EpisodeDto(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      airDate: json['air_date'] as String? ?? '',
      episode: json['episode'] as String? ?? '',
      url: json['url'] as String? ?? '',
      created: json['created'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'air_date': airDate,
      'episode': episode,
      'url': url,
      'created': created,
    };
  }
}

/// By-id episode responses are a JSON **object** (one id) or a top-level
/// **array** (several ids) — not `{info, results}`.
List<EpisodeDto> episodeDtosFromByIdResponse(dynamic json) {
  if (json is List) {
    return [
      for (final item in json) EpisodeDto.fromJson(_stringKeyedMap(item)),
    ];
  }
  if (json is Map) {
    return [EpisodeDto.fromJson(_stringKeyedMap(json))];
  }
  throw const FormatException('Expected episode object or JSON array');
}

Map<String, dynamic> _stringKeyedMap(dynamic json) {
  if (json is Map<String, dynamic>) {
    return json;
  }
  if (json is Map) {
    return Map<String, dynamic>.from(json);
  }
  throw const FormatException('Expected episode JSON object');
}
