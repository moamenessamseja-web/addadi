import 'package:addady/domain/app_data.dart';
import 'package:addady/domain/consumption.dart';
import 'package:addady/domain/format.dart';
import 'package:addady/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

final _day0 = DateTime(2026, 1, 1);

Reading r(String id, double v, int day, {bool reset = false, int hour = 0}) => Reading(
      id: id,
      meterId: 'm1',
      value: v,
      at: _day0.add(Duration(days: day, hours: hour)),
      isReset: reset,
    );

MeterAnalysis analyze(List<Reading> list, {double threshold = 30, int nowDay = 40}) => analyzeMeter(
      sortedReadings(list),
      thresholdPercent: threshold,
      now: _day0.add(Duration(days: nowDay)),
    );

void main() {
  group('parseNumber', () {
    test('Latin, thousands separators, spaces', () {
      expect(parseNumber('12,480'), equals(12480.0));
      expect(parseNumber('  42 '), equals(42.0));
      expect(parseNumber('385.5'), equals(385.5));
    });
    test('Arabic-Indic digits and decimal separator', () {
      expect(parseNumber('٣٨٥٫٥'), equals(385.5));
      expect(parseNumber('۱۲۳'), equals(123.0));
    });
    test('rejects negatives, exponents, junk and empty', () {
      expect(parseNumber('-5'), isNull);
      expect(parseNumber('1e5'), isNull);
      expect(parseNumber('12.5.3'), isNull);
      expect(parseNumber('abc'), isNull);
      expect(parseNumber(''), isNull);
    });
  });

  group('formatting', () {
    test('formatNumber', () {
      expect(formatNumber(12480), equals('12,480'));
      expect(formatNumber(385.5), equals('385.5'));
      expect(formatNumber(0.1 + 0.2), equals('0.3'));
      expect(formatNumber(1234567.891), equals('1,234,567.89'));
      expect(formatNumber(0), equals('0'));
      expect(formatNumber(999), equals('999'));
      expect(formatNumber(1000), equals('1,000'));
      expect(formatNumber(-1500), equals('-1,500'));
    });
    test('formatPercent and formatDate', () {
      expect(formatPercent(34.6), equals('+35%'));
      expect(formatPercent(-12.2), equals('-12%'));
      expect(formatPercent(0), equals('0%'));
      expect(formatDate(DateTime(2026, 11, 9)), equals('2026/11/09'));
      expect(formatTime(DateTime(2026, 11, 9, 7, 5)), equals('07:05'));
    });
  });

  group('segments and periods', () {
    test('a reset reading opens a new segment and nothing is calculated across it', () {
      final list = sortedReadings([r('1', 100, 0), r('2', 150, 30), r('3', 200, 60), r('4', 10, 90, reset: true), r('5', 40, 120)]);
      final segs = segmentsOf(list);
      expect(segs.length, equals(2));
      expect(segs[0].length, equals(3));
      expect(segs[1].length, equals(2));
      final periods = periodsOf(list);
      expect(periods.length, equals(3));
      expect(periods.last.consumption, equals(30.0));
    });
    test('equal timestamps keep creation (id) order', () {
      final list = sortedReadings([r('2', 150, 0), r('1', 100, 0)]);
      expect(list.first.id, equals('1'));
    });
    test('dailyRate', () {
      expect(Period(r('1', 100, 0), r('2', 160, 30)).dailyRate, equals(2.0));
      expect(Period(r('1', 100, 0), r('2', 160, 0)).dailyRate, isNull);
    });
  });

  group('analyzeMeter', () {
    test('no readings', () {
      final a = analyze([]);
      expect(a.status == MeterStatus.noReading, isTrue);
      expect(a.latest, isNull);
    });
    test('one and two readings are insufficient history, two give a current period', () {
      expect(analyze([r('1', 100, 0)]).status == MeterStatus.insufficientHistory, isTrue);
      final a = analyze([r('1', 100, 0), r('2', 150, 30)]);
      expect(a.status == MeterStatus.insufficientHistory, isTrue);
      expect(a.current!.consumption, equals(50.0));
      expect(a.previous, isNull);
      expect(a.spikePercent, isNull);
    });
    test('three readings: stable when consumption fell', () {
      final a = analyze([r('1', 100, 0), r('2', 150, 30), r('3', 190, 60)]);
      expect(a.status == MeterStatus.stable, isTrue);
      expect(a.spikePercent!, closeTo(-20.0, 1e-9));
    });
    test('spike above the threshold', () {
      final a = analyze([r('1', 100, 0), r('2', 150, 30), r('3', 220, 60)]);
      expect(a.status == MeterStatus.spike, isTrue);
      expect(a.spikePercent!, closeTo(40.0, 1e-9));
    });
    test('exactly the threshold counts as a spike', () {
      final a = analyze([r('1', 100, 0), r('2', 150, 30), r('3', 215, 60)]);
      expect(a.status == MeterStatus.spike, isTrue);
    });
    test('threshold is configurable', () {
      final readings = [r('1', 100, 0), r('2', 150, 30), r('3', 215, 60)];
      expect(analyze(readings, threshold: 50).status == MeterStatus.stable, isTrue);
    });
    test('no baseline above zero means no percentage and no spike', () {
      final a = analyze([r('1', 100, 0), r('2', 100, 30), r('3', 150, 60)]);
      expect(a.spikePercent, isNull);
      expect(a.status == MeterStatus.stable, isTrue);
    });
    test('does not compare across a reset', () {
      final a = analyze([r('1', 100, 0), r('2', 150, 30), r('3', 200, 60), r('4', 10, 90, reset: true), r('5', 400, 120)]);
      expect(a.previous, isNull);
      expect(a.spikePercent, isNull);
      expect(a.status == MeterStatus.insufficientHistory, isTrue);
      expect(a.current!.consumption, equals(390.0));
    });
    test('latest reading being a reset is flagged and has no current period', () {
      final a = analyze([r('1', 100, 0), r('2', 150, 30), r('3', 5, 60, reset: true)]);
      expect(a.latestIsReset, isTrue);
      expect(a.current, isNull);
    });
    test('due after more than 30 days without a reading', () {
      expect(analyze([r('1', 100, 0)], nowDay: 31).isDue, isTrue);
      expect(analyze([r('1', 100, 0)], nowDay: 30).isDue, isFalse);
    });
  });

  group('validateReading and previewConsumption', () {
    final existing = sortedReadings([r('1', 100, 0), r('2', 150, 30)]);
    final later = _day0.add(const Duration(days: 60));

    test('first reading of a meter accepts any non-negative number', () {
      expect(validateReading(existingSorted: const [], value: 0, at: later, isReset: false), isNull);
      expect(validateReading(existingSorted: const [], value: null, at: later, isReset: false) == ReadingProblem.invalidNumber, isTrue);
      expect(validateReading(existingSorted: const [], value: -1, at: later, isReset: false) == ReadingProblem.invalidNumber, isTrue);
    });
    test('lower than the previous reading needs the reset tag', () {
      expect(validateReading(existingSorted: existing, value: 120, at: later, isReset: false) == ReadingProblem.lowerThanPrevious, isTrue);
      expect(validateReading(existingSorted: existing, value: 120, at: later, isReset: true), isNull);
    });
    test('equal reading is valid (zero consumption)', () {
      expect(validateReading(existingSorted: existing, value: 150, at: later, isReset: false), isNull);
    });
    test('older than the latest reading is rejected', () {
      expect(validateReading(existingSorted: existing, value: 200, at: _day0.add(const Duration(days: 10)), isReset: false) == ReadingProblem.olderThanLatest, isTrue);
    });
    test('previewConsumption', () {
      expect(previewConsumption(existingSorted: existing, value: 190, at: later, isReset: false), equals(40.0));
      expect(previewConsumption(existingSorted: existing, value: 10, at: later, isReset: true), isNull);
      expect(previewConsumption(existingSorted: const [], value: 10, at: later, isReset: false), isNull);
      expect(previewConsumption(existingSorted: existing, value: 100, at: later, isReset: false), isNull);
    });
  });

  group('AppData', () {
    test('encode/decode round trip', () {
      final data = AppData(
        meters: const [Meter(id: 'm1', type: UtilityType.water, place: 'الشقة', unit: 'm³')],
        readings: [r('1', 100.5, 0), r('2', 12, 30, reset: true)],
        thresholdPercent: 45,
        themeMode: 'dark',
      );
      final back = AppData.decode(data.encode());
      expect(back.meters.single.title, equals('مياه — الشقة'));
      expect(back.meters.single.type == UtilityType.water, isTrue);
      expect(back.readings.length, equals(2));
      expect(back.readings.first.value, equals(100.5));
      expect(back.readings.last.isReset, isTrue);
      expect(back.readings.last.at, equals(_day0.add(const Duration(days: 30))));
      expect(back.thresholdPercent, equals(45.0));
      expect(back.themeMode, equals('dark'));
    });
    test('garbage is detected by tryDecode and decodes to an empty document', () {
      expect(AppData.tryDecode('not json'), isNull);
      expect(AppData.decode('not json').meters.isEmpty, isTrue);
      expect(AppData.decode(null).meters.isEmpty, isTrue);
      expect(AppData.decode('').thresholdPercent, equals(30.0));
    });
  });
}
