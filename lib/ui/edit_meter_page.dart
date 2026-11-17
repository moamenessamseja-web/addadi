import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../domain/format.dart';
import '../domain/models.dart';
import '../domain/tariff.dart';
import 'strings.dart';
import 'tokens.dart';

class _TierFields {
  _TierFields({String upTo = '', String price = ''})
      : upTo = TextEditingController(text: upTo),
        price = TextEditingController(text: price);

  final TextEditingController upTo;
  final TextEditingController price;

  void dispose() {
    upTo.dispose();
    price.dispose();
  }
}

class EditMeterPage extends StatefulWidget {
  const EditMeterPage({super.key, required this.store, required this.meterId});

  final AppStore store;
  final String meterId;

  @override
  State<EditMeterPage> createState() => _EditMeterPageState();
}

class _EditMeterPageState extends State<EditMeterPage> {
  late final Meter? _meter = widget.store.meterById(widget.meterId);
  late final TextEditingController _place = TextEditingController(text: _meter?.place ?? '');
  late final TextEditingController _unit = TextEditingController(text: _meter?.unit ?? '');
  late final TextEditingController _currency = TextEditingController(text: _meter?.tariff?.currency ?? 'ج.م');
  late final TextEditingController _fee = TextEditingController(
    text: (_meter?.tariff?.fixedFee ?? 0) > 0 ? formatNumber(_meter!.tariff!.fixedFee, maxDecimals: 3) : '',
  );
  late bool _tariffOn = _meter?.tariff != null;
  late final List<_TierFields> _tiers = _initialTiers();
  String? _error;
  bool _saving = false;

  List<_TierFields> _initialTiers() {
    final t = _meter?.tariff;
    if (t == null || t.tiers.isEmpty) return [_TierFields()];
    return [
      for (final tier in t.tiers)
        _TierFields(
          upTo: tier.upTo == null ? '' : formatNumber(tier.upTo!, maxDecimals: 3),
          price: formatNumber(tier.price, maxDecimals: 4),
        ),
    ];
  }

  @override
  void dispose() {
    _place.dispose();
    _unit.dispose();
    _currency.dispose();
    _fee.dispose();
    for (final t in _tiers) {
      t.dispose();
    }
    super.dispose();
  }

  String _problemText(TariffProblem p) => switch (p) {
        TariffProblem.noTiers => S.tariffNoTiers,
        TariffProblem.invalidPrice => S.tariffBadPrice,
        TariffProblem.invalidFee => S.tariffBadFee,
        TariffProblem.invalidLimit => S.tariffBadLimit,
        TariffProblem.limitsNotIncreasing => S.tariffLimitsOrder,
        TariffProblem.lastTierMustBeOpen => S.tariffLastOpen,
      };

  /// Returns the typed tariff, or sets [_error] and returns null.
  Tariff? _readTariff() {
    final tiers = <TariffTier>[];
    for (var i = 0; i < _tiers.length; i++) {
      final isLast = i == _tiers.length - 1;
      final price = parseNumber(_tiers[i].price.text);
      final limit = isLast ? null : parseNumber(_tiers[i].upTo.text);
      if (price == null || (!isLast && limit == null)) {
        _error = S.tariffNeedsNumbers;
        return null;
      }
      tiers.add(TariffTier(upTo: limit, price: price));
    }
    final feeText = _fee.text.trim();
    final fee = feeText.isEmpty ? 0.0 : parseNumber(feeText);
    if (fee == null) {
      _error = S.tariffBadFee;
      return null;
    }
    final tariff = Tariff(currency: _currency.text.trim(), fixedFee: fee, tiers: tiers);
    final problem = tariff.validate();
    if (problem != null) {
      _error = _problemText(problem);
      return null;
    }
    return tariff;
  }

  Future<void> _save() async {
    Tariff? tariff;
    setState(() => _error = null);
    if (_tariffOn) {
      tariff = _readTariff();
      if (tariff == null) {
        setState(() {});
        return;
      }
    }
    setState(() => _saving = true);
    try {
      await widget.store.updateMeter(meterId: widget.meterId, place: _place.text, unit: _unit.text, tariff: tariff);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = S.saveFailed;
      });
    }
  }

  InputDecoration _decoration(String label, {String? suffix}) => InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.input)),
      );

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final meter = _meter;
    if (meter == null) return Scaffold(appBar: AppBar(title: const Text(S.editMeter)));
    const numberKeyboard = TextInputType.numberWithOptions(decimal: true);
    return Scaffold(
      appBar: AppBar(title: Text('${S.editMeter}: ${meter.type.labelAr}')),
      body: ListView(
        padding: const EdgeInsets.all(Space.l),
        children: [
          TextField(controller: _place, decoration: _decoration(S.place)),
          const SizedBox(height: Space.m),
          TextField(controller: _unit, textDirection: TextDirection.ltr, decoration: _decoration(S.unit)),
          const SizedBox(height: Space.xl),
          Text(S.tariffSection, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(S.tariffEnable),
            subtitle: const Text(S.tariffHelper),
            value: _tariffOn,
            onChanged: (v) => setState(() => _tariffOn = v),
          ),
          if (_tariffOn) ...[
            const SizedBox(height: Space.s),
            Row(
              children: [
                Expanded(child: TextField(controller: _currency, decoration: _decoration(S.currency))),
                const SizedBox(width: Space.m),
                Expanded(
                  child: TextField(
                    controller: _fee,
                    keyboardType: numberKeyboard,
                    textDirection: TextDirection.ltr,
                    decoration: _decoration(S.fixedFee),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.m),
            for (var i = 0; i < _tiers.length; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: i == _tiers.length - 1
                        ? InputDecorator(
                            decoration: _decoration(S.tierUpTo),
                            child: const Text(S.tierRest),
                          )
                        : TextField(
                            controller: _tiers[i].upTo,
                            keyboardType: numberKeyboard,
                            textDirection: TextDirection.ltr,
                            decoration: _decoration(S.tierUpTo, suffix: _unit.text),
                          ),
                  ),
                  const SizedBox(width: Space.m),
                  Expanded(
                    child: TextField(
                      controller: _tiers[i].price,
                      keyboardType: numberKeyboard,
                      textDirection: TextDirection.ltr,
                      decoration: _decoration(S.tierPrice),
                    ),
                  ),
                  IconButton(
                    tooltip: S.removeTier,
                    icon: Icon(Icons.remove_circle_outline, color: _tiers.length > 1 ? c.danger : c.textSecondary),
                    onPressed: _tiers.length > 1
                        ? () => setState(() {
                              _tiers.removeAt(i).dispose();
                            })
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: Space.m),
            ],
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => setState(() => _tiers.insert(_tiers.length - 1, _TierFields())),
                icon: const Icon(Icons.add),
                label: const Text(S.addTier),
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: Space.m),
            Text(_error!, style: TextStyle(color: c.danger, fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: Space.xl),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: const Padding(padding: EdgeInsets.symmetric(vertical: Space.m), child: Text(S.saveMeter)),
          ),
        ],
      ),
    );
  }
}
