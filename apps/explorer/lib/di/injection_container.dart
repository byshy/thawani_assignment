import 'package:needle/needle.dart';

import '../config/flavor_config.dart';
import 'datasource_injector.dart';
import 'external_injector.dart';
import 'provider_injector.dart';
import 'repository_injector.dart';
import 'use_case_injector.dart';

Future<void> initSL({required FlavorConfig config, String? storagePath}) async {
  sl.registerSingleton<FlavorConfig>(config);
  await registerExternal(storagePath: storagePath);
  registerDataSources();
  registerRepositories();
  registerUseCases();
  registerProviders();
}
