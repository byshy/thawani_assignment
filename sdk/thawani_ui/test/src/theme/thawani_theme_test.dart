import 'package:flutter_test/flutter_test.dart';
import 'package:thawani_ui/thawani_ui.dart';

void main() {
  test('light theme uses the Thawani primary seed', () {
    final theme = ThawaniTheme.light();

    expect(theme.colorScheme.primary, ThawaniColors.primary);
    expect(theme.scaffoldBackgroundColor, ThawaniColors.surface);
  });
}
