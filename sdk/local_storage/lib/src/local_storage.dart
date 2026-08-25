import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'failures/storage_failure.dart';

/// Feature-agnostic keyed persistence. Callers own box names and value shapes.
class LocalStorage {
  LocalStorage({HiveInterface? hive}) : _hive = hive ?? Hive;

  final HiveInterface _hive;
  final Map<String, Box<dynamic>> _boxes = {};

  /// Initializes Hive using the app documents directory (Flutter).
  Future<void> init([String? subDir]) {
    return _hive.initFlutter(subDir);
  }

  /// Initializes Hive at a filesystem [path] (tests / non-Flutter hosts).
  void initPath(String path) {
    _hive.init(path);
  }

  Future<void> putMap(
    String boxName,
    String key,
    Map<String, dynamic> value,
  ) async {
    final box = await _box(boxName);
    await box.put(key, value);
  }

  Future<Map<String, dynamic>?> getMap(String boxName, String key) async {
    final box = await _box(boxName);
    final value = box.get(key);
    if (value == null) {
      return null;
    }
    return _asStringKeyedMap(value, boxName: boxName, key: key);
  }

  Future<void> delete(String boxName, String key) async {
    final box = await _box(boxName);
    await box.delete(key);
  }

  Future<bool> containsKey(String boxName, String key) async {
    final box = await _box(boxName);
    return box.containsKey(key);
  }

  /// All map entries in [boxName], keyed by their string keys.
  Future<Map<String, Map<String, dynamic>>> getAllMaps(String boxName) async {
    final box = await _box(boxName);
    final result = <String, Map<String, dynamic>>{};
    for (final key in box.keys) {
      final value = box.get(key);
      if (value == null) {
        continue;
      }
      result[key.toString()] = _asStringKeyedMap(
        value,
        boxName: boxName,
        key: key.toString(),
      );
    }
    return result;
  }

  Future<void> clear(String boxName) async {
    final box = await _box(boxName);
    await box.clear();
  }

  Future<void> close() async {
    await _hive.close();
    _boxes.clear();
  }

  Future<Box<dynamic>> _box(String name) async {
    final cached = _boxes[name];
    if (cached != null && cached.isOpen) {
      return cached;
    }
    final box = await _hive.openBox<dynamic>(name);
    _boxes[name] = box;
    return box;
  }

  Map<String, dynamic> _asStringKeyedMap(
    Object? value, {
    required String boxName,
    required String key,
  }) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    throw StorageFailure(
      message: 'Expected Map for key "$key" in box "$boxName"',
    );
  }
}
