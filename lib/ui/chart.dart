import 'package:flutter/material.dart';

import '../domain/format.dart';
import 'strings.dart';
import 'tokens.dart';

class ChartPoint {
  const ChartPoint(this.at, this.value);

  final DateTime at;
  final double value;
}

/// Local line chart of measured consumption per reading period. Points are only the measured ones;
/// missing readings are never interpolated (the line connects consecutive measured periods only).
class ConsumptionChart extends StatelessWidget {
  const ConsumptionChart({super.key, required this.points, required this.unit, this.height = 180});

  final List<ChartPoint> points;
  final String unit;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Semantics(
      label: S.chartSemantics(points.length),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _ChartPainter(points: points, unit: unit, line: c.brand700, grid: c.border, text: c.textSecondary),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({required this.points, required this.unit, required this.line, required this.grid, required this.text});

  final List<ChartPoint> points;
  final String unit;
  final Color line;
  final Color grid;
  final Color text;

  void _label(Canvas canvas, String s, Offset at, {bool alignRight = false}) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(color: text, fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, alignRight ? Offset(at.dx - tp.width, at.dy) : at);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    const left = 8.0, right = 8.0, top = 20.0, bottom = 22.0;
    final w = size.width - left - right;
    final h = size.height - top - bottom;
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    canvas.drawLine(Offset(left, top + h), Offset(left + w, top + h), gridPaint);
    canvas.drawLine(Offset(left, top), Offset(left + w, top), gridPaint);

    var maxV = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    if (maxV <= 0) maxV = 1;
    Offset pos(int i) {
      final x = points.length == 1 ? left + w / 2 : left + w * i / (points.length - 1);
      final y = top + h - h * (points[i].value / maxV);
      return Offset(x, y);
    }

    final linePaint = Paint()
      ..color = line
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final o = pos(i);
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    canvas.drawPath(path, linePaint);
    final dot = Paint()..color = line;
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(pos(i), 4, dot);
    }
    _label(canvas, '${formatNumber(maxV)} $unit', const Offset(left, 2));
    _label(canvas, formatDate(points.first.at), Offset(left, top + h + 4));
    if (points.length > 1) {
      _label(canvas, formatDate(points.last.at), Offset(left + w, top + h + 4), alignRight: true);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.points != points || old.unit != unit || old.line != line || old.grid != grid || old.text != text;
}
