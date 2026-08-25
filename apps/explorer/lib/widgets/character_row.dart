import 'package:flutter/material.dart';
import 'package:thawani_models/thawani_models.dart';
import 'package:thawani_ui/thawani_ui.dart';

class CharacterRow extends StatelessWidget {
  const CharacterRow({
    super.key,
    required this.character,
    required this.isFavourite,
    this.onTap,
    this.onFavouritePressed,
  });

  final Character character;
  final bool isFavourite;
  final VoidCallback? onTap;
  final VoidCallback? onFavouritePressed;

  static String subtitleFor(Character character) {
    return '${character.status.toApi()} · ${character.species}';
  }

  @override
  Widget build(BuildContext context) {
    return CharacterListTile(
      title: character.name,
      subtitle: subtitleFor(character),
      imageUrl: character.image.isEmpty ? null : character.image,
      isFavourite: isFavourite,
      onTap: onTap,
      onFavouritePressed: onFavouritePressed,
    );
  }
}
