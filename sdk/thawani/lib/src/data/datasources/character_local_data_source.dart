import 'package:local_storage/local_storage.dart';
import 'package:thawani_models/thawani_models.dart';

import '../../domain/results.dart';
import '../storage_boxes.dart';

class CharacterLocalDataSource {
  CharacterLocalDataSource(this._storage);

  final LocalStorage _storage;

  Future<void> savePage({
    required String query,
    required int page,
    required CharacterPageDto dto,
    required DateTime fetchedAt,
  }) {
    return _storage.putMap(
      StorageBoxes.characterListCache,
      _pageKey(query, page),
      {
        'fetchedAt': fetchedAt.toIso8601String(),
        'payload': dto.toJson(),
      },
    );
  }

  Future<CharacterPageResult?> readPage({
    required String query,
    required int page,
  }) async {
    final raw = await _storage.getMap(
      StorageBoxes.characterListCache,
      _pageKey(query, page),
    );
    if (raw == null) {
      return null;
    }

    final fetchedAt = DateTime.tryParse(raw['fetchedAt'] as String? ?? '');
    final payload = raw['payload'];
    if (fetchedAt == null || payload is! Map) {
      return null;
    }

    final dto = CharacterPageDto.fromJson(Map<String, dynamic>.from(payload));
    return CharacterPageResult(
      page: dto.toEntity(),
      meta: CacheMeta(fetchedAt: fetchedAt),
    );
  }

  Future<void> saveCharacter({
    required CharacterDto dto,
    required DateTime fetchedAt,
  }) {
    return _storage.putMap(
      StorageBoxes.characterDetailCache,
      dto.id.toString(),
      {
        'fetchedAt': fetchedAt.toIso8601String(),
        'payload': dto.toJson(),
      },
    );
  }

  Future<CharacterResult?> readCharacter(int id) async {
    final raw = await _storage.getMap(
      StorageBoxes.characterDetailCache,
      id.toString(),
    );
    if (raw == null) {
      return null;
    }

    final fetchedAt = DateTime.tryParse(raw['fetchedAt'] as String? ?? '');
    final payload = raw['payload'];
    if (fetchedAt == null || payload is! Map) {
      return null;
    }

    final dto = CharacterDto.fromJson(Map<String, dynamic>.from(payload));
    return CharacterResult(
      character: dto.toEntity(),
      meta: CacheMeta(fetchedAt: fetchedAt),
    );
  }

  String _pageKey(String query, int page) {
    final normalized = query.trim().toLowerCase();
    return 'q=${Uri.encodeComponent(normalized)}&p=$page';
  }
}
