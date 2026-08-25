import '../dto/character_page_dto.dart';
import '../dto/page_info_dto.dart';
import '../entities/character_page.dart';
import '../entities/page_info.dart';
import 'character_mapper.dart';

extension CharacterPageDtoMapper on CharacterPageDto {
  CharacterPage toEntity() {
    return CharacterPage(
      info: info.toEntity(),
      results: results.map((dto) => dto.toEntity()).toList(),
    );
  }
}

extension CharacterPageEntityMapper on CharacterPage {
  CharacterPageDto toDto() {
    return CharacterPageDto(
      info: info.toDto(),
      results: results.map((character) => character.toDto()).toList(),
    );
  }
}

extension PageInfoDtoMapper on PageInfoDto {
  PageInfo toEntity() {
    return PageInfo(
      count: count,
      pages: pages,
      nextPage: pageNumberFromUrl(next),
      prevPage: pageNumberFromUrl(prev),
    );
  }
}

extension PageInfoEntityMapper on PageInfo {
  /// Rebuilds next/prev as query URLs so [pageNumberFromUrl] round-trips.
  PageInfoDto toDto() {
    return PageInfoDto(
      count: count,
      pages: pages,
      next: nextPage == null ? null : '?page=$nextPage',
      prev: prevPage == null ? null : '?page=$prevPage',
    );
  }
}

int? pageNumberFromUrl(String? url) {
  if (url == null || url.isEmpty) {
    return null;
  }
  return int.tryParse(Uri.parse(url).queryParameters['page'] ?? '');
}
