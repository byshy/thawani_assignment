# thawani_models

Internal entities, Rick and Morty API DTOs, and explicit hand-written mappers.

`thawani`, `thawani_ui`, and `explorer` import types from here. This package has no HTTP, Hive, or widgets.

```dart
import 'package:thawani_models/thawani_models.dart';

final character = CharacterDto.fromJson(json).toEntity();
final page = CharacterPageDto.fromJson(json).toEntity();
```
