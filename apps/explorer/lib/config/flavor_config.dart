/// App environment. Both flavors share the public Rick and Morty API.
enum Flavor { dev, prod }

class FlavorConfig {
  const FlavorConfig({
    required this.flavor,
    required this.appName,
    required this.baseUrl,
  });

  factory FlavorConfig.dev() {
    return const FlavorConfig(
      flavor: Flavor.dev,
      appName: 'Explorer Dev',
      baseUrl: _rickAndMortyBaseUrl,
    );
  }

  factory FlavorConfig.prod() {
    return const FlavorConfig(
      flavor: Flavor.prod,
      appName: 'Explorer',
      baseUrl: _rickAndMortyBaseUrl,
    );
  }

  /// Resolves config from `--dart-define=flavor=` and `--flavor`.
  ///
  /// Prefers an explicit dart-define. If that is absent, uses the Flutter
  /// flavor flag (`FLUTTER_APP_FLAVOR`). Missing or unknown values fall back
  /// to production.
  factory FlavorConfig.fromEnvironment({
    String dartDefine = const String.fromEnvironment('flavor'),
    String appFlavor = const String.fromEnvironment('FLUTTER_APP_FLAVOR'),
  }) {
    return FlavorConfig.fromName(
      dartDefine.trim().isNotEmpty ? dartDefine : appFlavor,
    );
  }

  factory FlavorConfig.fromName(String raw) {
    final normalized = raw.trim().toLowerCase().replaceAll('-', '_');
    if (normalized == 'dev' || normalized == 'development') {
      return FlavorConfig.dev();
    }
    return FlavorConfig.prod();
  }

  static const _rickAndMortyBaseUrl = 'https://rickandmortyapi.com';

  final Flavor flavor;
  final String appName;
  final String baseUrl;

  String get environmentLabel => switch (flavor) {
    Flavor.dev => 'Development',
    Flavor.prod => 'Production',
  };

  bool get isDev => flavor == Flavor.dev;
}
