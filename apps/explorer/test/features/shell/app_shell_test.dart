import 'package:explorer/config/flavor_config.dart';
import 'package:explorer/features/favourites/state/favourites_provider.dart';
import 'package:explorer/features/list/state/characters_list_provider.dart';
import 'package:explorer/features/shell/app_shell.dart';
import 'package:explorer/use_cases/get_characters_page_use_case.dart';
import 'package:explorer/use_cases/get_favourites_use_case.dart';
import 'package:explorer/use_cases/toggle_favourite_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:thawani_ui/thawani_ui.dart';

import '../../support/fakes.dart';

void main() {
  testWidgets('switches between list and favourites tabs', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: FlavorConfig.dev()),
          ChangeNotifierProvider(
            create: (_) => FavouritesProvider(
              getFavourites: GetFavouritesUseCase(FakeFavouritesRepository()),
              toggleFavourite: ToggleFavouriteUseCase(
                FakeFavouritesRepository(),
              ),
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => CharactersListProvider(
              getPage: GetCharactersPageUseCase(FakeCharacterRepository()),
              searchDebouncer: Debouncer(delay: Duration.zero),
            )..loadInitialIfNeeded(),
          ),
        ],
        child: const MaterialApp(home: AppShell()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Search characters'), findsOneWidget);

    await tester.tap(find.text('Favourites'));
    await tester.pump();

    expect(find.text('No favourites'), findsOneWidget);
  });
}
