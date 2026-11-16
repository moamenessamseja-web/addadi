import 'package:flutter/material.dart';

import '../domain/models.dart';

/// Design tokens from the design foundation (4.1 colors, 4.3 spacing and shape).
/// Utility colors identify the utility type; status colors identify the condition. They are never mixed.
class AppColors {
  const AppColors._({
    required this.brand900,
    required this.brand700,
    required this.brand100,
    required this.onBrand,
    required this.surface,
    required this.canvas,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.electricity,
    required this.water,
    required this.gas,
    required this.success,
    required this.warning,
    required this.danger,
  });

  final Color brand900;
  final Color brand700;
  final Color brand100;
  final Color onBrand;
  final Color surface;
  final Color canvas;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color electricity;
  final Color water;
  final Color gas;
  final Color success;
  final Color warning;
  final Color danger;

  static const light = AppColors._(
    brand900: Color(0xFF12304A),
    brand700: Color(0xFF176B70),
    brand100: Color(0xFFE2F2F0),
    onBrand: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    canvas: Color(0xFFF5F7FA),
    textPrimary: Color(0xFF172B3A),
    textSecondary: Color(0xFF687887),
    border: Color(0xFFE1E7ED),
    electricity: Color(0xFFD99A24),
    water: Color(0xFF278BCB),
    gas: Color(0xFFD97832),
    success: Color(0xFF27845B),
    warning: Color(0xFFB87918),
    danger: Color(0xFFB84545),
  );

  /// Dark variant: same hue roles, lifted for contrast on dark surfaces.
  static const dark = AppColors._(
    brand900: Color(0xFFB9D7E8),
    brand700: Color(0xFF4FB3B0),
    brand100: Color(0xFF1C3A3C),
    onBrand: Color(0xFF062321),
    surface: Color(0xFF16242F),
    canvas: Color(0xFF0E1822),
    textPrimary: Color(0xFFE6EDF3),
    textSecondary: Color(0xFF9DB0C0),
    border: Color(0xFF2A3D4C),
    electricity: Color(0xFFE8B04A),
    water: Color(0xFF55AEE6),
    gas: Color(0xFFE8914F),
    success: Color(0xFF4CB98A),
    warning: Color(0xFFDDA844),
    danger: Color(0xFFE07A7A),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  Color utility(UtilityType type) => switch (type) {
        UtilityType.electricity => electricity,
        UtilityType.water => water,
        UtilityType.gas => gas,
      };
}

IconData utilityIcon(UtilityType type) => switch (type) {
      UtilityType.electricity => Icons.bolt,
      UtilityType.water => Icons.water_drop,
      UtilityType.gas => Icons.local_fire_department,
    };

class Space {
  const Space._();
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

class Radii {
  const Radii._();
  static const double control = 10;
  static const double input = 12;
  static const double card = 18;
  static const double panel = 22;
}
