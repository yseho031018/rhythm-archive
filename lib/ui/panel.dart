import 'package:flutter/material.dart';

import '../models/app_styles.dart';

class RhythmPanel extends StatelessWidget {
  const RhythmPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceAlt.withValues(alpha: 0.62),
            AppColors.surface.withValues(alpha: 0.88),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: AppColors.borderStrong.withValues(alpha: 0.52),
          width: 1,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
