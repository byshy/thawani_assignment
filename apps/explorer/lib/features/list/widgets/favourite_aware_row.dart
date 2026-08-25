import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thawani_models/thawani_models.dart';

import '../../../routing/screens.dart';
import '../../../widgets/character_row.dart';
import '../../favourites/state/favourites_provider.dart';

class FavouriteAwareRow extends StatelessWidget {
  const FavouriteAwareRow({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return Consumer<FavouritesProvider>(
      builder: (context, favourites, _) {
        return CharacterRow(
          character: character,
          isFavourite: favourites.contains(character.id),
          onTap: () {
            Navigator.of(
              context,
            ).pushNamed(Screens.characterDetail, arguments: character);
          },
          onFavouritePressed: () {
            unawaited(favourites.toggle(character));
          },
        );
      },
    );
  }
}
