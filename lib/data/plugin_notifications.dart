import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/notifications.dart';

/// The real Android notifications (flutter_local_notifications). Reminders are scheduled with an inexact
/// "allow while idle" alarm, so no special exact-alarm permission is needed; they may fire a few minutes late.
class PluginNotificationBackend implements NotificationBackend {
  PluginNotificationBackend._();

  static const _channelId = 'addady_readings';
  static const _channelName = 'تنبيهات القراءات';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<PluginNotificationBackend> create() async {
    tzdata.initializeTimeZones();
    final backend = PluginNotificationBackend._();
    await backend._plugin.initialize(
      const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    );
    await backend._android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'تنبيهات الزيادة الملحوظة في الاستهلاك وتذكير القراءات',
        importance: Importance.high,
      ),
    );
    return backend;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  @override
  Future<bool> permissionGranted() async => await _android?.areNotificationsEnabled() ?? true;

  @override
  Future<bool> requestPermission() async => await _android?.requestNotificationsPermission() ?? true;

  @override
  Future<void> showNow(int id, String title, String body) => _plugin.show(id, title, body, _details);

  @override
  Future<void> scheduleAt(int id, String title, String body, DateTime when) {
    return _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(when, tz.local), // an absolute moment: not affected by the device time zone
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id);
}
