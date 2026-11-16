import 'package:flutter/material.dart';

import 'app.dart';
import 'data/app_store.dart';
import 'data/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final storage = await PrefsStorage.open();
    final store = await AppStore.load(storage);
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
