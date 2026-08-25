import 'package:flutter/material.dart';

import '../theme/thawani_colors.dart';
import '../theme/thawani_spacing.dart';
import 'favourite_button.dart';

/// List/favourites row: title + subtitle + optional image + favourite control.
class CharacterListTile extends StatelessWidget {
  const CharacterListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isFavourite,
    this.imageUrl,
    this.onTap,
    this.onFavouritePressed,
  });

  final String title;
  final String subtitle;
  final bool isFavourite;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onFavouritePressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ThawaniSpacing.md,
        vertical: ThawaniSpacing.xs,
      ),
      leading: _Avatar(imageUrl: imageUrl, title: title),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: ThawaniColors.onSurfaceVariant),
      ),
      trailing: FavouriteButton(
        isFavourite: isFavourite,
        onPressed: onFavouritePressed,
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.imageUrl, required this.title});

  final String? imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return CircleAvatar(child: Text(title.isEmpty ? '?' : title[0]));
    }

    return CircleAvatar(
      backgroundColor: ThawaniColors.outline,
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, _) {},
    );
  }
}
