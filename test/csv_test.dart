import 'package:addady/domain/csv_export.dart';
import 'package:addady/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

const _headers = ['meter', 'unit', 'date', 'time', 'reading', 'reset', 'consumption'];
final _d0 = DateTime(2026, 1, 5, 7, 30);

Reading r(String id, String meter, double v, int day, {bool reset = false}) =>
    Reading(id: id, meterId: meter, value: v, at: _d0.add(Duration(days: day)), isReset: reset);

void main() {
  test('header, BOM, one row per reading, consumption blank for the first reading and after a reset', () {
    const m = Meter(id: 'a', type: UtilityType.electricity, place: 'Flat', unit: 'kWh');
    final csv = buildCsv(
      meters: const [m],
      sortedReadingsByMeter: {
        'a': [r('1', 'a', 100, 0), r('2', 'a', 150.5, 30), r('3', 'a', 10, 60, reset: true), r('4', 'a', 40, 90)],
      },
      headers: _headers,
    );
    expect(csv.startsWith('\uFEFF'), isTrue);
    final lines = csv.substring(1).split('\r\n');
    expect(lines.first, equals('meter,unit,date,time,reading,reset,consumption'));
    expect(lines.length, equals(6)); // header + 4 rows + trailing empty
    expect(lines[1], equals('كهرباء — Flat,kWh,2026-01-05,07:30,100,0,'));
    expect(lines[2].endsWith(',150.5,0,50.5'), isTrue);
    expect(lines[3].endsWith(',10,1,'), isTrue);
    expect(lines[4].endsWith(',40,0,30'), isTrue);
  });

  test('cells with commas or quotes are quoted; formulas are neutralised', () {
    expect(csvCell('a,b'), equals('"a,b"'));
    expect(csvCell('say "hi"'), equals('"say ""hi"""'));
    expect(csvCell('=SUM(A1)'), equals("'=SUM(A1)"));
    expect(csvCell('-5 floor'), equals("'-5 floor"));
    expect(csvCell('plain'), equals('plain'));
  });

  test('meters without readings are skipped and equal titles get a number', () {
    const a = Meter(id: 'a', type: UtilityType.water, place: 'Shop', unit: 'm³');
    const b = Meter(id: 'b', type: UtilityType.water, place: 'Shop', unit: 'm³');
    const empty = Meter(id: 'c', type: UtilityType.gas, place: '', unit: 'm³');
    final csv = buildCsv(
      meters: const [a, b, empty],
      sortedReadingsByMeter: {'a': [r('1', 'a', 1, 0)], 'b': [r('2', 'b', 2, 0)]},
      headers: _headers,
    );
    final lines = csv.substring(1).trim().split('\r\n');
    expect(lines.length, equals(3));
    expect(lines[1].startsWith('مياه — Shop,'), isTrue);
    expect(lines[2].startsWith('مياه — Shop (2),'), isTrue);
  });

  test('numbers are plain: no thousands separators, no trailing zeros', () {
    const m = Meter(id: 'a', type: UtilityType.electricity, place: '', unit: 'kWh');
    final csv = buildCsv(meters: const [m], sortedReadingsByMeter: {'a': [r('1', 'a', 12480.0, 0), r('2', 'a', 12480.25, 1)]}, headers: _headers);
    expect(csv.contains(',12480,0,'), isTrue);
    expect(csv.contains(',12480.25,0,0.25'), isTrue);
  });
}
