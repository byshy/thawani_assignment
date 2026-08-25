# thawani

Internal product/domain package: character repositories and data sources.

Use cases and DI registration stay in `apps/explorer`.

```dart
import 'package:thawani/thawani.dart';

final page = await characterRepository.getPage(query: 'rick', page: 1);
```
