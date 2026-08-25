import 'package:flutter/material.dart';
import 'package:thawani_ui/thawani_ui.dart';

import 'config/flavor_config.dart';

class ExplorerApp extends StatelessWidget {
  const ExplorerApp({super.key, required this.config});

  final FlavorConfig config;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: config.appName,
      theme: ThawaniTheme.light(),
      home: Scaffold(
        appBar: AppBar(title: Text(config.appName)),
        body: Center(child: Text(config.environmentLabel)),
      ),
    );
  }
}
