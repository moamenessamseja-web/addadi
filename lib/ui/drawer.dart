import 'package:flutter/material.dart';

import '../data/app_store.dart';
import 'add_meter_sheet.dart';
import 'edit_meter_page.dart';
import 'strings.dart';
import 'tokens.dart';
import 'widgets.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(Space.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.appName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: c.brand900)),
                  const SizedBox(height: Space.xs),
                  Text(S.promise, style: TextStyle(color: c.textSecondary)),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.speed),
              title: Text(S.manageMeters),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ManageMetersPage(store: store)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: Text(S.alertThreshold),
              subtitle: ListenableBuilder(
                listenable: store,
                builder: (context, _) => NumericText('${store.thresholdPercent.round()}%'),
              ),
              onTap: () => showDialog<void>(context: context, builder: (_) => _ThresholdDialog(store: store)),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(S.languageTitle),
              subtitle: ListenableBuilder(
                listenable: store,
                builder: (context, _) => Text(store.language == 'en' ? S.languageEnglish : S.languageArabic),
              ),
              onTap: () => showDialog<void>(context: context, builder: (_) => _LanguageDialog(store: store)),
            ),
            _NotificationsTile(store: store),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: Text(S.theme),
              onTap: () => showDialog<void>(context: context, builder: (_) => _ThemeDialog(store: store)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsTile extends StatelessWidget {
  const _NotificationsTile({required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => FutureBuilder<bool>(
        future: store.notificationsPermitted(),
        builder: (context, snapshot) {
          final permitted = snapshot.data ?? false;
          final enabled = store.notificationsEnabled;
          final String status;
          if (!enabled) {
            status = S.notificationsOff;
          } else if (!permitted) {
            status = S.notificationsBlocked;
          } else if (store.notificationError != null) {
            status = S.notificationsError;
          } else {
            status = S.notificationsOn;
          }
          return SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: Text(S.notificationsTitle),
            subtitle: Text(status),
            value: enabled,
            onChanged: (value) async {
              final allowed = await store.setNotificationsEnabled(value);
              if (!context.mounted) return;
              if (value && !allowed) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.notificationsBlocked)));
              }
            },
          );
        },
      ),
    );
  }
}

class _ThresholdDialog extends StatefulWidget {
  const _ThresholdDialog({required this.store});

  final AppStore store;

  @override
  State<_ThresholdDialog> createState() => _ThresholdDialogState();
}

class _ThresholdDialogState extends State<_ThresholdDialog> {
  late double _value = widget.store.thresholdPercent.clamp(10, 100).toDouble();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.alertThreshold),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.thresholdHelper, style: TextStyle(color: AppColors.of(context).textSecondary)),
          const SizedBox(height: Space.l),
          Center(child: NumericText('${_value.round()}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
          Slider(
            value: _value,
            min: 10,
            max: 100,
            divisions: 18,
            label: '${_value.round()}%',
            onChanged: (v) => setState(() => _value = v),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(S.cancel)),
        FilledButton(
          onPressed: () async {
            await widget.store.setThresholdPercent(_value);
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          child: Text(S.saveSetting),
        ),
      ],
    );
  }
}

class _LanguageDialog extends StatelessWidget {
  const _LanguageDialog({required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.languageTitle),
      content: ListenableBuilder(
        listenable: store,
        builder: (context, _) => SegmentedButton<String>(
          segments: [
            ButtonSegment<String>(value: 'ar', label: Text(S.languageArabic)),
            ButtonSegment<String>(value: 'en', label: Text(S.languageEnglish)),
          ],
          selected: {store.language},
          onSelectionChanged: (s) => store.setLanguage(s.first),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(S.close))],
    );
  }
}

class _ThemeDialog extends StatelessWidget {
  const _ThemeDialog({required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.theme),
      content: ListenableBuilder(
        listenable: store,
        builder: (context, _) => SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment<ThemeMode>(value: ThemeMode.system, label: Text(S.themeSystem)),
            ButtonSegment<ThemeMode>(value: ThemeMode.light, label: Text(S.themeLight)),
            ButtonSegment<ThemeMode>(value: ThemeMode.dark, label: Text(S.themeDark)),
          ],
          selected: {store.themeMode},
          onSelectionChanged: (s) => store.setThemeMode(s.first),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(S.close))],
    );
  }
}

class ManageMetersPage extends StatelessWidget {
  const ManageMetersPage({super.key, required this.store});

  final AppStore store;

  Future<void> _confirmDelete(BuildContext context, String meterId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.deleteConfirmTitle),
        content: Text(S.deleteConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(S.cancel)),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(S.delete)),
        ],
      ),
    );
    if (ok == true) await store.deleteMeter(meterId);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(S.manageMeters)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddMeterSheet(context, store),
        icon: const Icon(Icons.add),
        label: Text(S.addMeter),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final meters = store.meters;
          if (meters.isEmpty) {
            return Center(child: Text(S.noMetersToManage, style: TextStyle(color: c.textSecondary)));
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              for (final m in meters)
                ListTile(
                  leading: UtilityBadge(m.type, size: 40),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => EditMeterPage(store: store, meterId: m.id))),
                  title: Text(m.title),
                  subtitle: Row(children: [
                    NumericText(m.unit),
                    const SizedBox(width: Space.m),
                    NumericText('${store.readingsOf(m.id).length}'),
                    const SizedBox(width: Space.xs),
                    Text(S.meterReadingsCount),
                    if (m.tariff != null) ...[
                      const SizedBox(width: Space.m),
                      Icon(Icons.request_quote_outlined, size: 14, color: c.textSecondary),
                      const SizedBox(width: Space.xs),
                      Text(S.tariffSet),
                    ],
                  ]),
                  trailing: IconButton(
                    tooltip: S.deleteMeter,
                    icon: Icon(Icons.delete_outline, color: c.danger),
                    onPressed: () => _confirmDelete(context, m.id),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
