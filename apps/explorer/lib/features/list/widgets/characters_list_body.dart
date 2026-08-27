import 'dart:async';

import 'package:flutter/material.dart';
import 'package:thawani_ui/thawani_ui.dart';

import '../state/characters_list_provider.dart';
import '../state/characters_list_state.dart';
import 'favourite_aware_row.dart';

class CharactersListBody extends StatelessWidget {
  const CharactersListBody({super.key, required this.list});

  final CharactersListProvider list;

  @override
  Widget build(BuildContext context) {
    final state = list.state;
    return switch (state.status) {
      CharactersListStatus.initialLoading => const LoadingIndicator(),
      CharactersListStatus.empty => RefreshIndicator(
        onRefresh: () => list.refresh(clear: false),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.5,
              child: EmptyState.forQuery(state.query),
            ),
          ],
        ),
      ),
      CharactersListStatus.error => ErrorState(
        message: state.errorMessage ?? 'Something went wrong. Please retry.',
        onRetry: list.retry,
      ),
      CharactersListStatus.data => RefreshIndicator(
        onRefresh: () => list.refresh(clear: false),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.extentAfter < 400) {
              unawaited(list.loadNextPage());
            }
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: ThawaniSpacing.lg),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount:
                state.characters.length +
                (state.loadingMore ? 1 : 0) +
                (state.paginationErrorMessage != null ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < state.characters.length) {
                return FavouriteAwareRow(character: state.characters[index]);
              }
              if (state.loadingMore) {
                return const ListLoadingFooter();
              }
              return ListTile(
                title: Text(state.paginationErrorMessage!),
                trailing: TextButton(
                  onPressed: list.loadNextPage,
                  child: const Text('Retry'),
                ),
              );
            },
          ),
        ),
      ),
    };
  }
}
