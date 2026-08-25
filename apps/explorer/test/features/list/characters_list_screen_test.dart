import 'package:explorer/config/flavor_config.dart';
import 'package:explorer/features/favourites/state/favourites_provider.dart';
import 'package:explorer/features/list/state/characters_list_provider.dart';
import 'package:explorer/features/list/characters_list_screen.dart';
import 'package:explorer/use_cases/get_characters_page_use_case.dart';
import 'package:explorer/use_cases/get_favourites_use_case.dart';
import 'package:explorer/use_cases/toggle_favourite_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:networking/networking.dart';
import 'package:provider/provider.dart';
import 'package:thawani_ui/thawani_ui.dart';

import '../../support/fakes.dart';
import '../../support/test_characters.dart';

Widget _listHarness({
  required CharactersListProvider list,
  required FavouritesProvider favourites,
}) {
  return MultiProvider(
    providers: [
      Provider.value(value: FlavorConfig.dev()),
      ChangeNotifierProvider.value(value: favourites),
      ChangeNotifierProvider.value(value: list),
    ],
    child: const MaterialApp(home: CharactersListScreen()),
  );
}

void main() {
  testWidgets('favourite tap on a list row persists and updates the icon', (
    tester,
  ) async {
    final characters = FakeCharacterRepository();
    final favourites = FakeFavouritesRepository();
    final listProvider = CharactersListProvider(
      getPage: GetCharactersPageUseCase(characters),
      searchDebouncer: Debouncer(delay: Duration.zero),
    )..loadInitialIfNeeded();
    final favouritesProvider = FavouritesProvider(
      getFavourites: GetFavouritesUseCase(favourites),
      toggleFavourite: ToggleFavouriteUseCase(favourites),
    );

    await tester.pumpWidget(
      _listHarness(list: listProvider, favourites: favouritesProvider),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Rick Sanchez'), findsOneWidget);
    expect(find.byTooltip('Add favourite'), findsOneWidget);

    await tester.tap(find.byType(FavouriteButton));
    await tester.pump();
    await tester.pump();

    expect(find.byTooltip('Remove favourite'), findsOneWidget);
    expect(favouritesProvider.contains(testCharacter().id), isTrue);
    expect(favourites.stored, contains(testCharacter().id));
  });

  testWidgets('shows a retry footer when the next page fails', (tester) async {
    final characters = FakeCharacterRepository()
      ..onGetPage = (query, page) async {
        if (page == 1) {
          return testPageResult(results: [testCharacter()], nextPage: 2);
        }
        throw const NetworkFailure();
      };
    final listProvider = CharactersListProvider(
      getPage: GetCharactersPageUseCase(characters),
      searchDebouncer: Debouncer(delay: Duration.zero),
    );
    await listProvider.refresh();
    await listProvider.loadNextPage();

    await tester.pumpWidget(
      _listHarness(
        list: listProvider,
        favourites: FavouritesProvider(
          getFavourites: GetFavouritesUseCase(FakeFavouritesRepository()),
          toggleFavourite: ToggleFavouriteUseCase(FakeFavouritesRepository()),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Retry'), findsOneWidget);
  });
}
