import 'package:flutter/material.dart';

import '../models/app_styles.dart';
import '../models/rhythm_entry.dart';
import '../painters/weekly_rhythm_painter.dart';
import 'panel.dart';

class PatternTab extends StatelessWidget {
  const PatternTab({super.key, required this.entries});

  final List<RhythmEntry> entries;

  @override
  Widget build(BuildContext context) {
    final averageEnergy = entries.isEmpty
        ? 0.0
        : entries.map((e) => e.energy).reduce((a, b) => a + b) / entries.length;
    final emotionCounts = <String, int>{};
    final activityCounts = <String, int>{};
    for (final entry in entries) {
      for (final emotion in entry.emotions) {
        emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
      }
      for (final activity in entry.activities) {
        activityCounts[activity] = (activityCounts[activity] ?? 0) + 1;
      }
    }
    final topEmotion = topKey(emotionCounts) ?? '데이터 없음';
    final topActivity = topKey(activityCounts) ?? '데이터 없음';

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        RhythmPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '나의 리듬 패턴 카드',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricCard(
                    icon: Icons.battery_charging_full_rounded,
                    label: '평균 에너지',
                    value: averageEnergy.toStringAsFixed(1),
                  ),
                  _MetricCard(
                    icon: Icons.palette_outlined,
                    label: '지배적인 감정',
                    value: topEmotion,
                  ),
                  _MetricCard(
                    icon: Icons.directions_run_rounded,
                    label: '가장 잦은 활동',
                    value: topActivity,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  _insightText(averageEnergy, topEmotion, topActivity),
                  style: const TextStyle(
                    fontSize: 15.5,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        RhythmPanel(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '최근 7일간 에너지 흐름 (Bézier Spline)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 172,
                child: CustomPaint(
                  painter: WeeklyRhythmPainter(entries: entries),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _insightText(double averageEnergy, String emotion, String activity) {
    if (entries.length < 3) {
      return '아직 기록이 부족합니다. 3일 이상 성실히 기록하시면 캔버스 데이터 기반의 분석을 개시합니다.';
    }
    final tone = averageEnergy >= 3.5 ? '풍부하고 활기찬 편' : '차분하고 정적인 편';
    return '최근 ${entries.length}개의 리듬 기록에서 평균 에너지는 $tone입니다. '
        '주로 「$emotion」 감정을 느꼈으며, 「$activity」 활동과 강한 관계를 맺고 있습니다. '
        '이 파동들은 삶의 균형 상태를 나타내는 지표가 됩니다.';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.25),
                width: 0.8,
              ),
            ),
            child: Icon(icon, size: 20, color: AppColors.accentLight),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
