/// Pure Dart (no Flutter imports): the data model of Ɛaddady.
library;

import 'language.dart';
import 'tariff.dart';

enum UtilityType { electricity, water, gas }

extension UtilityTypeInfo on UtilityType {
  /// Default unit; the unit actually used is stored on each meter.
  String get defaultUnit => switch (this) {
        UtilityType.electricity => 'kWh',
        UtilityType.water => 'm³',
        UtilityType.gas => 'm³',
      };

  /// Name of the utility in the active language.
  String get label => switch (this) {
        UtilityType.electricity => AppLanguage.isArabic ? 'كهرباء' : 'Electricity',
        UtilityType.water => AppLanguage.isArabic ? 'مياه' : 'Water',
        UtilityType.gas => AppLanguage.isArabic ? 'غاز' : 'Gas',
      };
}

UtilityType utilityTypeFromName(String? name) => UtilityType.values.firstWhere(
      (t) => t.name == name,
      orElse: () => UtilityType.electricity,
    );

/// One physical meter. Two electricity meters are two separate [Meter]s.
class Meter {
  const Meter({
    required this.id,
    required this.type,
    required this.place,
    required this.unit,
    this.tariff,
  });

  final String id;
  final UtilityType type;

  /// Property / place the meter belongs to (apartment, shop, ...). May be empty.
  final String place;

  /// Unit shown next to readings, e.g. kWh or m³. Never assumed from the type after creation.
  final String unit;

  /// Optional local tariff used only for the cost estimate. Null = no estimate is shown.
  final Tariff? tariff;

  Meter copyWith({String? place, String? unit, Tariff? tariff, bool clearTariff = false}) => Meter(
        id: id,
        type: type,
        place: place ?? this.place,
        unit: unit ?? this.unit,
        tariff: clearTariff ? null : (tariff ?? this.tariff),
      );

  String get title => place.trim().isEmpty ? type.label : '${type.label} — ${place.trim()}';

  Map<String, Object?> toJson() => {
        'id': id,
        'type': type.name,
        'place': place,
        'unit': unit,
        'tariff': tariff?.toJson(),
      };

  factory Meter.fromJson(Map<String, Object?> json) => Meter(
        id: json['id'] as String,
        type: utilityTypeFromName(json['type'] as String?),
        place: (json['place'] as String?) ?? '',
        unit: (json['unit'] as String?) ?? 'kWh',
        tariff: json['tariff'] == null ? null : Tariff.fromJson((json['tariff'] as Map).cast<String, Object?>()),
      );
}

/// A timestamped cumulative value of one meter.
///
/// [isReset] marks a reset / replacement / capacity overflow: the reading starts a new
/// comparison segment, and no consumption is calculated across that boundary.
class Reading {
  const Reading({
    required this.id,
    required this.meterId,
    required this.value,
    required this.at,
    this.isReset = false,
  });

  final String id;
  final String meterId;
  final double value;
  final DateTime at;
  final bool isReset;

  Map<String, Object?> toJson() => {
        'id': id,
        'meterId': meterId,
        'value': value,
        'at': at.toIso8601String(),
        'isReset': isReset,
      };

  factory Reading.fromJson(Map<String, Object?> json) => Reading(
        id: json['id'] as String,
        meterId: json['meterId'] as String,
        value: (json['value'] as num).toDouble(),
        at: DateTime.parse(json['at'] as String),
        isReset: (json['isReset'] as bool?) ?? false,
      );
}
