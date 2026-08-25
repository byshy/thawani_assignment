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

int? pageNumberFromUrl(String? url) {
  if (url == null || url.isEmpty) {
    return null;
  }
  return int.tryParse(Uri.parse(url).queryParameters['page'] ?? '');
}
