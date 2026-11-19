import 'package:addady/domain/consumption.dart';
import 'package:addady/domain/models.dart';
import 'package:addady/domain/notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_backend.dart';

final _texts = NotificationTexts(
  dueTitle: 'due',
  dueBody: (meter, date) => '$meter since $date',
  spikeTitle: 'spike',
  spikeBody: (meter, pct) => '$meter $pct',
);

final _day0 = DateTime(2026, 1, 1);
const _m1 = Meter(id: '1000', type: UtilityType.electricity, place: 'home', unit: 'kWh');
const _m2 = Meter(id: '2000', type: UtilityType.water, place: '', unit: 'm3');

Reading r(String id, double v, int day) => Reading(id: id, meterId: '1000', value: v, at: _day0.add(Duration(days: day)));

void main() {
  group('ids and due moment', () {
    test('ids are stable and distinct per meter and kind', () {
      final ids = {
        notificationId('1000', NotificationKind.due),
        notificationId('1000', NotificationKind.spike),
        notificationId('2000', NotificationKind.due),
        notificationId('2000', NotificationKind.spike),
      };
      expect(ids.length, equals(4));
      expect(notificationId('1000', NotificationKind.due), equals(notificationId('1000', NotificationKind.due)));
    });
    test('ids fit a 32-bit signed integer even for real microsecond meter ids', () {
      expect(notificationId('1763280000123456', NotificationKind.spike) < 2147483647, isTrue);
    });
    test('due moment is 30 days later at 09:00', () {
      expect(dueMoment(DateTime(2026, 1, 15, 22, 30)), equals(DateTime(2026, 2, 14, 9)));
      expect(dueMoment(DateTime(2026, 12, 20)), equals(DateTime(2027, 1, 19, 9)));
    });
  });

  group('spikeNeedsAlert', () {
    final readings = [r('1', 100, 0), r('2', 150, 30), r('3', 220, 60)];
    final analysis = analyzeMeter(readings, thresholdPercent: 30, now: _day0.add(const Duration(days: 61)));
    test('first time yes, same latest reading never twice, a newer reading alerts again', () {
      expect(analysis.status == MeterStatus.spike, isTrue);
      expect(spikeNeedsAlert(analysis, null), isTrue);
      expect(spikeNeedsAlert(analysis, '3'), isFalse);
      expect(spikeNeedsAlert(analysis, '2'), isTrue);
    });
    test('a stable meter never needs an alert', () {
      final stable = analyzeMeter([r('1', 100, 0), r('2', 150, 30), r('3', 190, 60)], thresholdPercent: 30, now: _day0);
      expect(spikeNeedsAlert(stable, null), isFalse);
    });
  });

  group('syncDueReminders', () {
    final byMeter = {
      '1000': [r('1', 100, 0), r('2', 150, 30)],
    };

    test('schedules the future due reminder and cancels the previous one first', () async {
      final b = FakeBackend();
      final c = NotificationCoordinator(b, _texts);
      await c.syncDueReminders(
        enabled: true,
        meters: const [_m1, _m2],
        sortedReadingsByMeter: byMeter,
        now: _day0.add(const Duration(days: 31)),
      );
      expect(b.cancelled.length, equals(2));
      expect(b.scheduled.length, equals(1));
      expect(b.scheduledAt.single, equals(DateTime(2026, 3, 2, 9))); // day 30 = Jan 31 + 30 days
      expect(b.scheduledIds.single, equals(notificationId('1000', NotificationKind.due)));
      expect(b.scheduled.single.contains('home'), isTrue);
      expect(c.lastError, isNull);
    });
    test('an overdue meter gets no scheduled reminder (the in-app list shows it)', () async {
      final b = FakeBackend();
      await NotificationCoordinator(b, _texts).syncDueReminders(
        enabled: true,
        meters: const [_m1],
        sortedReadingsByMeter: byMeter,
        now: _day0.add(const Duration(days: 100)),
      );
      expect(b.scheduled.length, equals(0));
    });
    test('disabled preference: old reminders are cancelled and nothing is scheduled', () async {
      final b = FakeBackend();
      await NotificationCoordinator(b, _texts).syncDueReminders(
        enabled: false,
        meters: const [_m1],
        sortedReadingsByMeter: byMeter,
        now: _day0.add(const Duration(days: 31)),
      );
      expect(b.cancelled.length, equals(1));
      expect(b.scheduled.length, equals(0));
    });
    test('missing OS permission: nothing is scheduled', () async {
      final b = FakeBackend()..granted = false;
      await NotificationCoordinator(b, _texts).syncDueReminders(
        enabled: true,
        meters: const [_m1],
        sortedReadingsByMeter: byMeter,
        now: _day0.add(const Duration(days: 31)),
      );
      expect(b.scheduled.length, equals(0));
    });
    test('a plugin failure is recorded, not thrown', () async {
      final b = FakeBackend()..throwOnSchedule = true;
      final c = NotificationCoordinator(b, _texts);
      await c.syncDueReminders(
        enabled: true,
        meters: const [_m1],
        sortedReadingsByMeter: byMeter,
        now: _day0.add(const Duration(days: 31)),
      );
      expect(c.lastError != null, isTrue);
    });
  });

  group('notifySpike and cancelMeter', () {
    final analysis = analyzeMeter(
      [r('1', 100, 0), r('2', 150, 30), r('3', 220, 60)],
      thresholdPercent: 30,
      now: _day0.add(const Duration(days: 61)),
    );
    test('shows once when enabled and permitted', () async {
      final b = FakeBackend();
      final shown = await NotificationCoordinator(b, _texts).notifySpike(enabled: true, meter: _m1, analysis: analysis);
      expect(shown, isTrue);
      expect(b.shown.single.endsWith('+40%'), isTrue);
    });
    test('does not show when disabled, not permitted, or without a percentage', () async {
      final b = FakeBackend();
      final c = NotificationCoordinator(b, _texts);
      expect(await c.notifySpike(enabled: false, meter: _m1, analysis: analysis), isFalse);
      b.granted = false;
      expect(await c.notifySpike(enabled: true, meter: _m1, analysis: analysis), isFalse);
      b.granted = true;
      final none = analyzeMeter([r('1', 100, 0)], thresholdPercent: 30, now: _day0);
      expect(await c.notifySpike(enabled: true, meter: _m1, analysis: none), isFalse);
      expect(b.shown.length, equals(0));
    });
    test('cancelMeter cancels both kinds', () async {
      final b = FakeBackend();
      await NotificationCoordinator(b, _texts).cancelMeter('1000');
      expect(b.cancelled.length, equals(2));
    });
  });
}
