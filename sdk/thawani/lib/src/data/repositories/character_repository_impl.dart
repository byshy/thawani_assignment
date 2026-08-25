import 'package:networking/networking.dart';
import 'package:thawani_models/thawani_models.dart';

import '../../domain/character_repository.dart';
import '../../domain/failures.dart';
import '../../domain/results.dart';
import '../datasources/character_local_data_source.dart';
import '../datasources/character_remote_data_source.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  CharacterRepositoryImpl({
    required CharacterRemoteDataSource remote,
    required CharacterLocalDataSource local,
    required Future<bool> Function() isOnline,
  })  : _remote = remote,
        _local = local,
        _isOnline = isOnline;

  final CharacterRemoteDataSource _remote;
  final CharacterLocalDataSource _local;
  final Future<bool> Function() _isOnline;

  @override
  Future<CharacterPageResult> getPage({
    String query = '',
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    final online = await _isOnline();
    if (!online) {
      return _cachedPageOrThrow(query: query, page: page);
    }

    try {
      final dto = await _remote.fetchPage(
        query: query,
        page: page,
        cancelToken: cancelToken,
      );
      final fetchedAt = DateTime.now();
      await _local.savePage(
        query: query,
        page: page,
        dto: dto,
        fetchedAt: fetchedAt,
      );
      return CharacterPageResult(
        page: dto.toEntity(),
        meta: CacheMeta(fetchedAt: fetchedAt, fromCache: false),
      );
    } on CancelledFailure {
      rethrow;
    } on ServerFailure catch (error) {
      if (error.statusCode == 404 && query.trim().isNotEmpty) {
        final fetchedAt = DateTime.now();
        return CharacterPageResult(
          page: const CharacterPage(
            info: PageInfo(count: 0, pages: 0),
            results: [],
          ),
          meta: CacheMeta(fetchedAt: fetchedAt, fromCache: false),
        );
      }
      return _cachedPageOrRethrow(query: query, page: page, error: error);
    } on RemoteFailure catch (error) {
      return _cachedPageOrRethrow(query: query, page: page, error: error);
    }
  }

  @override
  Future<CharacterResult> getCharacter(
    int id, {
    CancelToken? cancelToken,
  }) async {
    final online = await _isOnline();
    if (!online) {
      return _cachedCharacterOrThrow(id);
    }

    try {
      final dto = await _remote.fetchCharacter(id, cancelToken: cancelToken);
      final fetchedAt = DateTime.now();
      await _local.saveCharacter(dto: dto, fetchedAt: fetchedAt);
      return CharacterResult(
        character: dto.toEntity(),
        meta: CacheMeta(fetchedAt: fetchedAt, fromCache: false),
      );
    } on CancelledFailure {
      rethrow;
    } on RemoteFailure {
      final cached = await _local.readCharacter(id);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  Future<CharacterPageResult> _cachedPageOrThrow({
    required String query,
    required int page,
  }) async {
    final cached = await _local.readPage(query: query, page: page);
    if (cached != null) {
      return cached;
    }
    throw const NoCachedDataFailure();
  }

  Future<CharacterPageResult> _cachedPageOrRethrow({
    required String query,
    required int page,
    required RemoteFailure error,
  }) async {
    final cached = await _local.readPage(query: query, page: page);
    if (cached != null) {
      return cached;
    }
    throw error;
  }

  Future<CharacterResult> _cachedCharacterOrThrow(int id) async {
    final cached = await _local.readCharacter(id);
    if (cached != null) {
      return cached;
    }
    throw const NoCachedDataFailure();
  }
}
