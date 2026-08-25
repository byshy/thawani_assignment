import 'dart:async';

import 'package:explorer/features/list/state/characters_list_provider.dart';
import 'package:explorer/features/list/state/characters_list_state.dart';
import 'package:explorer/use_cases/get_characters_page_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:networking/networking.dart';
import 'package:thawani_ui/thawani_ui.dart';

import '../../../support/fakes.dart';
import '../../../support/test_characters.dart';

void main() {
  late FakeCharacterRepository repository;
  late CharactersListProvider provider;

  setUp(() {
    repository = FakeCharacterRepository();
    provider = CharactersListProvider(
      getPage: GetCharactersPageUseCase(repository),
      searchDebouncer: Debouncer(delay: Duration.zero),
    );
  });

  tearDown(() => provider.dispose());

  test('debounce: only the last query is fetched', () async {
    provider.onQueryChanged('r');
    provider.onQueryChanged('ri');
    provider.onQueryChanged('rick');
    await Future<void>.delayed(Duration.zero);

    expect(repository.pageCalls, [(query: 'rick', page: 1)]);
    expect(provider.state.query, 'rick');
    expect(provider.state.status, CharactersListStatus.data);
  });

  test('ignores a stale page response after a newer query', () async {
    final firstGate = Completer<void>();
    repository.onGetPage = (query, page) async {
      if (query == 'old') {
        await firstGate.future;
        return testPageResult(results: [testCharacter(name: 'Old')]);
      }
      return testPageResult(results: [testCharacter(name: 'New')]);
    };

    final stale = provider.search('old');
    final latest = provider.search('new');
    firstGate.complete();
    await stale;
    await latest;

    expect(provider.state.characters.single.name, 'New');
  });

  test('pagination does not duplicate in-flight page requests', () async {
    final nextGate = Completer<void>();
    repository.onGetPage = (query, page) async {
      if (page == 1) {
        return testPageResult(
          results: [testCharacter(id: 1, name: 'One')],
          nextPage: 2,
        );
      }
      await nextGate.future;
      return testPageResult(results: [testCharacter(id: 2, name: 'Two')]);
    };

    await provider.refresh();
    expect(provider.state.hasMore, isTrue);

    unawaited(provider.loadNextPage());
    unawaited(provider.loadNextPage());
    await Future<void>.delayed(Duration.zero);
    expect(repository.pageCalls.where((call) => call.page == 2), hasLength(1));

    nextGate.complete();
    await Future<void>.delayed(Duration.zero);
    expect(provider.state.characters.map((c) => c.name), ['One', 'Two']);
  });

  test('does not request past the last page', () async {
    repository.onGetPage = (query, page) async {
      return testPageResult(results: [testCharacter()]);
    };

    await provider.refresh();
    await provider.loadNextPage();

    expect(provider.state.hasMore, isFalse);
    expect(repository.pageCalls, [(query: '', page: 1)]);
  });

  test('search empty results use the empty status', () async {
    repository.onGetPage = (query, page) async {
      return testPageResult(results: const []);
    };

    await provider.search('zzzz');

    expect(provider.state.status, CharactersListStatus.empty);
  });

  test('failure without data shows error status', () async {
    repository.pageError = const NetworkFailure(message: 'offline');

    await provider.refresh();

    expect(provider.state.status, CharactersListStatus.error);
    expect(provider.state.errorMessage, contains('internet'));
  });

  test(
    'pagination failure keeps existing rows and sets a footer message',
    () async {
      repository.onGetPage = (query, page) async {
        if (page == 1) {
          return testPageResult(results: [testCharacter()], nextPage: 2);
        }
        throw const NetworkFailure(message: 'offline');
      };

      await provider.refresh();
      await provider.loadNextPage();

      expect(provider.state.status, CharactersListStatus.data);
      expect(provider.state.characters, isNotEmpty);
      expect(provider.state.paginationErrorMessage, contains('internet'));
      expect(provider.state.loadingMore, isFalse);
    },
  );
}
