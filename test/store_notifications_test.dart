import 'package:addady/data/app_store.dart';
import 'package:addady/data/storage.dart';
import 'package:addady/domain/models.dart';
import 'package:addady/domain/notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_backend.dart';

final _texts = NotificationTexts(
  dueTitle: 'due',
  dueBody: (meter, date) => '$meter $date',
  spikeTitle: 'spike',
  spikeBody: (meter, pct) => '$meter $pct',
);

Future<(AppStore, FakeBackend, Meter)> _setup({bool granted = true}) async {
  final backend = FakeBackend()..granted = granted;
  final store = await AppStore.load(MemoryStorage(), notifications: NotificationCoordinator(backend, _texts));
  final meter = await store.addMeter(type: UtilityType.electricity, place: 'home', unit: 'kWh');
  return (store, backend, meter);
}

/// Three readings 100 -> 150 -> 220 over the last 70 days: the last period is +40% against the one before.
Future<void> _addSpikeReadings(AppStore store, Meter meter) async {
  final now = DateTime.now();
  await store.addReading(meterId: meter.id, value: 100, at: now.subtract(const Duration(days: 70)), isReset: false);
  await store.addReading(meterId: meter.id, value: 150, at: now.subtract(const Duration(days: 40)), isReset: false);
  await store.addReading(meterId: meter.id, value: 220, at: now.subtract(const Duration(days: 10)), isReset: false);
}

void main() {
  test('saving readings schedules the due reminder and alerts once on a spike', () async {
    final (store, backend, meter) = await _setup();
    await _addSpikeReadings(store, meter);
    expect(backend.shown.length, equals(1));
    expect(backend.scheduled.isNotEmpty, isTrue);
    expect(backend.scheduledIds.last, equals(notificationId(meter.id, NotificationKind.due)));

    await store.syncNotifications(); // re-syncing must never repeat the spike alert
    expect(backend.shown.length, equals(1));
  });

  test('a newer reading that is still a spike alerts again; a stable one does not', () async {
    final (store, backend, meter) = await _setup();
    await _addSpikeReadings(store, meter);
    final now = DateTime.now();
    await store.addReading(meterId: meter.id, value: 400, at: now.subtract(const Duration(days: 2)), isReset: false); // +160%
    expect(backend.shown.length, equals(2));
    await store.addReading(meterId: meter.id, value: 410, at: now.subtract(const Duration(days: 1)), isReset: false); // small
    expect(backend.shown.length, equals(2));
  });

  test('the preference off means no notification and nothing scheduled', () async {
    final (store, backend, meter) = await _setup();
    await store.setNotificationsEnabled(false);
    await _addSpikeReadings(store, meter);
    expect(backend.shown.length, equals(0));
    expect(backend.scheduled.length, equals(0));
    await store.setNotificationsEnabled(true);
    expect(backend.scheduled.isNotEmpty, isTrue);
  });

  test('enabling while the OS blocks notifications reports false and schedules nothing', () async {
    final (store, backend, meter) = await _setup(granted: false);
    await _addSpikeReadings(store, meter);
    expect(await store.setNotificationsEnabled(true), isFalse);
    expect(backend.shown.length, equals(0));
    expect(backend.scheduled.length, equals(0));
  });

  test('deleting a meter cancels both of its notifications', () async {
    final (store, backend, meter) = await _setup();
    await store.deleteMeter(meter.id);
    expect(backend.cancelled.contains(notificationId(meter.id, NotificationKind.due)), isTrue);
    expect(backend.cancelled.contains(notificationId(meter.id, NotificationKind.spike)), isTrue);
  });

  test('a notification failure never fails the saved reading', () async {
    final (store, backend, meter) = await _setup();
    backend.throwOnShow = true;
    backend.throwOnSchedule = true;
    final now = DateTime.now();
    await store.addReading(meterId: meter.id, value: 100, at: now.subtract(const Duration(days: 70)), isReset: false);
    await store.addReading(meterId: meter.id, value: 150, at: now.subtract(const Duration(days: 40)), isReset: false);
    final problem = await store.addReading(meterId: meter.id, value: 220, at: now.subtract(const Duration(days: 10)), isReset: false);
    expect(problem, isNull);
    expect(store.readingsOf(meter.id).length, equals(3));
  });

  test('settings and the spike dedup survive a reload', () async {
    final storage = MemoryStorage();
    final backend = FakeBackend();
    final store = await AppStore.load(storage, notifications: NotificationCoordinator(backend, _texts));
    final meter = await store.addMeter(type: UtilityType.water, place: '', unit: 'm³');
    await _addSpikeReadings(store, meter);
    await store.setNotificationsEnabled(false);
    final reloaded = await AppStore.load(storage, notifications: NotificationCoordinator(backend, _texts));
    expect(reloaded.notificationsEnabled, isFalse);
  });
}
