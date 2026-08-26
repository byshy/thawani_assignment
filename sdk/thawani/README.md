# thawani

Internal product/domain package: character and episode repositories and data sources.

- `CharacterRepository` — list/search/detail with offline cache orchestration
- `FavouritesRepository` — local favourites only
- `EpisodeRepository` — batched by-id fetch, in-memory cache, single-flight, concurrency cap
- Search HTTP `404` → empty page (not an error)

Use cases and DI registration stay in `apps/explorer`. DTO ↔ entity mapping stays in `thawani_models`.

```dart
import 'package:thawani/thawani.dart';

final page = await characterRepository.getPage(query: 'rick', page: 1);
```
