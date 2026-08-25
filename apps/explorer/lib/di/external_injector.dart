import 'package:local_storage/local_storage.dart';
import 'package:needle/needle.dart';
import 'package:networking/networking.dart';

import '../config/flavor_config.dart';

Future<void> registerExternal({String? storagePath}) async {
  final config = sl<FlavorConfig>();
  final storage = LocalStorage();
  if (storagePath != null) {
    storage.initPath(storagePath);
  } else {
    await storage.init();
  }
  sl.registerSingleton<LocalStorage>(storage);

  sl.registerLazySingleton<ApiClient>(() => ApiClient(baseUrl: config.baseUrl));
  sl.registerLazySingleton<ConnectivityChecker>(() => ConnectivityChecker());
}
