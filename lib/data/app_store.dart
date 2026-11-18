import 'package:flutter/material.dart';

import '../domain/app_data.dart';
import '../domain/consumption.dart';
import '../domain/csv_export.dart';
import '../domain/language.dart';
import '../domain/models.dart';
import '../domain/notifications.dart';
import '../domain/tariff.dart';
import 'storage.dart';

/// The single source of truth the UI listens to. Every change is written to local storage first;
/// listeners are only notified after the write succeeded, so "saved on this device" is always true.
class AppStore extends ChangeNotifier {
  AppStore._(this._storage, this._data, this._notifications, this._textsBuilder, this._exportSink);

  static const storageKey = 'addady.data.v1';

  final KeyValueStorage _storage;
  final NotificationCoordinator? _notifications;
  final NotificationTexts Function()? _textsBuilder;
  final ExportSink? _exportSink;
  AppData _data;
  int _lastId = 0;

  static Future<AppStore> load(
    KeyValueStorage storage, {
    NotificationCoordinator? notifications,
    NotificationTexts Function()? notificationTexts,
    ExportSink? exportSink,
  }) async {
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
    AppLanguage.code = data.language;
    return AppStore._(storage, data, notifications, notificationTexts, exportSink);
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

  /// 'ar' or 'en'.
  String get language => _data.language;

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
    await _afterReadingSaved(meterId);
    return null;
  }

  /// Changes the place, unit and optional local tariff of a meter. Readings are never touched.
  Future<void> updateMeter({
    required String meterId,
    required String place,
    required String unit,
    Tariff? tariff,
  }) async {
    final meters = [
      for (final m in _data.meters)
        if (m.id == meterId)
          m.copyWith(place: place.trim(), unit: unit.trim().isEmpty ? m.unit : unit.trim(), tariff: tariff, clearTariff: tariff == null)
        else
          m,
    ];
    await _commit(_data.copyWith(meters: meters));
    try {
      await syncNotifications();
    } catch (_) {}
  }

  /// Removes the meter and all of its readings.
  Future<void> deleteMeter(String meterId) async {
    await _commit(_data.copyWith(
      meters: _data.meters.where((m) => m.id != meterId).toList(),
      readings: _data.readings.where((r) => r.meterId != meterId).toList(),
      spikeAlerted: Map<String, String>.of(_data.spikeAlerted)..remove(meterId),
    ));
    await _notifications?.cancelMeter(meterId);
  }

  Future<void> setThresholdPercent(double percent) => _commit(_data.copyWith(thresholdPercent: percent));

  Future<void> setLanguage(String code) async {
    await _commit(_data.copyWith(language: code == 'en' ? 'en' : 'ar'));
    final n = _notifications;
    final builder = _textsBuilder;
    if (n != null && builder != null) {
      n.texts = builder();
      try {
        await syncNotifications();
      } catch (_) {}
    }
  }

  Future<void> setThemeMode(ThemeMode mode) => _commit(_data.copyWith(
        themeMode: switch (mode) {
          ThemeMode.light => 'light',
          ThemeMode.dark => 'dark',
          ThemeMode.system => 'system',
        },
      ));

  // ---- export ----------------------------------------------------------------------------------

  /// Builds the CSV of every meter and reading and hands it to the OS share sheet.
  /// [headers] are the 7 column titles in the active language.
  Future<ExportOutcome> exportCsv({required List<String> headers, DateTime? now}) async {
    final sink = _exportSink;
    if (sink == null) return ExportOutcome.failed;
    final byMeter = {for (final m in _data.meters) m.id: readingsOf(m.id)};
    if (byMeter.values.every((r) => r.isEmpty)) return ExportOutcome.nothingToExport;
    final d = now ?? DateTime.now();
    final stamp = '${d.year.toString().padLeft(4, '0')}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
    try {
      await sink.shareFile(
        filename: 'addady-readings-$stamp.csv',
        content: buildCsv(meters: _data.meters, sortedReadingsByMeter: byMeter, headers: headers),
        mimeType: 'text/csv',
      );
      return ExportOutcome.shared;
    } catch (_) {
      return ExportOutcome.failed;
    }
  }

  // ---- notifications -------------------------------------------------------------------------

  bool get notificationsEnabled => _data.notificationsEnabled;

  /// Non-null when the last notification operation failed (shown in settings).
  String? get notificationError => _notifications?.lastError;

  Future<bool> notificationsPermitted() async => await _notifications?.permissionGranted() ?? false;

  /// Re-arms the "reading due" reminders from the current data. Safe to call at any time (e.g. on every app start).
  Future<void> syncNotifications() async {
    final n = _notifications;
    if (n == null) return;
    await n.syncDueReminders(
      enabled: _data.notificationsEnabled,
      meters: _data.meters,
      sortedReadingsByMeter: {for (final m in _data.meters) m.id: readingsOf(m.id)},
      now: DateTime.now(),
    );
  }

  /// Returns false when the preference is on but the OS blocks notifications (the UI explains how to allow them).
  Future<bool> setNotificationsEnabled(bool enabled) async {
    await _commit(_data.copyWith(notificationsEnabled: enabled));
    var allowed = true;
    if (enabled) allowed = await _ensurePermission();
    await syncNotifications();
    return !enabled || allowed;
  }

  Future<bool> _ensurePermission() async {
    final n = _notifications;
    if (n == null) return false;
    if (await n.permissionGranted()) return true;
    final granted = await n.requestPermission();
    if (!_data.notificationPermissionAsked) {
      await _commit(_data.copyWith(notificationPermissionAsked: true));
    }
    return granted;
  }

  /// Never lets a notification problem fail a reading that was already saved.
  Future<void> _afterReadingSaved(String meterId) async {
    final n = _notifications;
    if (n == null) return;
    try {
      if (_data.notificationsEnabled && !_data.notificationPermissionAsked) {
        await _ensurePermission();
      }
      await syncNotifications();
      final meter = meterById(meterId);
      if (meter == null) return;
      final analysis = analysisOf(meterId);
      if (spikeNeedsAlert(analysis, _data.spikeAlerted[meterId])) {
        final shown = await n.notifySpike(enabled: _data.notificationsEnabled, meter: meter, analysis: analysis);
        if (shown) {
          await _commit(_data.copyWith(spikeAlerted: {..._data.spikeAlerted, meterId: analysis.latest!.id}));
        }
      }
    } catch (_) {
      // The reading is saved; the settings screen shows notificationError.
    }
  }

  Future<void> _commit(AppData next) async {
    await _storage.write(storageKey, next.encode());
    _data = next;
    AppLanguage.code = next.language; // before listeners rebuild, so every text is already in the new language
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
