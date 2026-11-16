import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../domain/consumption.dart';
import '../domain/format.dart';
import '../domain/models.dart';
import 'strings.dart';
import 'tokens.dart';
import 'widgets.dart';

String problemMessage(ReadingProblem p) => switch (p) {
      ReadingProblem.invalidNumber => S.problemInvalid,
      ReadingProblem.olderThanLatest => S.problemOlder,
      ReadingProblem.lowerThanPrevious => S.problemLower,
    };

class AddReadingScreen extends StatefulWidget {
  const AddReadingScreen({
    super.key,
    required this.store,
    required this.meterId,
    required this.onSelectMeter,
  });

  final AppStore store;
  final String? meterId;
  final void Function(String meterId) onSelectMeter;

  @override
  State<AddReadingScreen> createState() => _AddReadingScreenState();
}

class _AddReadingScreenState extends State<AddReadingScreen> {
  final _value = TextEditingController();
  DateTime _at = DateTime.now();
  bool _reset = false;
  bool _saving = false;
  Meter? _savedMeter;
  MeterAnalysis? _savedAnalysis;

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _at,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_at));
    if (time == null || !mounted) return;
    setState(() => _at = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _save(Meter meter) async {
    final value = parseNumber(_value.text);
    if (_reset) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(S.resetConfirmTitle),
          content: const Text(S.resetConfirmBody),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text(S.cancel)),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text(S.confirm)),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }
    setState(() => _saving = true);
    try {
      final problem = await widget.store.addReading(meterId: meter.id, value: value, at: _at, isReset: _reset);
      if (!mounted) return;
      if (problem != null) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(problemMessage(problem))));
        return;
      }
      final analysis = widget.store.analysisOf(meter.id);
      setState(() {
        _saving = false;
        _savedMeter = meter;
        _savedAnalysis = analysis;
        _value.clear();
        _reset = false;
        _at = DateTime.now();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(S.savedOnDevice)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(S.saveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final c = AppColors.of(context);
        final meters = widget.store.meters;
        if (meters.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(Space.xxl),
              child: Text(S.addMeterFirst, textAlign: TextAlign.center, style: TextStyle(color: c.textSecondary)),
            ),
          );
        }
        final meter = widget.store.meterById(widget.meterId) ?? meters.first;
        final existing = widget.store.readingsOf(meter.id);
        final value = parseNumber(_value.text);
        final hasText = _value.text.trim().isNotEmpty;
        final problem = hasText
            ? validateReading(existingSorted: existing, value: value, at: _at, isReset: _reset)
            : null;
        final preview = previewConsumption(existingSorted: existing, value: value, at: _at, isReset: _reset);
        final canSave = hasText && problem == null && !_saving;
        final last = existing.isEmpty ? null : existing.last;

        return ListView(
          padding: const EdgeInsets.all(Space.l),
          children: [
            const Text(S.chooseMeter, style: TextStyle(fontWeight: FontWeight.w700)),
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
                    onSelected: (_) {
                      widget.onSelectMeter(m.id);
                      setState(() {
                        _value.clear();
                        _reset = false;
                        _savedMeter = null;
                        _savedAnalysis = null;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: Space.l),
            AppCard(
              child: last == null
                  ? Text(S.noPreviousReading, style: TextStyle(color: c.textSecondary))
                  : Row(
                      children: [
                        Expanded(
                          child: LabeledValue(
                            label: S.previousReading,
                            value: NumericText(
                              '${formatNumber(last.value)} ${meter.unit}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        NumericText(formatDate(last.at), style: TextStyle(color: c.textSecondary)),
                      ],
                    ),
            ),
            const SizedBox(height: Space.l),
            TextField(
              controller: _value,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textDirection: TextDirection.ltr,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: S.newReading,
                suffixText: meter.unit,
                errorText: problem == null ? null : problemMessage(problem),
                errorMaxLines: 3,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.input)),
              ),
            ),
            const SizedBox(height: Space.m),
            OutlinedButton.icon(
              onPressed: _pickDateTime,
              icon: const Icon(Icons.event),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('${S.readingDateTime}: '),
                  NumericText('${formatDate(_at)}  ${formatTime(_at)}'),
                ],
              ),
            ),
            const SizedBox(height: Space.s),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(S.resetToggle),
              subtitle: const Text(S.resetHelper),
              value: _reset,
              onChanged: (v) => setState(() => _reset = v),
            ),
            const SizedBox(height: Space.s),
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: LabeledValue(
                      label: S.calculation,
                      value: preview == null
                          ? Text(S.noCalculation, style: TextStyle(color: c.textSecondary))
                          : NumericText(
                              '${formatNumber(preview)} ${meter.unit}',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: c.brand700),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.l),
            FilledButton(
              onPressed: canSave ? () => _save(meter) : null,
              child: const Padding(padding: EdgeInsets.symmetric(vertical: Space.m), child: Text(S.save)),
            ),
            if (_savedMeter != null && _savedAnalysis != null) ...[
              const SizedBox(height: Space.l),
              _SavedCard(meter: _savedMeter!, analysis: _savedAnalysis!),
            ],
          ],
        );
      },
    );
  }
}

class _SavedCard extends StatelessWidget {
  const _SavedCard({required this.meter, required this.analysis});

  final Meter meter;
  final MeterAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final cur = analysis.current;
    final prev = analysis.previous;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.check_circle, color: c.success),
            const SizedBox(width: Space.s),
            const Expanded(child: Text(S.savedOnDevice, style: TextStyle(fontWeight: FontWeight.w700))),
          ]),
          if (cur != null) ...[
            const SizedBox(height: Space.m),
            LabeledValue(
              label: S.periodConsumption,
              value: NumericText(
                '${formatNumber(cur.consumption)} ${meter.unit}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ],
          if (analysis.status == MeterStatus.spike && analysis.spikePercent != null && cur != null && prev != null) ...[
            const SizedBox(height: Space.m),
            Row(children: [
              Icon(Icons.trending_up, color: c.warning),
              const SizedBox(width: Space.s),
              NumericText(formatPercent(analysis.spikePercent!), style: TextStyle(color: c.warning, fontWeight: FontWeight.w800, fontSize: 18)),
            ]),
            const SizedBox(height: Space.xs),
            Text(S.spikeDetected, style: TextStyle(color: c.textSecondary)),
            const SizedBox(height: Space.xs),
            NumericText(
              '${formatDate(cur.from.at)} → ${formatDate(cur.to.at)}  vs  ${formatDate(prev.from.at)} → ${formatDate(prev.to.at)}',
              style: TextStyle(color: c.textSecondary, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
