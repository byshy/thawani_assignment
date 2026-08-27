import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thawani_models/thawani_models.dart';
import 'package:thawani_ui/thawani_ui.dart';

import '../../widgets/network_offline_banner.dart';
import '../favourites/state/favourites_provider.dart';
import 'state/character_detail_provider.dart';
import 'widgets/character_fact.dart';
import 'widgets/episode_section.dart';

class CharacterDetailScreen extends StatelessWidget {
  const CharacterDetailScreen({super.key, required this.character});

  /// Snapshot from the list/favourites row; replaced when the provider loads.
  final Character character;

  @override
  Widget build(BuildContext context) {
    return Consumer<CharacterDetailProvider>(
      builder: (context, detail, _) {
        final character = detail.state.character ?? this.character;

        if (detail.state.characterLoading && detail.state.character == null) {
          return Scaffold(
            appBar: AppBar(title: Text(this.character.name)),
            body: const LoadingIndicator(),
          );
        }

        if (detail.state.characterErrorMessage != null &&
            detail.state.character == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Character')),
            body: ErrorState(
              message: detail.state.characterErrorMessage!,
              onRetry: detail.retry,
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(character.name),
            actions: [
              Consumer<FavouritesProvider>(
                builder: (context, favourites, _) {
                  return FavouriteButton(
                    isFavourite: favourites.contains(character.id),
                    onPressed: () {
                      unawaited(favourites.toggle(character));
                    },
                  );
                },
              ),
            ],
          ),
          body: Column(
              children: [
              NetworkOfflineBanner(fetchedAt: detail.state.characterFetchedAt),
              Expanded(
                child: ListView(
                  children: [
                    if (character.image.isNotEmpty)
                      Image.network(
                        character.image,
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox(height: 24),
                      ),
                    if (detail.state.characterLoading)
                      const LinearProgressIndicator(),
                    CharacterFact(
                      label: 'Status',
                      value: character.status.toApi(),
                    ),
                    CharacterFact(label: 'Species', value: character.species),
                    if (character.type.isNotEmpty)
                      CharacterFact(label: 'Type', value: character.type),
                    CharacterFact(
                      label: 'Gender',
                      value: character.gender.toApi(),
                    ),
                    CharacterFact(
                      label: 'Origin',
                      value: character.origin.name,
                    ),
                    CharacterFact(
                      label: 'Location',
                      value: character.location.name,
                    ),
                    CharacterFact(
                      label: 'Episodes',
                      value: '${character.episodeCount}',
                    ),
                    EpisodeSection(
                      episodes: detail.state.episodes,
                      loading: detail.state.episodesLoading,
                      failedCount: detail.state.failedEpisodeIds.length,
                      httpCalls: detail.state.episodeHttpCalls,
                      errorMessage: detail.state.episodesErrorMessage,
                      onRetryMissing: detail.retryMissingEpisodes,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
