import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thawani_ui/thawani_ui.dart';

void main() {
  testWidgets('shows title, subtitle, and favourite control', (tester) async {
    var favourited = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CharacterListTile(
            title: 'Rick Sanchez',
            subtitle: 'Alive',
            isFavourite: false,
            onFavouritePressed: () => favourited = true,
          ),
        ),
      ),
    );

    expect(find.text('Rick Sanchez'), findsOneWidget);
    expect(find.text('Alive'), findsOneWidget);

    await tester.tap(find.byType(FavouriteButton));
    await tester.pump();

    expect(favourited, isTrue);
  });
}
