import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../domain/consumption.dart';
import '../domain/format.dart';
import 'add_reading_screen.dart';
import 'analytics_screen.dart';
import 'drawer.dart';
import 'home_screen.dart';
import 'strings.dart';
import 'tokens.dart';
import 'widgets.dart';

/// One entry of the in-app alert list. It works even when OS notifications are not available.
class AlertEntry {
  const AlertEntry({required this.meterTitle, required this.message, required this.icon, required this.isSpike});

  final String meterTitle;
  final String message;
  final IconData icon;
  final bool isSpike;
}

List<AlertEntry> buildAlerts(AppStore store) {
  final alerts = <AlertEntry>[];
  for (final m in store.meters) {
    final a = store.analysisOf(m.id);
    if (a.status == MeterStatus.spike && a.spikePercent != null) {
      alerts.add(AlertEntry(
        meterTitle: m.title,
        message: '${S.spike} ${formatPercent(a.spikePercent!)}',
        icon: Icons.trending_up,
        isSpike: true,
      ));
    }
    if (a.isDue) {
      alerts.add(AlertEntry(meterTitle: m.title, message: S.due, icon: Icons.schedule, isSpike: false));
    }
  }
  return alerts;
}

class Shell extends StatefulWidget {
  const Shell({super.key, required this.store});

  final AppStore store;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _tab = 0;
  String? _meterId;

  void _goTo(int tab, String meterId) => setState(() {
        _tab = tab;
        _meterId = meterId;
      });

  void _showAlerts() {
    final alerts = buildAlerts(widget.store);
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final c = AppColors.of(ctx);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Space.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.alertsTitle, style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: Space.m),
                if (alerts.isEmpty)
                  Text(S.noAlerts, style: TextStyle(color: c.textSecondary))
                else
                  for (final a in alerts)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(a.icon, color: c.warning),
                      title: Text(a.meterTitle),
                      subtitle: Text(a.message),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final alertCount = buildAlerts(widget.store).length;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: c.surface,
            foregroundColor: c.textPrimary,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(S.appName, style: TextStyle(fontWeight: FontWeight.w800)),
            actions: [
              IconButton(
                tooltip: S.bellTooltip,
                onPressed: _showAlerts,
                icon: Badge(
                  isLabelVisible: alertCount > 0,
                  label: NumericText('$alertCount'),
                  child: const Icon(Icons.notifications_none),
                ),
              ),
            ],
          ),
          drawer: AppDrawer(store: widget.store),
          body: IndexedStack(
            index: _tab,
            children: [
              HomeScreen(
                store: widget.store,
                onAddReading: (id) => _goTo(1, id),
                onOpenAnalytics: (id) => _goTo(2, id),
              ),
              AddReadingScreen(
                store: widget.store,
                meterId: _meterId,
                onSelectMeter: (id) => setState(() => _meterId = id),
              ),
              AnalyticsScreen(
                store: widget.store,
                meterId: _meterId,
                onSelectMeter: (id) => setState(() => _meterId = id),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            backgroundColor: c.surface,
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.speed), label: S.tabMeters),
              NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: S.tabAddReading),
              NavigationDestination(icon: Icon(Icons.show_chart), label: S.tabAnalytics),
            ],
          ),
        );
      },
    );
  }
}
