import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thawani_ui/thawani_ui.dart';

import 'config/flavor_config.dart';
import 'routing/router.dart';
import 'routing/screens.dart';

class ExplorerApp extends StatelessWidget {
  const ExplorerApp({super.key, required this.config});

  final FlavorConfig config;

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: config,
      child: MaterialApp(
        title: config.appName,
        theme: ThawaniTheme.light(),
        initialRoute: Screens.shell,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
