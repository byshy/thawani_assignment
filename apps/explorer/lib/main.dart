import 'package:flutter/widgets.dart';

import 'app.dart';
import 'config/flavor_config.dart';
import 'di/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = FlavorConfig.fromEnvironment();
  await initSL(config: config);
  runApp(ExplorerApp(config: config));
}
