import 'package:explorer/app.dart';
import 'package:explorer/config/flavor_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the flavor app name and environment', (tester) async {
    await tester.pumpWidget(ExplorerApp(config: FlavorConfig.dev()));

    expect(find.text('Explorer Dev'), findsWidgets);
    expect(find.text('Development'), findsOneWidget);
  });
}
