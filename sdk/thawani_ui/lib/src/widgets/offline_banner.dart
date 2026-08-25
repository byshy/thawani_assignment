import 'package:flutter/material.dart';

import '../theme/thawani_colors.dart';
import '../theme/thawani_spacing.dart';

/// Non-blocking banner: offline + age of the data currently shown.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    required this.fetchedAt,
  });

  final DateTime fetchedAt;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ThawaniColors.offlineBanner,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ThawaniSpacing.md,
          vertical: ThawaniSpacing.sm,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.cloud_off,
              size: 18,
              color: ThawaniColors.onOfflineBanner,
            ),
            const SizedBox(width: ThawaniSpacing.sm),
            Expanded(
              child: Text(
                'Offline — showing data from ${_formatAge(fetchedAt)}',
                style: const TextStyle(
                  color: ThawaniColors.onOfflineBanner,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatAge(DateTime fetchedAt) {
    final seconds = DateTime.now().difference(fetchedAt).inSeconds;
    if (seconds < 60) {
      return 'just now';
    }
    final minutes = seconds ~/ 60;
    if (minutes < 60) {
      return minutes == 1 ? '1 minute ago' : '$minutes minutes ago';
    }
    final hours = minutes ~/ 60;
    if (hours < 24) {
      return hours == 1 ? '1 hour ago' : '$hours hours ago';
    }
    final days = hours ~/ 24;
    return days == 1 ? '1 day ago' : '$days days ago';
  }
}
