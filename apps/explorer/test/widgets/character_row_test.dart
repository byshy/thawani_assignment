import 'package:explorer/widgets/character_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_characters.dart';

void main() {
  test('subtitleFor joins status and species', () {
    expect(CharacterRow.subtitleFor(testCharacter()), 'Alive · Human');
  });

  testWidgets('renders the character name and mapped subtitle', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CharacterRow(character: testCharacter(), isFavourite: false),
        ),
      ),
    );

    expect(find.text('Rick Sanchez'), findsOneWidget);
    expect(find.text('Alive · Human'), findsOneWidget);
  });
}
