import 'package:flutter/material.dart';

abstract final class HarutalkColors {
  static const background = Color(0xFFFFFEFA);
  static const surface = Colors.white;
  static const primary = Color(0xFF3C946B);
  static const primaryDark = Color(0xFF286D4C);
  static const primarySoft = Color(0xFFE6F2E9);
  static const cream = Color(0xFFF7F3E8);
  static const ink = Color(0xFF252A27);
  static const muted = Color(0xFF757C77);
  static const border = Color(0xFFE8ECE8);
}

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color = HarutalkColors.surface,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: HarutalkColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D52675A),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: content,
    );
  }
}

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 5),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class SmallPill extends StatelessWidget {
  const SmallPill({
    super.key,
    required this.label,
    this.icon,
    this.color = HarutalkColors.primarySoft,
    this.foreground = HarutalkColors.primaryDark,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: foreground),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
