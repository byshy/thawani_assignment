# explorer

Rick and Morty Explorer — Thawani Flutter assignment

## Run

From `apps/explorer`:

```bash
flutter pub get

flutter run --flavor dev
flutter run --flavor prod
```

Both flavors use the public Rick and Morty API. They differ by app name, Android application id / iOS bundle id, launcher icon, splash colour, and the in-app environment label.

Flutter **3.41.6** (Dart 3.11.4). Android was the device-side check; iOS schemes are wired.

```bash
flutter analyze --fatal-warnings
flutter test
```
