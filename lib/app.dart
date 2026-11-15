import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/app_store.dart';
import 'ui/shell.dart';
import 'ui/strings.dart';
import 'ui/theme.dart';

class EaddadyApp extends StatelessWidget {
  const EaddadyApp({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => MaterialApp(
        title: S.appName,
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: store.themeMode,
        home: Shell(store: store),
      ),
    );
  }
}
