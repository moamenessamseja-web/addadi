/// Pure Dart: consumption, comparison segments, spike detection, entry validation.
///
/// Rules (README + design foundation):
/// * a meter is only ever compared with its own history;
/// * a reset / replacement reading starts a new segment: nothing is calculated across the boundary;
/// * negative consumption is invalid; overflow is handled with the reset tag;
/// * a spike needs two valid historical readings (a baseline period) plus the current reading,
///   i.e. at least 3 readings in the current segment.
library;

import 'models.dart';

List<Reading> sortedReadings(Iterable<Reading> readings) {
  final list = readings.toList();
  list.sort((a, b) {
    final c = a.at.compareTo(b.at);
    return c != 0 ? c : a.id.compareTo(b.id);
  });
  return list;
}

/// Splits a chronologically sorted list at every reset reading (the reset reading opens the new segment).
List<List<Reading>> segmentsOf(List<Reading> sorted) {
  final segments = <List<Reading>>[];
  for (final r in sorted) {
    if (segments.isEmpty || r.isReset) {
      segments.add(<Reading>[r]);
    } else {
      segments.last.add(r);
    }
  }
  return segments;
}

/// The interval between two consecutive readings of the same segment.
class Period {
  const Period(this.from, this.to);

  final Reading from;
  final Reading to;

  double get consumption => to.value - from.value;

  double get days => to.at.difference(from.at).inMinutes / 1440.0;

  /// Average consumption per day, or null when both readings share the same instant.
  double? get dailyRate => days > 0 ? consumption / days : null;
}

/// Every measured period of a meter, oldest first, never crossing a reset boundary.
List<Period> periodsOf(List<Reading> sorted) {
  final periods = <Period>[];
  for (final seg in segmentsOf(sorted)) {
    for (var i = 1; i < seg.length; i++) {
      periods.add(Period(seg[i - 1], seg[i]));
    }
  }
  return periods;
}

enum MeterStatus { noReading, insufficientHistory, stable, spike }

class MeterAnalysis {
  const MeterAnalysis({
    required this.status,
    required this.isDue,
    required this.latestIsReset,
    this.latest,
    this.current,
    this.previous,
    this.spikePercent,
  });

  final MeterStatus status;

  /// No reading for longer than the due interval (monthly by default).
  final bool isDue;

  /// The latest reading is a reset / replacement marker (history break).
  final bool latestIsReset;

  final Reading? latest;

  /// Period between the last two readings of the current segment.
  final Period? current;

  /// The period before [current] in the same segment (the baseline).
  final Period? previous;

  /// (current - previous) / previous * 100, only when a valid baseline above zero exists.
  final double? spikePercent;
}

MeterAnalysis analyzeMeter(
  List<Reading> sortedMeterReadings, {
  required double thresholdPercent,
  required DateTime now,
  int dueAfterDays = 30,
}) {
  if (sortedMeterReadings.isEmpty) {
    return const MeterAnalysis(status: MeterStatus.noReading, isDue: false, latestIsReset: false);
  }
  final latest = sortedMeterReadings.last;
  final seg = segmentsOf(sortedMeterReadings).last;
  final n = seg.length;
  final current = n >= 2 ? Period(seg[n - 2], seg[n - 1]) : null;
  final previous = n >= 3 ? Period(seg[n - 3], seg[n - 2]) : null;

  double? percent;
  if (current != null && previous != null && previous.consumption > 0) {
    percent = (current.consumption - previous.consumption) / previous.consumption * 100.0;
  }

  final MeterStatus status;
  // 1e-9 tolerance: 30% exactly must count as reaching a 30% threshold despite floating point noise.
  if (percent != null && percent >= thresholdPercent - 1e-9) {
    status = MeterStatus.spike;
  } else if (previous == null) {
    status = MeterStatus.insufficientHistory;
  } else {
    status = MeterStatus.stable;
  }

  return MeterAnalysis(
    status: status,
    isDue: now.difference(latest.at).inDays > dueAfterDays,
    latestIsReset: latest.isReset,
    latest: latest,
    current: current,
    previous: previous,
    spikePercent: percent,
  );
}

enum ReadingProblem { invalidNumber, olderThanLatest, lowerThanPrevious }

/// Checks a new reading against the meter's existing (sorted) readings. Returns null when it can be saved.
ReadingProblem? validateReading({
  required List<Reading> existingSorted,
  required double? value,
  required DateTime at,
  required bool isReset,
}) {
  if (value == null || value.isNaN || value.isInfinite || value < 0) {
    return ReadingProblem.invalidNumber;
  }
  if (existingSorted.isEmpty) return null;
  final last = existingSorted.last;
  if (at.isBefore(last.at)) return ReadingProblem.olderThanLatest;
  if (!isReset && value < last.value) return ReadingProblem.lowerThanPrevious;
  return null;
}

/// Consumption the new reading would produce, or null when none can be calculated
/// (first reading, reset boundary, or an invalid entry).
double? previewConsumption({
  required List<Reading> existingSorted,
  required double? value,
  required DateTime at,
  required bool isReset,
}) {
  if (validateReading(existingSorted: existingSorted, value: value, at: at, isReset: isReset) != null) {
    return null;
  }
  if (existingSorted.isEmpty || isReset || value == null) return null;
  return value - existingSorted.last.value;
}
