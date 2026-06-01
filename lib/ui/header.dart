import 'package:flutter/material.dart';

import '../models/app_styles.dart';

class RhythmHeader extends StatelessWidget {
  const RhythmHeader({super.key, required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryLight, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.32)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryLight.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.waves_rounded,
              color: AppColors.accentLight,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Flexible(
                    child: Text(
                      'Rhythm',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                        height: 1.05,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.24),
                      ),
                    ),
                    child: const Text(
                      'v0.1.0 데모',
                      style: TextStyle(
                        color: AppColors.accentLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '매일 30초, 감정의 파도를 기록합니다.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: '데모 데이터 초기화',
          onPressed: onReset,
          icon: const Icon(Icons.refresh_rounded, size: 20),
          style: IconButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            backgroundColor: AppColors.surfaceAlt.withValues(alpha: 0.46),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: AppColors.borderStrong.withValues(alpha: 0.48),
              ),
            ),
            padding: const EdgeInsets.all(10),
          ),
        ),
      ],
    );
  }
}
