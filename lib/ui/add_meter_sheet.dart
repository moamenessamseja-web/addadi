import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../domain/models.dart';
import 'strings.dart';
import 'tokens.dart';

Future<void> showAddMeterSheet(BuildContext context, AppStore store) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _AddMeterForm(store: store),
    ),
  );
}

class _AddMeterForm extends StatefulWidget {
  const _AddMeterForm({required this.store});

  final AppStore store;

  @override
  State<_AddMeterForm> createState() => _AddMeterFormState();
}

class _AddMeterFormState extends State<_AddMeterForm> {
  UtilityType _type = UtilityType.electricity;
  final _place = TextEditingController();
  late final TextEditingController _unit = TextEditingController(text: _type.defaultUnit);
  bool _saving = false;

  @override
  void dispose() {
    _place.dispose();
    _unit.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.store.addMeter(type: _type, place: _place.text, unit: _unit.text);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(S.saveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(S.addMeterTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: Space.l),
          const Text(S.meterType),
          const SizedBox(height: Space.s),
          Wrap(
            spacing: Space.s,
            children: [
              for (final t in UtilityType.values)
                ChoiceChip(
                  avatar: Icon(utilityIcon(t), size: 18),
                  label: Text(t.labelAr),
                  selected: _type == t,
                  onSelected: (_) => setState(() {
                    _type = t;
                    _unit.text = t.defaultUnit;
                  }),
                ),
            ],
          ),
          const SizedBox(height: Space.l),
          TextField(
            controller: _place,
            decoration: InputDecoration(
              labelText: S.place,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.input)),
            ),
          ),
          const SizedBox(height: Space.m),
          TextField(
            controller: _unit,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: S.unit,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.input)),
            ),
          ),
          const SizedBox(height: Space.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: const Padding(padding: EdgeInsets.symmetric(vertical: Space.m), child: Text(S.addMeter)),
            ),
          ),
        ],
      ),
    );
  }
}
