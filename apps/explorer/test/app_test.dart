import 'package:explorer/app.dart';
import 'package:explorer/config/flavor_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:needle/needle.dart';

import 'support/test_di.dart';

void main() {
  setUp(registerTestDependencies);

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('shows the flavor app name and tab destinations', (tester) async {
    await tester.pumpWidget(ExplorerApp(config: FlavorConfig.dev()));
    await tester.pump();
    await tester.pump();

    expect(find.text('Explorer Dev'), findsWidgets);
    expect(find.text('Characters'), findsOneWidget);
    expect(find.text('Favourites'), findsOneWidget);
  });
}
