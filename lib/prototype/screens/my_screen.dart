import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../diary_controller.dart';
import '../diary_entry.dart';
import '../widgets/harutalk_ui.dart';
import '../widgets/tori_mascot.dart';

/// 통계 집계 기간.
enum StatsPeriod {
  weekly('주간'),
  monthly('월간'),
  yearly('연간');

  const StatsPeriod(this.label);

  final String label;
}

class MyScreen extends StatefulWidget {
  const MyScreen({super.key, required this.controller});

  final DiaryController controller;

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  StatsPeriod _period = StatsPeriod.monthly;
  late DateTime _anchor;

  DiaryController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _anchor = DateTime.now();
  }

  /// 현재 기간/기준일이 가리키는 날짜 범위 [start, end).
  ({DateTime start, DateTime end}) get _range {
    switch (_period) {
      case StatsPeriod.weekly:
        final monday = _anchor.subtract(Duration(days: _anchor.weekday - 1));
        final start = DateTime(monday.year, monday.month, monday.day);
        return (start: start, end: start.add(const Duration(days: 7)));
      case StatsPeriod.monthly:
        return (
          start: DateTime(_anchor.year, _anchor.month),
          end: DateTime(_anchor.year, _anchor.month + 1),
        );
      case StatsPeriod.yearly:
        return (start: DateTime(_anchor.year), end: DateTime(_anchor.year + 1));
    }
  }

  String get _periodLabel {
    final range = _range;
    switch (_period) {
      case StatsPeriod.weekly:
        final last = range.end.subtract(const Duration(days: 1));
        return '${range.start.month}월 ${range.start.day}일 ~ ${last.month}월 ${last.day}일';
      case StatsPeriod.monthly:
        return '${_anchor.year}년 ${_anchor.month}월';
      case StatsPeriod.yearly:
        return '${_anchor.year}년';
    }
  }

  String get _periodWord => switch (_period) {
    StatsPeriod.weekly => '이번 주',
    StatsPeriod.monthly => '이번 달',
    StatsPeriod.yearly => '올해',
  };

  String get _countLabel => switch (_period) {
    StatsPeriod.weekly => '주간 기록',
    StatsPeriod.monthly => '이번 달 기록',
    StatsPeriod.yearly => '올해 기록',
  };

  // 미래 기간으로는 이동하지 않는다(아직 오지 않은 날은 데이터가 없으므로).
  bool get _canGoNext => !DateTime.now().isBefore(_range.end);

  void _selectPeriod(StatsPeriod period) {
    setState(() {
      _period = period;
      _anchor = DateTime.now();
    });
  }

  void _shift(int delta) {
    setState(() {
      switch (_period) {
        case StatsPeriod.weekly:
          _anchor = _anchor.add(Duration(days: 7 * delta));
        case StatsPeriod.monthly:
          _anchor = DateTime(_anchor.year, _anchor.month + delta, 15);
        case StatsPeriod.yearly:
          _anchor = DateTime(_anchor.year + delta, 6, 15);
      }
    });
  }

  Map<DiaryMood, int> _moodCounts(List<DiaryEntry> rangeEntries) {
    final result = {for (final mood in DiaryMood.values) mood: 0};
    for (final entry in rangeEntries) {
      result[entry.mood] = (result[entry.mood] ?? 0) + 1;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final range = _range;
        final entries = controller.entries
            .where(
              (entry) =>
                  !entry.date.isBefore(range.start) &&
                  entry.date.isBefore(range.end),
            )
            .toList();
        final counts = _moodCounts(entries);
        final average = entries.isEmpty
            ? 0.0
            : entries
                      .map((entry) => entry.satisfaction)
                      .reduce((a, b) => a + b) /
                  entries.length;

        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
          children: [
            const AppPageHeader(
              title: '통계',
              subtitle: '기록이 모이면 마음의 흐름이 보여요.',
            ),
            const SizedBox(height: 20),
            _PeriodTabs(selected: _period, onSelect: _selectPeriod),
            const SizedBox(height: 14),
            _PeriodSwitcher(
              label: _periodLabel,
              onPrev: () => _shift(-1),
              onNext: _canGoNext ? () => _shift(1) : null,
            ),
            const SizedBox(height: 18),
            _SummaryStrip(
              countLabel: _countLabel,
              count: entries.length,
              streak: controller.currentStreak,
              average: average,
            ),
            const SizedBox(height: 24),
            Text('기분 비율', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 11),
            SoftCard(
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 122,
                    child: CustomPaint(
                      painter: _MoodDonutPainter(counts),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${entries.length}',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const Text(
                              '기록',
                              style: TextStyle(
                                color: HarutalkColors.muted,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      children: [
                        for (final mood in DiaryMood.values)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: _LegendRow(
                              mood: mood,
                              count: counts[mood] ?? 0,
                              total: entries.length,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('만족도 흐름', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 11),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        average.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(color: HarutalkColors.primary),
                      ),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          '/ 5점',
                          style: TextStyle(
                            color: HarutalkColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 84,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _ScoreTrendPainter(entries.reversed.toList()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _AiInsightCard(
              message: _periodInsight(counts, entries),
              expression: entries.isEmpty
                  ? ToriExpression.sleeping
                  : ToriExpression.thinking,
            ),
          ],
        );
      },
    );
  }

  String _periodInsight(Map<DiaryMood, int> counts, List<DiaryEntry> entries) {
    if (entries.isEmpty) {
      return '아직 기록이 없어요. 토리와 오늘의 감정부터 가볍게 남겨보세요.';
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first.key;
    final keywordCounts = <String, int>{};
    for (final entry in entries) {
      for (final keyword in entry.keywords) {
        keywordCounts[keyword] = (keywordCounts[keyword] ?? 0) + 1;
      }
    }
    final topKeyword = keywordCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final keywordText = topKeyword.isEmpty ? '일상' : topKeyword.first.key;
    return '${top.emoji} $_periodWord에는 ${top.label}을 가장 자주 느꼈고, '
        '$keywordText와 함께한 날이 많았어요. 기록이 더 쌓이면 토리가 관계를 자세히 알려줄게요.';
  }
}

class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs({required this.selected, required this.onSelect});

  final StatsPeriod selected;
  final ValueChanged<StatsPeriod> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final period in StatsPeriod.values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(period),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: period == selected
                        ? Colors.white
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: period == selected
                        ? const [
                            BoxShadow(
                              color: Color(0x0F52675A),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    period.label,
                    style: TextStyle(
                      color: period == selected
                          ? HarutalkColors.primaryDark
                          : HarutalkColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PeriodSwitcher extends StatelessWidget {
  const _PeriodSwitcher({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left_rounded),
          color: HarutalkColors.muted,
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
        IconButton(
          // 미래 기간은 데이터가 없으므로 현재 기간까지만 이동.
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
          color: HarutalkColors.muted,
        ),
      ],
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.countLabel,
    required this.count,
    required this.streak,
    required this.average,
  });

  final String countLabel;
  final int count;
  final int streak;
  final double average;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryItem(
          icon: Icons.calendar_today_rounded,
          value: '$count일',
          label: countLabel,
        ),
        const SizedBox(width: 8),
        _SummaryItem(
          icon: Icons.local_fire_department_rounded,
          value: '$streak일',
          label: '연속 기록',
        ),
        const SizedBox(width: 8),
        _SummaryItem(
          icon: Icons.star_rounded,
          value: average.toStringAsFixed(1),
          label: '평균 점수',
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SoftCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: HarutalkColors.primary, size: 20),
            const SizedBox(height: 7),
            Text(
              value,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: HarutalkColors.muted,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.mood,
    required this.count,
    required this.total,
  });

  final DiaryMood mood;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : (count / total * 100).round();
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: mood.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            mood.label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          '$percent%',
          style: const TextStyle(
            color: HarutalkColors.muted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AiInsightCard extends StatelessWidget {
  const _AiInsightCard({required this.message, required this.expression});

  final String message;
  final ToriExpression expression;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: HarutalkColors.cream,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ToriMascot(expression: expression, size: 72),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI 한 줄 회고',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(message, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodDonutPainter extends CustomPainter {
  _MoodDonutPainter(this.counts);

  final Map<DiaryMood, int> counts;

  @override
  void paint(Canvas canvas, Size size) {
    final total = counts.values.fold<int>(0, (sum, value) => sum + value);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final background = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..color = const Color(0xFFF0F2EF);
    canvas.drawCircle(center, radius, background);
    if (total == 0) return;

    var start = -math.pi / 2;
    for (final mood in DiaryMood.values) {
      final sweep = (counts[mood] ?? 0) / total * math.pi * 2;
      if (sweep == 0) continue;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.butt
        ..color = mood.color;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _MoodDonutPainter oldDelegate) {
    return oldDelegate.counts != counts;
  }
}

class _ScoreTrendPainter extends CustomPainter {
  _ScoreTrendPainter(this.entries);

  final List<DiaryEntry> entries;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFFE9EEE9)
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      final y = size.height * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    if (entries.isEmpty) return;
    final recent = entries.length > 7
        ? entries.sublist(entries.length - 7)
        : entries;
    final path = Path();
    final points = <Offset>[];
    for (var index = 0; index < recent.length; index++) {
      final x = recent.length == 1
          ? size.width / 2
          : size.width * index / (recent.length - 1);
      final y =
          size.height - ((recent[index].satisfaction - 1) / 4 * size.height);
      points.add(Offset(x, y));
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final line = Paint()
      ..color = HarutalkColors.primary
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, line);
    final dot = Paint()..color = HarutalkColors.primary;
    for (final point in points) {
      canvas.drawCircle(point, 3.5, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _ScoreTrendPainter oldDelegate) {
    return oldDelegate.entries != entries;
  }
}
