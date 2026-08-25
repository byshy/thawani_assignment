import 'package:explorer/app.dart';
import 'package:explorer/config/flavor_config.dart';
import 'package:explorer/routing/router.dart';
import 'package:explorer/routing/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:needle/needle.dart';

import '../support/test_di.dart';

void main() {
  setUp(registerTestDependencies);

  tearDown(() async {
    await sl.reset();
  });

  testWidgets(
    'generateRoute wraps the shell in list and favourites providers',
    (tester) async {
      await tester.pumpWidget(ExplorerApp(config: FlavorConfig.dev()));
      await tester.pump();
      await tester.pump();

      expect(find.text('Search characters'), findsOneWidget);
      expect(find.text('Rick Sanchez'), findsOneWidget);
    },
  );

  testWidgets('character detail route wraps the screen in its providers', (
    tester,
  ) async {
    await tester.pumpWidget(ExplorerApp(config: FlavorConfig.dev()));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Rick Sanchez'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Origin'), findsOneWidget);
  });

  test('missing character argument shows a fallback', () {
    final route = AppRouter.generateRoute(
      const RouteSettings(name: Screens.characterDetail),
    );

    expect(route, isA<MaterialPageRoute<void>>());
  });
}
