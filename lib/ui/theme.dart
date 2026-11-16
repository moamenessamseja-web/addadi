import 'package:flutter/material.dart';

import 'tokens.dart';

/// Only the color scheme and background are themed globally; components are styled where they are used.
ThemeData buildTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.brand700,
    onPrimary: c.onBrand,
    secondary: c.brand700,
    onSecondary: c.onBrand,
    error: c.danger,
    onError: c.onBrand,
    surface: c.surface,
    onSurface: c.textPrimary,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.canvas,
  );
}
