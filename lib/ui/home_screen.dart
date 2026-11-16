import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../domain/consumption.dart';
import '../domain/format.dart';
import '../domain/models.dart';
import 'add_meter_sheet.dart';
import 'strings.dart';
import 'tokens.dart';
import 'widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.store,
    required this.onAddReading,
    required this.onOpenAnalytics,
  });

  final AppStore store;
  final void Function(String meterId) onAddReading;
  final void Function(String meterId) onOpenAnalytics;

  @override
  Widget build(BuildContext context) {
    final meters = store.meters;
    return ListView(
      padding: const EdgeInsets.all(Space.l),
      children: [
        if (meters.isNotEmpty) ...[
          _Overview(store: store),
          const SizedBox(height: Space.xxl),
        ],
        SectionHeader(
          S.myMeters,
          action: FilledButton.icon(
            onPressed: () => showAddMeterSheet(context, store),
            icon: const Icon(Icons.add),
            label: const Text(S.addMeter),
          ),
        ),
        const SizedBox(height: Space.m),
        if (meters.isEmpty)
          const _EmptyState()
        else
          for (final m in meters) ...[
            MeterCard(
              meter: m,
              analysis: store.analysisOf(m.id),
              onAddReading: () => onAddReading(m.id),
              onOpenAnalytics: () => onOpenAnalytics(m.id),
            ),
            const SizedBox(height: Space.m),
          ],
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return AppCard(
      padding: const EdgeInsets.all(Space.xxl),
      child: Column(
        children: [
          Icon(Icons.speed, size: 48, color: c.brand700),
          const SizedBox(height: Space.m),
          Text(S.noMetersTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: Space.s),
          Text(S.noMetersBody, textAlign: TextAlign.center, style: TextStyle(color: c.textSecondary)),
          const SizedBox(height: Space.l),
          Text(S.promise, textAlign: TextAlign.center, style: TextStyle(color: c.brand900, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Per utility: how many meters and how many need attention. It deliberately shows counts, not summed
/// consumption, because different meters do not share billing periods.
class _Overview extends StatelessWidget {
  const _Overview({required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final tiles = <Widget>[];
    for (final type in UtilityType.values) {
      final ofType = store.meters.where((m) => m.type == type).toList();
      if (ofType.isEmpty) continue;
      final attention = ofType.where((m) {
        final a = store.analysisOf(m.id);
        return a.status == MeterStatus.spike || a.isDue;
      }).length;
      tiles.add(Expanded(
        child: AppCard(
          padding: const EdgeInsets.all(Space.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UtilityBadge(type, size: 36),
              const SizedBox(height: Space.s),
              Text(type.labelAr, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Row(children: [
                NumericText('${ofType.length}', style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(width: Space.xs),
                Text(S.metersCount, style: TextStyle(color: c.textSecondary, fontSize: 12)),
              ]),
              if (attention > 0) ...[
                const SizedBox(height: Space.xs),
                Row(children: [
                  Icon(Icons.priority_high, size: 14, color: c.warning),
                  NumericText('$attention', style: TextStyle(color: c.warning, fontWeight: FontWeight.w700, fontSize: 12)),
                  const SizedBox(width: Space.xs),
                  Flexible(child: Text(S.needAttention, style: TextStyle(color: c.warning, fontSize: 12))),
                ]),
              ],
            ],
          ),
        ),
      ));
      tiles.add(const SizedBox(width: Space.s));
    }
    if (tiles.isNotEmpty) tiles.removeLast();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(S.overview),
        const SizedBox(height: Space.s),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: tiles),
      ],
    );
  }
}

class MeterCard extends StatelessWidget {
  const MeterCard({
    super.key,
    required this.meter,
    required this.analysis,
    required this.onAddReading,
    required this.onOpenAnalytics,
  });

  final Meter meter;
  final MeterAnalysis analysis;
  final VoidCallback onAddReading;
  final VoidCallback onOpenAnalytics;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final latest = analysis.latest;
    final current = analysis.current;
    final chips = <Widget>[];
    switch (analysis.status) {
      case MeterStatus.noReading:
        chips.add(StatusChip(label: S.noReadingYet, icon: Icons.edit_note, color: c.textSecondary));
      case MeterStatus.insufficientHistory:
        chips.add(StatusChip(label: S.insufficientHistory, icon: Icons.hourglass_empty, color: c.textSecondary));
      case MeterStatus.stable:
        chips.add(StatusChip(label: S.stable, icon: Icons.check_circle_outline, color: c.success));
      case MeterStatus.spike:
        chips.add(StatusChip(label: S.spike, icon: Icons.trending_up, color: c.warning));
    }
    if (analysis.isDue) {
      chips.add(StatusChip(label: S.due, icon: Icons.schedule, color: c.warning));
    }

    return AppCard(
      onTap: onOpenAnalytics,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UtilityBadge(meter.type),
              const SizedBox(width: Space.m),
              Expanded(
                child: Text(
                  meter.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Icon(Icons.chevron_left, color: c.textSecondary),
            ],
          ),
          const SizedBox(height: Space.m),
          if (latest != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LabeledValue(
                    label: S.latestReading,
                    value: NumericText(
                      '${formatNumber(latest.value)} ${meter.unit}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                if (current != null)
                  Expanded(
                    child: LabeledValue(
                      label: S.periodConsumption,
                      value: NumericText(
                        '${formatNumber(current.consumption)} ${meter.unit}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: c.brand700),
                      ),
                    ),
                  ),
              ],
            ),
          if (latest != null) ...[
            const SizedBox(height: Space.xs),
            NumericText(formatDate(latest.at), style: TextStyle(color: c.textSecondary, fontSize: 12)),
          ],
          const SizedBox(height: Space.m),
          Wrap(spacing: Space.s, runSpacing: Space.s, crossAxisAlignment: WrapCrossAlignment.center, children: [
            ...chips,
            if (analysis.status == MeterStatus.spike && analysis.spikePercent != null)
              NumericText(
                formatPercent(analysis.spikePercent!),
                style: TextStyle(color: c.warning, fontWeight: FontWeight.w800, fontSize: 16),
              ),
          ]),
          if (analysis.status == MeterStatus.spike)
            Padding(
              padding: const EdgeInsets.only(top: Space.xs),
              child: Text(S.comparedWithPrevious, style: TextStyle(color: c.textSecondary, fontSize: 12)),
            ),
          if (analysis.latestIsReset)
            Padding(
              padding: const EdgeInsets.only(top: Space.s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.link_off, size: 16, color: c.textSecondary),
                  const SizedBox(width: Space.xs),
                  Expanded(child: Text(S.resetMarker, style: TextStyle(color: c.textSecondary, fontSize: 12))),
                ],
              ),
            ),
          const SizedBox(height: Space.s),
          Row(
            children: [
              TextButton.icon(onPressed: onAddReading, icon: const Icon(Icons.add_circle_outline), label: const Text(S.addReadingAction)),
              TextButton.icon(onPressed: onOpenAnalytics, icon: const Icon(Icons.show_chart), label: const Text(S.analyticsAction)),
            ],
          ),
        ],
      ),
    );
  }
}
