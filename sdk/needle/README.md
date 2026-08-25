# needle

Internal get_it re-export. App and SDK packages import `GetIt` / `sl` from here.

Registration stays in `apps/explorer/lib/di/`. This package does not register dependencies.

```dart
import 'package:needle/needle.dart';

sl.registerSingleton<Foo>(Foo());
final foo = sl<Foo>();
```
