import 'package:explorer/features/detail/widgets/episode_debug_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the HTTP call count for this screen', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: EpisodeDebugOverlay(httpCalls: 3)),
      ),
    );

    expect(find.text('episode HTTP calls this screen: 3'), findsOneWidget);
  });
}
