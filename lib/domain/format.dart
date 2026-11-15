/// Pure Dart number / date helpers. Output always uses Latin digits (numeric runs are shown LTR by the UI).
library;

const _arabicIndic = '٠١٢٣٤٥٦٧٨٩';
const _easternIndic = '۰۱۲۳۴۵۶۷۸۹';

/// Parses a user-typed reading. Accepts Latin, Arabic-Indic and Eastern Arabic-Indic digits, '.' or '٫' as
/// the decimal separator, and ignores thousands separators (',', '٬', spaces). Rejects negatives,
/// exponents and anything else (returns null).
double? parseNumber(String input) {
  final b = StringBuffer();
  for (final r in input.trim().runes) {
    final ch = String.fromCharCode(r);
    final i1 = _arabicIndic.indexOf(ch);
    final i2 = _easternIndic.indexOf(ch);
    if (i1 >= 0) {
      b.write(i1);
    } else if (i2 >= 0) {
      b.write(i2);
    } else if (ch == '٫') {
      b.write('.');
    } else if (ch == '٬' || ch == ',' || ch == ' ' || ch == '\u00A0') {
      continue;
    } else {
      b.write(ch);
    }
  }
  final s = b.toString();
  if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(s)) return null;
  final v = double.tryParse(s);
  if (v == null || v.isNaN || v.isInfinite) return null;
  return v;
}

/// 12480 -> "12,480", 385.5 -> "385.5", 0.30000000000000004 -> "0.3".
String formatNumber(double v, {int maxDecimals = 2}) {
  var s = v.abs().toStringAsFixed(maxDecimals);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '');
    if (s.endsWith('.')) s = s.substring(0, s.length - 1);
  }
  final parts = s.split('.');
  final intPart = parts[0];
  final grouped = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) grouped.write(',');
    grouped.write(intPart[i]);
  }
  final body = parts.length > 1 ? '${grouped.toString()}.${parts[1]}' : grouped.toString();
  return (v < 0 && body != '0') ? '-$body' : body;
}

/// 34.6 -> "+35%", -12.2 -> "-12%", 0 -> "0%".
String formatPercent(double p) {
  final r = p.round();
  return r > 0 ? '+$r%' : '$r%';
}

/// yyyy/MM/dd (numeric dates are shown LTR).
String formatDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

/// HH:mm
String formatTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
