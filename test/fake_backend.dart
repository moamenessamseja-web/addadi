import 'package:addady/domain/notifications.dart';

class FakeBackend implements NotificationBackend {
  bool granted = true;
  bool throwOnSchedule = false;
  bool throwOnShow = false;
  final List<String> shown = [];
  final List<String> scheduled = [];
  final List<DateTime> scheduledAt = [];
  final List<int> scheduledIds = [];
  final List<int> cancelled = [];

  @override
  Future<bool> permissionGranted() async => granted;

  @override
  Future<bool> requestPermission() async => granted;

  @override
  Future<void> showNow(int id, String title, String body) async {
    if (throwOnShow) throw StateError('plugin failure');
    shown.add('$id|$title|$body');
  }

  @override
  Future<void> scheduleAt(int id, String title, String body, DateTime when) async {
    if (throwOnSchedule) throw StateError('plugin failure');
    scheduled.add('$id|$title|$body');
    scheduledAt.add(when);
    scheduledIds.add(id);
  }

  @override
  Future<void> cancel(int id) async => cancelled.add(id);
}
