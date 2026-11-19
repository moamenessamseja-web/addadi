/// Pure Dart: what to notify, when, and without duplicates. The Android side is behind [NotificationBackend]
/// so everything here can be tested without a device.
library;

import 'consumption.dart';
import 'format.dart';
import 'models.dart';

abstract class NotificationBackend {
  Future<bool> permissionGranted();

  /// Asks the OS for the notification permission (Android 13+). Returns whether it is granted afterwards.
  Future<bool> requestPermission();

  Future<void> showNow(int id, String title, String body);

  /// Schedules at an absolute moment (not affected by the device time zone).
  Future<void> scheduleAt(int id, String title, String body, DateTime when);

  Future<void> cancel(int id);
}

/// Used when the platform plugin could not start: nothing is ever scheduled or shown, the app keeps working.
class NoopNotificationBackend implements NotificationBackend {
  const NoopNotificationBackend();

  @override
  Future<bool> permissionGranted() async => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> showNow(int id, String title, String body) async {}

  @override
  Future<void> scheduleAt(int id, String title, String body, DateTime when) async {}

  @override
  Future<void> cancel(int id) async {}
}

class NotificationTexts {
  const NotificationTexts({
    required this.dueTitle,
    required this.dueBody,
    required this.spikeTitle,
    required this.spikeBody,
  });

  final String dueTitle;
  final String Function(String meterTitle, String lastDate) dueBody;
  final String spikeTitle;
  final String Function(String meterTitle, String percent) spikeBody;
}

enum NotificationKind { due, spike }

/// Stable per meter and kind (meter ids are numeric strings), so a notification can be cancelled later.
int notificationId(String meterId, NotificationKind kind) {
  final n = int.tryParse(meterId);
  final base = n != null ? n % 100000000 : (meterId.hashCode & 0x1fffffff) % 100000000;
  return base * 4 + kind.index;
}

/// The moment a reading becomes due: [dueAfterDays] after the latest reading, at [hour] local time.
DateTime dueMoment(DateTime lastReadingAt, {int dueAfterDays = 30, int hour = 9}) =>
    DateTime(lastReadingAt.year, lastReadingAt.month, lastReadingAt.day + dueAfterDays, hour);

/// A spike notification is sent once per latest reading: the same meter and comparison period never alerts twice,
/// and a newer reading that is still a spike (a changed state) alerts again.
bool spikeNeedsAlert(MeterAnalysis analysis, String? lastAlertedReadingId) =>
    analysis.status == MeterStatus.spike &&
    analysis.latest != null &&
    analysis.latest!.id != lastAlertedReadingId;

class NotificationCoordinator {
  NotificationCoordinator(this.backend, this.texts);

  final NotificationBackend backend;
  NotificationTexts texts;

  /// Set when the last operation failed (shown in settings); cleared by the next successful one.
  String? lastError;

  Future<bool> permissionGranted() async {
    try {
      return await backend.permissionGranted();
    } catch (e) {
      lastError = e.toString();
      return false;
    }
  }

  Future<bool> requestPermission() async {
    try {
      return await backend.requestPermission();
    } catch (e) {
      lastError = e.toString();
      return false;
    }
  }

  /// Re-arms the "reading due" reminder of every meter: cancels the old ones, then schedules the ones that are
  /// still in the future. When [enabled] is false or the OS permission is missing, nothing stays scheduled.
  Future<void> syncDueReminders({
    required bool enabled,
    required List<Meter> meters,
    required Map<String, List<Reading>> sortedReadingsByMeter,
    required DateTime now,
  }) async {
    try {
      for (final m in meters) {
        await backend.cancel(notificationId(m.id, NotificationKind.due));
      }
      if (!enabled || !await backend.permissionGranted()) {
        lastError = null;
        return;
      }
      for (final m in meters) {
        final readings = sortedReadingsByMeter[m.id] ?? const <Reading>[];
        if (readings.isEmpty) continue;
        final last = readings.last;
        final when = dueMoment(last.at);
        if (!when.isAfter(now)) continue;
        await backend.scheduleAt(
          notificationId(m.id, NotificationKind.due),
          texts.dueTitle,
          texts.dueBody(m.title, formatDate(last.at)),
          when,
        );
      }
      lastError = null;
    } catch (e) {
      lastError = e.toString();
    }
  }

  /// Shows the spike notification now. Returns true only when it was really handed to the OS.
  Future<bool> notifySpike({required bool enabled, required Meter meter, required MeterAnalysis analysis}) async {
    final percent = analysis.spikePercent;
    if (!enabled || percent == null) return false;
    try {
      if (!await backend.permissionGranted()) return false;
      await backend.showNow(
        notificationId(meter.id, NotificationKind.spike),
        texts.spikeTitle,
        texts.spikeBody(meter.title, formatPercent(percent)),
      );
      lastError = null;
      return true;
    } catch (e) {
      lastError = e.toString();
      return false;
    }
  }

  Future<void> cancelMeter(String meterId) async {
    try {
      for (final k in NotificationKind.values) {
        await backend.cancel(notificationId(meterId, k));
      }
    } catch (e) {
      lastError = e.toString();
    }
  }
}
