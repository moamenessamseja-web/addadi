import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../domain/consumption.dart';
import '../domain/format.dart';
import '../domain/models.dart';
import 'chart.dart';
import 'strings.dart';
import 'tokens.dart';
import 'widgets.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({
    super.key,
    required this.store,
    required this.meterId,
    required this.onSelectMeter,
  });

  final AppStore store;
  final String? meterId;
  final void Function(String meterId) onSelectMeter;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final c = AppColors.of(context);
        final meters = store.meters;
        if (meters.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(Space.xxl),
              child: Text(S.noMeterSelected, textAlign: TextAlign.center, style: TextStyle(color: c.textSecondary)),
            ),
          );
        }
        final meter = store.meterById(meterId) ?? meters.first;
        final readings = store.readingsOf(meter.id);
        final analysis = store.analysisOf(meter.id);
        // The chart shows only the current comparison segment (never across a reset boundary).
        final segments = segmentsOf(readings);
        final currentSegment = segments.isEmpty ? const <Reading>[] : segments.last;
        final periods = <Period>[
          for (var i = 1; i < currentSegment.length; i++) Period(currentSegment[i - 1], currentSegment[i]),
        ];
        final hasEarlierSegments = segments.length > 1;
        final cur = analysis.current;
        final prev = analysis.previous;

        return ListView(
          padding: const EdgeInsets.all(Space.l),
          children: [
            const Text(S.selectMeter, style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: Space.s),
            Wrap(
              spacing: Space.s,
              runSpacing: Space.s,
              children: [
                for (final m in meters)
                  ChoiceChip(
                    avatar: Icon(utilityIcon(m.type), size: 18),
                    label: Text(m.title),
                    selected: m.id == meter.id,
                    onSelected: (_) => onSelectMeter(m.id),
                  ),
              ],
            ),
            const SizedBox(height: Space.l),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(S.currentComparison, style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: Space.m),
                  if (cur == null)
                    Text(S.notEnoughHistory, style: TextStyle(color: c.textSecondary))
                  else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: LabeledValue(
                            label: S.currentPeriod,
                            value: NumericText(
                              '${formatNumber(cur.consumption)} ${meter.unit}',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: c.brand700),
                            ),
                          ),
                        ),
                        if (prev != null)
                          Expanded(
                            child: LabeledValue(
                              label: S.previousPeriod,
                              value: NumericText(
                                '${formatNumber(prev.consumption)} ${meter.unit}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: Space.xs),
                    NumericText(
                      '${formatDate(cur.from.at)} → ${formatDate(cur.to.at)}',
                      style: TextStyle(color: c.textSecondary, fontSize: 12),
                    ),
                    if (prev != null && analysis.spikePercent != null) ...[
                      const SizedBox(height: Space.m),
                      Row(
                        children: [
                          Icon(
                            analysis.status == MeterStatus.spike ? Icons.trending_up : Icons.trending_flat,
                            color: analysis.status == MeterStatus.spike ? c.warning : c.success,
                          ),
                          const SizedBox(width: Space.s),
                          NumericText(
                            formatPercent(analysis.spikePercent!),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: analysis.status == MeterStatus.spike ? c.warning : c.success,
                            ),
                          ),
                          const SizedBox(width: Space.m),
                          Text('${S.absoluteVariance}: ', style: TextStyle(color: c.textSecondary)),
                          NumericText('${formatNumber(cur.consumption - prev.consumption)} ${meter.unit}'),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: Space.m),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(S.monthlyChart, style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: Space.m),
                  if (periods.length < 2)
                    Text(S.notEnoughHistory, style: TextStyle(color: c.textSecondary))
                  else ...[
                    ConsumptionChart(
                      unit: meter.unit,
                      points: [for (final p in periods) ChartPoint(p.to.at, p.consumption)],
                    ),
                    const SizedBox(height: Space.s),
                    Text(S.chartNote, style: TextStyle(color: c.textSecondary, fontSize: 12)),
                  ],
                  if (hasEarlierSegments) ...[
                    const SizedBox(height: Space.s),
                    Text(S.resetMarker, style: TextStyle(color: c.textSecondary, fontSize: 12)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: Space.m),
            AppCard(
              child: LabeledValue(
                label: S.burnRate,
                value: cur?.dailyRate == null
                    ? Text(S.notEnoughHistory, style: TextStyle(color: c.textSecondary))
                    : Row(
                        children: [
                          NumericText(
                            '${formatNumber(cur!.dailyRate!)} ${meter.unit}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: Space.s),
                          Text(S.perDay, style: TextStyle(color: c.textSecondary)),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
