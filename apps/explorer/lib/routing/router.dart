import 'dart:async';

import 'package:flutter/material.dart';
import 'package:needle/needle.dart';
import 'package:provider/provider.dart';
import 'package:thawani_models/thawani_models.dart';

import '../features/detail/state/character_detail_provider.dart';
import '../features/detail/character_detail_screen.dart';
import '../features/favourites/state/favourites_provider.dart';
import '../features/list/state/characters_list_provider.dart';
import '../features/shell/app_shell.dart';
import 'screens.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Screens.shell:
        final favourites = sl<FavouritesProvider>();
        unawaited(favourites.load());
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider<FavouritesProvider>.value(
                value: favourites,
              ),
              ChangeNotifierProvider(
                create: (_) =>
                    sl<CharactersListProvider>()..loadInitialIfNeeded(),
              ),
            ],
            child: const AppShell(),
          ),
        );
      case Screens.characterDetail:
        final character = settings.arguments as Character?;
        if (character == null) {
          return MaterialPageRoute<void>(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Character not provided')),
            ),
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider<FavouritesProvider>.value(
                value: sl<FavouritesProvider>(),
              ),
              ChangeNotifierProvider(
                create: (_) =>
                    sl<CharacterDetailProvider>()
                      ..load(character.id, episodeUrls: character.episodeUrls),
              ),
            ],
            child: CharacterDetailScreen(character: character),
          ),
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
