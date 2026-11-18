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
    this.notificationsEnabled = true,
    this.notificationPermissionAsked = false,
    this.spikeAlerted = const {},
    this.language = 'ar',
  });

  static const double defaultThresholdPercent = 30;
  static const int schemaVersion = 1;

  final List<Meter> meters;
  final List<Reading> readings;
  final double thresholdPercent;

  /// 'system' | 'light' | 'dark'
  final String themeMode;

  /// The owner's preference; the OS permission is separate and checked at the moment of use.
  final bool notificationsEnabled;

  /// The OS permission dialog is shown at most once automatically.
  final bool notificationPermissionAsked;

  /// meterId -> id of the latest reading a spike notification was already sent for.
  final Map<String, String> spikeAlerted;

  /// 'ar' or 'en'.
  final String language;

  AppData copyWith({
    List<Meter>? meters,
    List<Reading>? readings,
    double? thresholdPercent,
    String? themeMode,
    bool? notificationsEnabled,
    bool? notificationPermissionAsked,
    Map<String, String>? spikeAlerted,
    String? language,
  }) =>
      AppData(
        meters: meters ?? this.meters,
        readings: readings ?? this.readings,
        thresholdPercent: thresholdPercent ?? this.thresholdPercent,
        themeMode: themeMode ?? this.themeMode,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        notificationPermissionAsked: notificationPermissionAsked ?? this.notificationPermissionAsked,
        spikeAlerted: spikeAlerted ?? this.spikeAlerted,
        language: language ?? this.language,
      );

  String encode() => jsonEncode({
        'version': schemaVersion,
        'meters': meters.map((m) => m.toJson()).toList(),
        'readings': readings.map((r) => r.toJson()).toList(),
        'thresholdPercent': thresholdPercent,
        'themeMode': themeMode,
        'notificationsEnabled': notificationsEnabled,
        'notificationPermissionAsked': notificationPermissionAsked,
        'spikeAlerted': spikeAlerted,
        'language': language,
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
        notificationsEnabled: (map['notificationsEnabled'] as bool?) ?? true,
        notificationPermissionAsked: (map['notificationPermissionAsked'] as bool?) ?? false,
        spikeAlerted: ((map['spikeAlerted'] as Map?) ?? const {}).map((k, v) => MapEntry(k as String, v as String)),
        language: (map['language'] as String?) == 'en' ? 'en' : 'ar',
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
