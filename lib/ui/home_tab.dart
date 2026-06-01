import 'package:flutter/material.dart';

import '../models/app_styles.dart';
import '../models/rhythm_entry.dart';
import '../painters/rhythm_wave_painter.dart';
import 'chip_section.dart';
import 'energy_selector.dart';
import 'panel.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.energy,
    required this.selectedEmotions,
    required this.selectedActivities,
    required this.emotionOptions,
    required this.activityOptions,
    required this.noteController,
    required this.animation,
    required this.previewEntry,
    required this.onEnergyChanged,
    required this.onEmotionToggle,
    required this.onActivityToggle,
    required this.onSave,
  });

  final int energy;
  final Set<String> selectedEmotions;
  final Set<String> selectedActivities;
  final List<String> emotionOptions;
  final List<String> activityOptions;
  final TextEditingController noteController;
  final Animation<double> animation;
  final RhythmEntry? previewEntry;
  final ValueChanged<double> onEnergyChanged;
  final ValueChanged<String> onEmotionToggle;
  final ValueChanged<String> onActivityToggle;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final input = RhythmPanel(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.22),
                        ),
                      ),
                      child: const Icon(
                        Icons.edit_note_rounded,
                        size: 18,
                        color: AppColors.accentLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '오늘의 리듬 기록',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                EnergySelector(
                  value: energy,
                  onChanged: (v) => onEnergyChanged(v.toDouble()),
                ),
                const SizedBox(height: 18),
                ChipSection(
                  title: '감정 키워드',
                  subtitle: '최대 3개 선택',
                  options: emotionOptions,
                  selected: selectedEmotions,
                  onToggle: onEmotionToggle,
                  isEmotion: true,
                ),
                const SizedBox(height: 18),
                ChipSection(
                  title: '주요 활동',
                  subtitle: '최대 3개 선택',
                  options: activityOptions,
                  selected: selectedActivities,
                  onToggle: onActivityToggle,
                  isEmotion: false,
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: noteController,
                  minLines: 2,
                  maxLines: 4,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    labelText: '짧은 메모',
                    labelStyle: const TextStyle(
                      color: AppColors.accentBronze,
                      fontWeight: FontWeight.w600,
                    ),
                    hintText: '오늘의 리듬을 한 문장으로 기록해 보세요.',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surface.withValues(alpha: 0.58),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.borderStrong.withValues(alpha: 0.44),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.accent.withValues(alpha: 0.72),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: onSave,
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accentBronze, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(AppRadii.button),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.28),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: AppColors.background,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          '오늘의 리듬 기록하기',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.background,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        final hasWavePreview = selectedEmotions.isNotEmpty;
        final canvas = RhythmPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '오늘의 파동',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.primaryLight.withValues(alpha: 0.28),
                      ),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: RepaintBoundary(
                    child: hasWavePreview
                        ? WaveCanvas(
                            energy: energy,
                            emotions: selectedEmotions,
                            entry: previewEntry,
                            animation: animation,
                          )
                        : const EmptyWavePlaceholder(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_motion_outlined,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasWavePreview
                          ? '감정과 에너지에 따라 움직이는 파동 그래프입니다. 터치하면 파동이 한 번 더 번집니다.'
                          : '감정 키워드를 선택하면 파동 그래프가 생성됩니다.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        if (wide) {
          return Row(
            children: [
              Expanded(flex: 4, child: input),
              const SizedBox(width: 16),
              Expanded(flex: 5, child: canvas),
            ],
          );
        }
        return Column(
          children: [
            Expanded(flex: 55, child: input),
            const SizedBox(height: 16),
            Expanded(flex: 45, child: canvas),
          ],
        );
      },
    );
  }
}

class EmptyWavePlaceholder extends StatelessWidget {
  const EmptyWavePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background.withValues(alpha: 0.96),
            AppColors.surface.withValues(alpha: 0.9),
          ],
        ),
        border: Border.all(
          color: AppColors.borderStrong.withValues(alpha: 0.36),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.waves_outlined,
                size: 34,
                color: AppColors.textMuted.withValues(alpha: 0.65),
              ),
              const SizedBox(height: 14),
              const Text(
                '감정 키워드를 선택해주세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '선택된 감정이 없으면 파동 그래프를 표시하지 않습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaveCanvas extends StatefulWidget {
  const WaveCanvas({
    super.key,
    required this.energy,
    required this.emotions,
    required this.entry,
    required this.animation,
  });

  final int energy;
  final Set<String> emotions;
  final RhythmEntry? entry;
  final Animation<double> animation;

  @override
  State<WaveCanvas> createState() => _WaveCanvasState();
}

class _WaveCanvasState extends State<WaveCanvas> {
  Offset? _touchPoint;
  double _touchStart = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        setState(() {
          _touchPoint = box.globalToLocal(details.globalPosition);
          _touchStart = widget.animation.value;
        });
      },
      child: AnimatedBuilder(
        animation: widget.animation,
        builder: (context, _) {
          return CustomPaint(
            painter: RhythmWavePainter(
              progress: widget.animation.value,
              entry: widget.entry,
              previewEnergy: widget.energy,
              previewEmotions: widget.emotions,
              touchPoint: _touchPoint,
              touchStart: _touchStart,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}
