import 'package:flutter/material.dart';

import 'app.dart';
import 'data/app_store.dart';
import 'data/plugin_notifications.dart';
import 'data/storage.dart';
import 'domain/notifications.dart';
import 'ui/notification_texts.dart';

Future<NotificationBackend> _openNotifications() async {
  try {
    return await PluginNotificationBackend.create();
  } catch (_) {
    // The app works without notifications; settings explain that they are unavailable.
    return const NoopNotificationBackend();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final storage = await PrefsStorage.open();
    final coordinator = NotificationCoordinator(await _openNotifications(), arabicNotificationTexts);
    final store = await AppStore.load(storage, notifications: coordinator);
    await store.syncNotifications();
    runApp(EaddadyApp(store: store));
  } catch (_) {
    // Without local storage nothing can be saved, so say so instead of showing a blank screen.
    runApp(const MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: Center(child: Text('تعذّر فتح التخزين المحلي على هذا الجهاز'))),
      ),
    ));
  }
}
