# thawani_models

Internal entities, Rick and Morty API DTOs, and explicit hand-written bidirectional mappers.

`thawani` and `explorer` import types from here. This package has no HTTP, Hive, or widgets.

Episode by-id payloads are a JSON object (one id) or a top-level array (several ids). Use `episodeDtosFromByIdResponse`.

```dart
import 'package:thawani_models/thawani_models.dart';

final dto = CharacterDto.fromJson(json);
final character = dto.toEntity();
final again = character.toDto();
final cached = dto.toJson();
```
