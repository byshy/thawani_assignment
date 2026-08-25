import 'package:flutter/material.dart';

import '../theme/thawani_colors.dart';

class FavouriteButton extends StatelessWidget {
  const FavouriteButton({
    super.key,
    required this.isFavourite,
    required this.onPressed,
  });

  final bool isFavourite;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: isFavourite ? 'Remove favourite' : 'Add favourite',
      onPressed: onPressed,
      icon: Icon(
        isFavourite ? Icons.favorite : Icons.favorite_border,
        color: isFavourite ? ThawaniColors.favourite : null,
      ),
    );
  }
}
