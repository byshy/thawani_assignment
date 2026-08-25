import 'package:flutter/material.dart';

import 'thawani_colors.dart';

abstract final class ThawaniTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ThawaniColors.primary,
        brightness: Brightness.light,
        primary: ThawaniColors.primary,
        onPrimary: ThawaniColors.onPrimary,
        surface: ThawaniColors.surface,
        onSurface: ThawaniColors.onSurface,
        error: ThawaniColors.error,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: ThawaniColors.surface,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      dividerTheme: const DividerThemeData(
        color: ThawaniColors.outline,
        space: 1,
        thickness: 1,
      ),
    );
  }
}
