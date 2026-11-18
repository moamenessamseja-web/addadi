/// Pure Dart: builds the CSV export of all meters and readings. Sharing the file is behind [ExportSink].
library;

import 'consumption.dart';
import 'models.dart';

abstract class ExportSink {
  /// Writes [content] to a temporary file called [filename] and hands it to the OS share sheet.
  Future<void> shareFile({required String filename, required String content, required String mimeType});
}

enum ExportOutcome { shared, nothingToExport, failed }

String _plain(double v) {
  var s = v.toStringAsFixed(3);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '');
    if (s.endsWith('.')) s = s.substring(0, s.length - 1);
  }
  return s;
}

String _two(int n) => n.toString().padLeft(2, '0');

/// Quotes a cell when needed, and neutralises spreadsheet formulas (a text cell starting with = + - @).
String csvCell(String value, {bool isText = true}) {
  var v = value;
  if (isText && v.isNotEmpty && '=+-@'.contains(v[0])) v = "'$v";
  if (v.contains(',') || v.contains('"') || v.contains('\n') || v.contains('\r')) {
    return '"${v.replaceAll('"', '""')}"';
  }
  return v;
}

/// UTF-8 text starting with a byte-order mark (so spreadsheet apps read Arabic correctly), one row per reading.
/// [headers] must have 7 entries: meter, unit, date, time, reading, reset flag, consumption of the period.
/// Numbers are plain (dot decimal, no thousands separators) so they can be calculated with.
String buildCsv({
  required List<Meter> meters,
  required Map<String, List<Reading>> sortedReadingsByMeter,
  required List<String> headers,
}) {
  assert(headers.length == 7);
  final b = StringBuffer('\uFEFF');
  b.write('${headers.map((h) => csvCell(h, isText: false)).join(',')}\r\n');
  final used = <String, int>{};
  for (final m in meters) {
    final readings = sortedReadingsByMeter[m.id] ?? const <Reading>[];
    if (readings.isEmpty) continue;
    final count = (used[m.title] ?? 0) + 1;
    used[m.title] = count;
    final name = count == 1 ? m.title : '${m.title} ($count)';
    final consumptionAt = {for (final p in periodsOf(readings)) p.to.id: p.consumption};
    for (final r in readings) {
      final c = consumptionAt[r.id];
      final row = [
        csvCell(name),
        csvCell(m.unit),
        '${r.at.year.toString().padLeft(4, '0')}-${_two(r.at.month)}-${_two(r.at.day)}',
        '${_two(r.at.hour)}:${_two(r.at.minute)}',
        _plain(r.value),
        r.isReset ? '1' : '0',
        c == null ? '' : _plain(c),
      ];
      b.write('${row.join(',')}\r\n');
    }
  }
  return b.toString();
}
