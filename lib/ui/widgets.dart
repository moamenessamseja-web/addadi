import 'package:flutter/material.dart';

import '../domain/models.dart';
import 'tokens.dart';

/// A number (with its unit, date or percent sign) is always one left-to-right run, isolated from the
/// surrounding right-to-left Arabic text.
class NumericText extends StatelessWidget {
  const NumericText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.ltr,
        child: Text(text, style: style, textDirection: TextDirection.ltr),
      );
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.padding});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.card),
        side: BorderSide(color: c.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.card),
        onTap: onTap,
        child: Padding(padding: padding ?? const EdgeInsets.all(Space.l), child: child),
      ),
    );
  }
}

/// Status is always text + icon + color, never color alone.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.icon, required this.color});

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: Space.m, vertical: Space.xs + 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: Space.xs + 2),
            Flexible(
              child: Text(
                label,
                style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
}

class UtilityBadge extends StatelessWidget {
  const UtilityBadge(this.type, {super.key, this.size = 44});

  final UtilityType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.of(context).utility(type);
    return Semantics(
      label: type.labelAr,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(Radii.input),
        ),
        child: Icon(utilityIcon(type), color: color, size: size * 0.55),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
          if (action != null) action!,
        ],
      );
}

/// One label above one value; the value can be any widget (usually a [NumericText]).
class LabeledValue extends StatelessWidget {
  const LabeledValue({super.key, required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(color: c.textSecondary, fontSize: 12)),
        const SizedBox(height: 2),
        value,
      ],
    );
  }
}
