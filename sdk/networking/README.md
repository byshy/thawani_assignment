# networking

Internal Dio client, real internet reachability checks, and typed remote failures.

Feature-agnostic — no character endpoints. Remote data sources in `thawani` use this package.

```dart
import 'package:networking/networking.dart';

final client = ApiClient(baseUrl: appConfig.baseUrl); // from app / flavors
final online = await ConnectivityChecker().isOnline;
final json = requireJsonMap(response.data); // shared by remote data sources
```
