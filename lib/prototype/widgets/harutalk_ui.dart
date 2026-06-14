import 'package:flutter/material.dart';

import 'harutalk_theme.dart';
import 'tori_mascot.dart';

export 'harutalk_theme.dart';

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// null이면 테마 surface 색을 쓴다.
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 18,
            offset: const Offset(0, 6),
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
    this.color,
    this.foreground,
  });

  final String label;
  final IconData? icon;

  /// null이면 테마 primarySoft / primaryDark를 쓴다.
  final Color? color;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final background = color ?? colors.primarySoft;
    final fg = foreground ?? colors.primaryDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class HarutalkDialogIcon extends StatelessWidget {
  const HarutalkDialogIcon({
    super.key,
    required this.icon,
    this.destructive = false,
  });

  final IconData icon;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = destructive
        ? Theme.of(context).colorScheme.error
        : colors.primaryDark;
    final background = destructive
        ? foreground.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.1,
          )
        : colors.primarySoft;
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Icon(icon, color: foreground, size: 26),
      ),
    );
  }
}

class HarutalkDialogActions extends StatelessWidget {
  const HarutalkDialogActions({
    super.key,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
    this.destructive = false,
  });

  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final danger = Theme.of(context).colorScheme.error;
    return SizedBox(
      width: double.maxFinite,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(cancelLabel),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              onPressed: onConfirm,
              style: destructive
                  ? FilledButton.styleFrom(
                      backgroundColor: danger,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    )
                  : null,
              child: Text(confirmLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class ToriEmptyStateCard extends StatelessWidget {
  const ToriEmptyStateCard({
    super.key,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.expression = ToriExpression.thinking,
  });

  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final ToriExpression expression;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SoftCard(
      color: colors.cream,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      child: Column(
        children: [
          ToriMascot(expression: expression, size: 132),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 7),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
