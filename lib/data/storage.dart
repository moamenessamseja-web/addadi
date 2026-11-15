import 'package:shared_preferences/shared_preferences.dart';

/// Minimal key-value persistence so the store can be tested without a device.
abstract class KeyValueStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

/// Real on-device storage (Android SharedPreferences). Everything stays local.
class PrefsStorage implements KeyValueStorage {
  PrefsStorage(this._prefs);

  final SharedPreferences _prefs;

  static Future<PrefsStorage> open() async => PrefsStorage(await SharedPreferences.getInstance());

  @override
  Future<String?> read(String key) async => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) async {
    final ok = await _prefs.setString(key, value);
    if (!ok) throw StateError('could not write $key');
  }
}

class MemoryStorage implements KeyValueStorage {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}
