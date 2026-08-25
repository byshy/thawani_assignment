import 'package:explorer/features/favourites/state/favourites_provider.dart';
import 'package:explorer/features/favourites/favourites_screen.dart';
import 'package:explorer/use_cases/get_favourites_use_case.dart';
import 'package:explorer/use_cases/toggle_favourite_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../support/fakes.dart';

void main() {
  testWidgets('shows an empty state when there are no favourites', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FavouritesProvider(
          getFavourites: GetFavouritesUseCase(FakeFavouritesRepository()),
          toggleFavourite: ToggleFavouriteUseCase(FakeFavouritesRepository()),
        ),
        child: const MaterialApp(home: FavouritesScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('No favourites'), findsOneWidget);
  });
}
