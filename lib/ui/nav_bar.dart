import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/app_styles.dart';

class RhythmNavBar extends StatelessWidget {
  const RhythmNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.auto_awesome_outlined, Icons.auto_awesome, '오늘'),
      (Icons.calendar_month_outlined, Icons.calendar_month, '히스토리'),
      (Icons.insights_outlined, Icons.insights, '패턴'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / items.length;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      left: itemWidth * selectedIndex,
                      top: 10,
                      width: itemWidth,
                      height: 52,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accent.withValues(alpha: 0.16),
                                AppColors.accentLight.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(items.length, (index) {
                        final isSelected = selectedIndex == index;
                        final item = items[index];

                        return SizedBox(
                          width: itemWidth,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onDestinationSelected(index),
                            child: Center(
                              child: SizedBox(
                                height: 48,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 26,
                                      child: Center(
                                        child: AnimatedScale(
                                          scale: isSelected ? 1.12 : 1.0,
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          child: Icon(
                                            isSelected ? item.$2 : item.$1,
                                            color: isSelected
                                                ? AppColors.accentLight
                                                : AppColors.textSecondary,
                                            size: 23,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      item.$3,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        height: 1.1,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? AppColors.textPrimary
                                            : AppColors.textMuted,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
