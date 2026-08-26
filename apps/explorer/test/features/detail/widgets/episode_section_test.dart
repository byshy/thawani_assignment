import 'package:explorer/features/detail/widgets/episode_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_characters.dart';

void main() {
  testWidgets('groups episodes by season and shows the debug overlay', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EpisodeSection(
            episodes: [
              testEpisode(id: 1, name: 'Pilot', code: 'S01E01'),
              testEpisode(
                id: 12,
                name: 'A Rickle in Time',
                code: 'S02E01',
                airDate: 'July 26, 2015',
              ),
            ],
            loading: false,
            failedCount: 0,
            httpCalls: 3,
          ),
        ),
      ),
    );

    expect(find.text('Season 1'), findsOneWidget);
    expect(find.text('Season 2'), findsOneWidget);
    expect(find.text('Pilot'), findsOneWidget);
    expect(find.text('A Rickle in Time'), findsOneWidget);
    expect(find.text('episode HTTP calls this screen: 3'), findsOneWidget);
  });

  testWidgets('offers retry when some episodes failed', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EpisodeSection(
            episodes: [testEpisode()],
            loading: false,
            failedCount: 5,
            httpCalls: 2,
            errorMessage: 'Could not load 5 episodes.',
            onRetryMissing: () => retried = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Retry missing'));
    expect(retried, isTrue);
  });
}
