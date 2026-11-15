import 'package:flutter/material.dart';

import '../domain/app_data.dart';
import '../domain/consumption.dart';
import '../domain/models.dart';
import 'storage.dart';

/// The single source of truth the UI listens to. Every change is written to local storage first;
/// listeners are only notified after the write succeeded, so "saved on this device" is always true.
class AppStore extends ChangeNotifier {
  AppStore._(this._storage, this._data);

  static const storageKey = 'eaddady.data.v1';

  final KeyValueStorage _storage;
  AppData _data;
  int _lastId = 0;

  static Future<AppStore> load(KeyValueStorage storage) async {
    final raw = await storage.read(storageKey);
    var data = const AppData();
    if (raw != null && raw.isNotEmpty) {
      final decoded = AppData.tryDecode(raw);
      if (decoded == null) {
        // Unreadable document: keep the original text instead of silently overwriting it.
        await storage.write('$storageKey.unreadable', raw);
      } else {
        data = decoded;
      }
    }
    return AppStore._(storage, data);
  }

  List<Meter> get meters => List.unmodifiable(_data.meters);

  Meter? meterById(String? id) {
    for (final m in _data.meters) {
      if (m.id == id) return m;
    }
    return null;
  }

  List<Reading> readingsOf(String meterId) =>
      sortedReadings(_data.readings.where((r) => r.meterId == meterId));

  double get thresholdPercent => _data.thresholdPercent;

  ThemeMode get themeMode => switch (_data.themeMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  MeterAnalysis analysisOf(String meterId, {DateTime? now}) => analyzeMeter(
        readingsOf(meterId),
        thresholdPercent: thresholdPercent,
        now: now ?? DateTime.now(),
      );

  Future<Meter> addMeter({required UtilityType type, required String place, required String unit}) async {
    final meter = Meter(
      id: _newId(),
      type: type,
      place: place.trim(),
      unit: unit.trim().isEmpty ? type.defaultUnit : unit.trim(),
    );
    await _commit(_data.copyWith(meters: [..._data.meters, meter]));
    return meter;
  }

  /// Returns null when the reading was saved, otherwise why it was refused.
  Future<ReadingProblem?> addReading({
    required String meterId,
    required double? value,
    required DateTime at,
    required bool isReset,
  }) async {
    final problem = validateReading(
      existingSorted: readingsOf(meterId),
      value: value,
      at: at,
      isReset: isReset,
    );
    if (problem != null || value == null) return problem ?? ReadingProblem.invalidNumber;
    final reading = Reading(id: _newId(), meterId: meterId, value: value, at: at, isReset: isReset);
    await _commit(_data.copyWith(readings: [..._data.readings, reading]));
    return null;
  }

  /// Removes the meter and all of its readings.
  Future<void> deleteMeter(String meterId) => _commit(_data.copyWith(
        meters: _data.meters.where((m) => m.id != meterId).toList(),
        readings: _data.readings.where((r) => r.meterId != meterId).toList(),
      ));

  Future<void> setThresholdPercent(double percent) => _commit(_data.copyWith(thresholdPercent: percent));

  Future<void> setThemeMode(ThemeMode mode) => _commit(_data.copyWith(
        themeMode: switch (mode) {
          ThemeMode.light => 'light',
          ThemeMode.dark => 'dark',
          ThemeMode.system => 'system',
        },
      ));

  Future<void> _commit(AppData next) async {
    await _storage.write(storageKey, next.encode());
    _data = next;
    notifyListeners();
  }

  /// Strictly increasing, so ids sort in creation order.
  String _newId() {
    var id = DateTime.now().microsecondsSinceEpoch;
    if (id <= _lastId) id = _lastId + 1;
    _lastId = id;
    return id.toString();
  }
}
