import 'package:explorer/config/flavor_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dev flavor uses a distinct app name and the public API', () {
    final config = FlavorConfig.dev();

    expect(config.flavor, Flavor.dev);
    expect(config.appName, 'Explorer Dev');
    expect(config.environmentLabel, 'Development');
    expect(config.isDev, isTrue);
    expect(config.baseUrl, 'https://rickandmortyapi.com');
  });

  test('prod flavor uses the same public API without a name suffix', () {
    final config = FlavorConfig.prod();

    expect(config.flavor, Flavor.prod);
    expect(config.appName, 'Explorer');
    expect(config.environmentLabel, 'Production');
    expect(config.isDev, isFalse);
    expect(config.baseUrl, FlavorConfig.dev().baseUrl);
  });

  test('fromName maps aliases and defaults unknown values to prod', () {
    expect(FlavorConfig.fromName('dev').flavor, Flavor.dev);
    expect(FlavorConfig.fromName('development').flavor, Flavor.dev);
    expect(FlavorConfig.fromName('DEV').flavor, Flavor.dev);
    expect(FlavorConfig.fromName('prod').flavor, Flavor.prod);
    expect(FlavorConfig.fromName('production').flavor, Flavor.prod);
    expect(FlavorConfig.fromName('').flavor, Flavor.prod);
    expect(FlavorConfig.fromName('uat').flavor, Flavor.prod);
  });

  test('fromEnvironment prefers dart-define over the flavor flag', () {
    expect(
      FlavorConfig.fromEnvironment(dartDefine: 'dev', appFlavor: 'prod').isDev,
      isTrue,
    );
    expect(
      FlavorConfig.fromEnvironment(dartDefine: '', appFlavor: 'dev').isDev,
      isTrue,
    );
    expect(
      FlavorConfig.fromEnvironment(dartDefine: '', appFlavor: '').isDev,
      isFalse,
    );
  });
}
