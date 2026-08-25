import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thawani_ui/thawani_ui.dart';

void main() {
  testWidgets('reports presses', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FavouriteButton(
            isFavourite: false,
            onPressed: () => taps++,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FavouriteButton));
    await tester.pump();

    expect(taps, 1);
  });
}
