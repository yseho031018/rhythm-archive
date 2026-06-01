import 'package:flutter/material.dart';

import '../models/app_styles.dart';

class EnergySelector extends StatelessWidget {
  const EnergySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  static const _labels = ['매우 낮음', '낮음', '보통', '높음', '매우 높음'];
  static const _descriptions = [
    '충분한 수면과 휴식이 필요한 상태',
    '차분하고 정돈된 상태',
    '안정적이고 균형 잡힌 에너지',
    '활기차고 긍정적인 집중력',
    '강한 의욕과 최고의 몰입 상태',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '에너지 레벨',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.28),
                  width: 0.8,
                ),
              ),
              child: Text(
                '$value / 5',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accentLight,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final level = index + 1;
            final isSelected = level == value;

            final Color activeGlowColor;
            if (level <= 2) {
              activeGlowColor = const Color(0xFF758591);
            } else if (level == 3) {
              activeGlowColor = AppColors.accentBronze;
            } else {
              activeGlowColor = AppColors.accent;
            }

            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(level),
                child: AnimatedScale(
                  scale: isSelected ? 1.02 : 0.98,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutBack,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.surfaceAlt.withValues(alpha: 0.72)
                          : AppColors.surface.withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected
                            ? activeGlowColor.withValues(alpha: 0.62)
                            : AppColors.borderStrong.withValues(alpha: 0.42),
                        width: isSelected ? 1.2 : 0.9,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: activeGlowColor.withValues(alpha: 0.2),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? activeGlowColor
                                : AppColors.surfaceAlt,
                            shape: BoxShape.circle,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: activeGlowColor.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '$level',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isSelected
                                    ? AppColors.background
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          _labels[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
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
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.54),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderStrong.withValues(alpha: 0.42),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.accentLight.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '에너지 레벨 $value: ${_descriptions[value - 1]}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
