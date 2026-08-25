import 'dart:async';

import 'package:networking/networking.dart';
import 'package:thawani/thawani.dart';
import 'package:thawani_models/thawani_models.dart';

import 'test_characters.dart';

class FakeCharacterRepository implements CharacterRepository {
  final pageCalls = <({String query, int page})>[];
  final detailCalls = <int>[];
  Completer<void>? gate;
  Future<CharacterPageResult> Function(String query, int page)? onGetPage;
  Future<CharacterResult> Function(int id)? onGetCharacter;
  Object? pageError;
  Object? detailError;

  @override
  Future<CharacterPageResult> getPage({
    String query = '',
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    pageCalls.add((query: query, page: page));
    final pending = gate;
    if (pending != null) {
      await pending.future;
    }
    if (pageError != null) {
      throw pageError!;
    }
    if (onGetPage != null) {
      return onGetPage!(query, page);
    }
    return testPageResult();
  }

  @override
  Future<CharacterResult> getCharacter(
    int id, {
    CancelToken? cancelToken,
  }) async {
    detailCalls.add(id);
    final pending = gate;
    if (pending != null) {
      await pending.future;
    }
    if (detailError != null) {
      throw detailError!;
    }
    if (onGetCharacter != null) {
      return onGetCharacter!(id);
    }
    return testCharacterResult(character: testCharacter(id: id));
  }
}

class FakeFavouritesRepository implements FavouritesRepository {
  final stored = <int, Character>{};

  @override
  Future<List<Character>> getFavourites() async {
    return stored.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<bool> isFavourite(int id) async => stored.containsKey(id);

  @override
  Future<void> add(Character character) async {
    stored[character.id] = character;
  }

  @override
  Future<void> remove(int id) async {
    stored.remove(id);
  }

  @override
  Future<void> toggle(Character character) async {
    if (stored.containsKey(character.id)) {
      stored.remove(character.id);
    } else {
      stored[character.id] = character;
    }
  }
}
