import 'package:flutter/material.dart';

import '../theme/thawani_spacing.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.title,
  });

  /// Use when search returns no matches — pass a message that names the query.
  factory EmptyState.forQuery(String query) {
    final trimmed = query.trim();
    return EmptyState(
      title: 'No results',
      message: trimmed.isEmpty
          ? 'Nothing to show.'
          : 'No characters found for "$trimmed".',
    );
  }

  final String? title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThawaniSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: ThawaniSpacing.md),
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ThawaniSpacing.sm),
            ],
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
