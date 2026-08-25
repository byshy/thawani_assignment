# local_storage

Internal Hive persistence facade. Repositories own cache policy and box names; this package owns how maps are stored.

```dart
import 'package:local_storage/local_storage.dart';

final storage = LocalStorage();
await storage.init(); // app / DI
await storage.putMap('favourites', '1', characterJson);
final cached = await storage.getMap('favourites', '1');
```
