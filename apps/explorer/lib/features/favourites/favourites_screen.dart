import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thawani_ui/thawani_ui.dart';

import '../../routing/screens.dart';
import '../../widgets/character_row.dart';
import 'state/favourites_provider.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
      body: Consumer<FavouritesProvider>(
        builder: (context, favourites, _) {
          final state = favourites.state;
          if (state.loading) {
            return const LoadingIndicator();
          }
          if (state.errorMessage != null && state.items.isEmpty) {
            return ErrorState(
              message: state.errorMessage!,
              onRetry: favourites.load,
            );
          }
          if (state.items.isEmpty) {
            return const EmptyState(
              title: 'No favourites',
              message: 'Tap the heart on a character to save them here.',
            );
          }

          return ListView.builder(
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final character = state.items[index];
              return CharacterRow(
                character: character,
                isFavourite: true,
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
        },
      ),
    );
  }
}
