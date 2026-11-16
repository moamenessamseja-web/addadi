/// Pure Dart: everything the app persists, as one JSON document.
library;

import 'dart:convert';

import 'models.dart';

class AppData {
  const AppData({
    this.meters = const [],
    this.readings = const [],
    this.thresholdPercent = defaultThresholdPercent,
    this.themeMode = 'system',
  });

  static const double defaultThresholdPercent = 30;
  static const int schemaVersion = 1;

  final List<Meter> meters;
  final List<Reading> readings;
  final double thresholdPercent;

  /// 'system' | 'light' | 'dark'
  final String themeMode;

  AppData copyWith({
    List<Meter>? meters,
    List<Reading>? readings,
    double? thresholdPercent,
    String? themeMode,
  }) =>
      AppData(
        meters: meters ?? this.meters,
        readings: readings ?? this.readings,
        thresholdPercent: thresholdPercent ?? this.thresholdPercent,
        themeMode: themeMode ?? this.themeMode,
      );

  String encode() => jsonEncode({
        'version': schemaVersion,
        'meters': meters.map((m) => m.toJson()).toList(),
        'readings': readings.map((r) => r.toJson()).toList(),
        'thresholdPercent': thresholdPercent,
        'themeMode': themeMode,
      });

  /// Returns null when [text] is not a readable document (so the caller can keep a backup instead of overwriting it).
  static AppData? tryDecode(String text) {
    try {
      final map = jsonDecode(text) as Map<String, Object?>;
      return AppData(
        meters: ((map['meters'] as List?) ?? const [])
            .map((e) => Meter.fromJson((e as Map).cast<String, Object?>()))
            .toList(),
        readings: ((map['readings'] as List?) ?? const [])
            .map((e) => Reading.fromJson((e as Map).cast<String, Object?>()))
            .toList(),
        thresholdPercent: (map['thresholdPercent'] as num?)?.toDouble() ?? defaultThresholdPercent,
        themeMode: (map['themeMode'] as String?) ?? 'system',
      );
    } catch (_) {
      return null;
    }
  }

  /// Empty or missing text yields an empty [AppData]; unreadable text also does (use [tryDecode] to tell them apart).
  static AppData decode(String? text) {
    if (text == null || text.isEmpty) return const AppData();
    return tryDecode(text) ?? const AppData();
  }
}
