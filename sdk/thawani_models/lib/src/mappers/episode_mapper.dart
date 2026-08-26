import '../dto/episode_dto.dart';
import '../entities/episode.dart';

extension EpisodeDtoMapper on EpisodeDto {
  Episode toEntity() {
    return Episode(
      id: id,
      name: name,
      airDate: airDate,
      code: episode,
      url: url,
    );
  }
}

extension EpisodeEntityMapper on Episode {
  EpisodeDto toDto() {
    return EpisodeDto(
      id: id,
      name: name,
      airDate: airDate,
      episode: code,
      url: url,
    );
  }
}
