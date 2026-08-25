import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thawani_ui/thawani_ui.dart';

import '../../config/flavor_config.dart';
import '../../widgets/network_offline_banner.dart';
import 'state/characters_list_provider.dart';
import 'widgets/characters_list_body.dart';

class CharactersListScreen extends StatefulWidget {
  const CharactersListScreen({super.key});

  @override
  State<CharactersListScreen> createState() => _CharactersListScreenState();
}

class _CharactersListScreenState extends State<CharactersListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = context.read<FlavorConfig>();

    return Consumer<CharactersListProvider>(
      builder: (context, list, title) {
        return Scaffold(
          appBar: AppBar(
            title: title,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  ThawaniSpacing.md,
                  0,
                  ThawaniSpacing.md,
                  ThawaniSpacing.sm,
                ),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search characters',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: list.state.query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              list.onQueryChanged('');
                            },
                            icon: const Icon(Icons.clear),
                          ),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: list.onQueryChanged,
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              NetworkOfflineBanner(
                fromCache: list.state.fromCache,
                fetchedAt: list.state.fetchedAt,
              ),
              Expanded(child: CharactersListBody(list: list)),
            ],
          ),
        );
      },
      child: Text(config.appName),
    );
  }
}
