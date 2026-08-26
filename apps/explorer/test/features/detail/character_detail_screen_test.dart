import 'package:explorer/features/detail/state/character_detail_provider.dart';
import 'package:explorer/features/detail/character_detail_screen.dart';
import 'package:explorer/features/favourites/state/favourites_provider.dart';
import 'package:explorer/use_cases/get_character_use_case.dart';
import 'package:explorer/use_cases/get_episodes_use_case.dart';
import 'package:explorer/use_cases/get_favourites_use_case.dart';
import 'package:explorer/use_cases/toggle_favourite_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../support/fakes.dart';
import '../../support/test_characters.dart';

void main() {
  testWidgets('shows richer character fields', (tester) async {
    final network = FakeNetwork();
    addTearDown(network.dispose);
    final character = testCharacter();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: network.provider),
          ChangeNotifierProvider(
            create: (_) => FavouritesProvider(
              getFavourites: GetFavouritesUseCase(FakeFavouritesRepository()),
              toggleFavourite: ToggleFavouriteUseCase(
                FakeFavouritesRepository(),
              ),
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => CharacterDetailProvider(
              getCharacter: GetCharacterUseCase(FakeCharacterRepository()),
              getEpisodes: GetEpisodesUseCase(FakeEpisodeRepository()),
            )..load(character.id, episodeUrls: character.episodeUrls),
          ),
        ],
        child: MaterialApp(home: CharacterDetailScreen(character: character)),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Rick Sanchez'), findsWidgets);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Species'), findsOneWidget);
    expect(find.text('Origin'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Episodes'), findsOneWidget);
    expect(find.text('Pilot'), findsOneWidget);
    expect(find.text('episode HTTP calls this screen: 1'), findsOneWidget);
  });
}
