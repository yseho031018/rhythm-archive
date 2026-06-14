import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../backup_file_service.dart';
import '../diary_controller.dart';
import '../diary_entry.dart';
import '../pattern_analysis.dart';
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
  const MyScreen({
    super.key,
    required this.controller,
    this.backupFileService = const BackupFileService(),
    this.onRecord,
  });

  final DiaryController controller;
  final BackupFileService backupFileService;
  final VoidCallback? onRecord;

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

  Future<void> _exportBackup() async {
    try {
      await widget.backupFileService.saveBackup(
        controller.createBackupJson(),
        DateTime.now(),
      );
      if (!mounted) return;
      _showMessage('하루톡 백업 파일을 저장했어요.');
    } catch (_) {
      if (!mounted) return;
      _showMessage('백업 파일을 저장하지 못했어요.');
    }
  }

  Future<void> _restoreBackup() async {
    try {
      final raw = await widget.backupFileService.pickBackup();
      if (raw == null || !mounted) return;
      final preview = controller.inspectBackupJson(raw);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('백업을 복원할까요?'),
          content: _BackupPreviewContent(
            preview: preview,
            currentEntryCount: controller.entries.length,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('복원하기'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      final result = await controller.restoreBackupJson(raw);
      if (!mounted) return;
      _showMessage(result.message);
    } on FormatException catch (error) {
      if (!mounted) return;
      _showMessage(error.message.toString());
    } catch (_) {
      if (!mounted) return;
      _showMessage('백업 파일을 불러오지 못했어요.');
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모든 기록을 삭제할까요?'),
        content: const Text('삭제한 기록은 복구할 수 없습니다. 먼저 백업을 권장해요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('전체 삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final cleared = await controller.clearAllData();
    if (!mounted) return;
    _showMessage(cleared ? '모든 기록을 삭제했어요.' : '기록을 삭제하지 못했어요.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
        final colors = context.colors;

        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
          children: [
            const AppPageHeader(
              title: '통계',
              subtitle: '기록이 모이면 마음의 흐름이 보여요.',
              trailing: ThemeToggleButton(),
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
            if (entries.isEmpty)
              _StatsEmptyState(
                hasAnyEntries: controller.entries.isNotEmpty,
                onRecord: widget.onRecord,
              )
            else ...[
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
                        painter: _MoodDonutPainter(counts, colors.surfaceSoft),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${entries.length}',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              Text(
                                '기록',
                                style: TextStyle(
                                  color: colors.muted,
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
                              ?.copyWith(color: colors.primary),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '/ 5점',
                            style: TextStyle(
                              color: colors.muted,
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
                        painter: _ScoreTrendPainter(
                          entries.reversed.toList(),
                          colors.primary,
                          colors.border,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (controller.entries.isNotEmpty) ...[
              const SizedBox(height: 24),
              // 생활 패턴은 기간과 무관하게 누적 기록 전체를 분석한다.
              _LifePatternSection(report: analyzePatterns(controller.entries)),
            ],
            const SizedBox(height: 24),
            _DataManagementSection(
              entryCount: controller.entries.length,
              onExport: _exportBackup,
              onRestore: _restoreBackup,
              onClear: _clearAllData,
            ),
          ],
        );
      },
    );
  }
}

class _StatsEmptyState extends StatelessWidget {
  const _StatsEmptyState({required this.hasAnyEntries, this.onRecord});

  final bool hasAnyEntries;
  final VoidCallback? onRecord;

  @override
  Widget build(BuildContext context) {
    if (hasAnyEntries) {
      return const ToriEmptyStateCard(
        title: '이 기간에는 기록이 없어요',
        body: '다른 기간으로 이동하면 쌓아둔 마음의 흐름을 다시 볼 수 있어요.',
        expression: ToriExpression.sleeping,
      );
    }
    return ToriEmptyStateCard(
      title: '첫 기록이 통계의 시작이에요',
      body: '한 줄이 쌓이면 기분 비율과 만족도 흐름,\n생활 패턴을 토리가 함께 찾아줄게요.',
      actionLabel: onRecord == null ? null : '첫 기록 남기기',
      onAction: onRecord,
      expression: ToriExpression.thinking,
    );
  }
}

class _BackupPreviewContent extends StatelessWidget {
  const _BackupPreviewContent({
    required this.preview,
    required this.currentEntryCount,
  });

  final BackupPreview preview;
  final int currentEntryCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('현재 기록과 사용자 키워드를 선택한 백업의 내용으로 교체합니다.'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.primarySoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _BackupPreviewRow(
                icon: Icons.schedule_rounded,
                label: '백업 생성',
                value: _formatBackupDateTime(preview.exportedAt),
              ),
              const SizedBox(height: 10),
              _BackupPreviewRow(
                icon: Icons.menu_book_rounded,
                label: '백업 기록',
                value: '${preview.entryCount}개',
              ),
              const SizedBox(height: 10),
              _BackupPreviewRow(
                icon: Icons.sell_outlined,
                label: '사용자 키워드',
                value: '${preview.keywordCount}개',
              ),
              const SizedBox(height: 10),
              _BackupPreviewRow(
                icon: Icons.date_range_rounded,
                label: '기록 기간',
                value: _formatBackupRange(preview),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '현재 기록 $currentEntryCount개 → 백업 기록 ${preview.entryCount}개',
          style: TextStyle(
            color: colors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BackupPreviewRow extends StatelessWidget {
  const _BackupPreviewRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.primaryDark),
        const SizedBox(width: 9),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: colors.primaryDark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

String _formatBackupDate(DateTime date) {
  return '${date.year}.${date.month.toString().padLeft(2, '0')}.'
      '${date.day.toString().padLeft(2, '0')}';
}

String _formatBackupDateTime(DateTime? date) {
  if (date == null) return '날짜 정보 없음';
  return '${_formatBackupDate(date)} '
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}

String _formatBackupRange(BackupPreview preview) {
  final earliest = preview.earliestEntry;
  final latest = preview.latestEntry;
  if (earliest == null || latest == null) return '기록 없음';
  if (isSameDiaryDay(earliest, latest)) return _formatBackupDate(earliest);
  return '${_formatBackupDate(earliest)} ~ ${_formatBackupDate(latest)}';
}

class _DataManagementSection extends StatelessWidget {
  const _DataManagementSection({
    required this.entryCount,
    required this.onExport,
    required this.onRestore,
    required this.onClear,
  });

  final int entryCount;
  final VoidCallback onExport;
  final VoidCallback onRestore;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('내 데이터', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 11),
        SoftCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.primarySoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        color: colors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '기기에 안전하게 저장 중',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Drift · SQLite · 기록 $entryCount개',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.check_circle_rounded, color: colors.primary),
                  ],
                ),
              ),
              Divider(height: 1, color: colors.border),
              _DataActionRow(
                icon: Icons.file_download_outlined,
                title: '백업 파일 저장',
                subtitle: '기록과 사용자 키워드를 JSON으로 보관',
                onTap: onExport,
              ),
              Divider(height: 1, indent: 70, color: colors.border),
              _DataActionRow(
                icon: Icons.file_upload_outlined,
                title: '백업 파일 복원',
                subtitle: '현재 데이터를 선택한 백업으로 교체',
                onTap: onRestore,
              ),
              Divider(height: 1, indent: 70, color: colors.border),
              _DataActionRow(
                icon: Icons.delete_outline_rounded,
                title: '모든 기록 삭제',
                subtitle: '기록과 사용자 키워드를 기기에서 삭제',
                onTap: onClear,
                danger: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '로그인 없이 이 기기에 저장됩니다. 다른 기기로 옮길 때는 백업 파일을 사용해 주세요.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.muted, height: 1.45),
        ),
      ],
    );
  }
}

class _DataActionRow extends StatelessWidget {
  const _DataActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = danger
        ? Theme.of(context).colorScheme.error
        : colors.ink;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: foreground, size: 23),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: colors.muted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.muted),
          ],
        ),
      ),
    );
  }
}

class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs({required this.selected, required this.onSelect});

  final StatsPeriod selected;
  final ValueChanged<StatsPeriod> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
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
                        ? colors.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: period == selected
                        ? [
                            BoxShadow(
                              color: colors.shadow,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    period.label,
                    style: TextStyle(
                      color: period == selected
                          ? colors.primaryDark
                          : colors.muted,
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
          color: context.colors.muted,
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
          color: context.colors.muted,
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
            Icon(icon, color: context.colors.primary, size: 20),
            const SizedBox(height: 7),
            Text(
              value,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.muted,
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
          style: TextStyle(
            color: context.colors.muted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// 누적 기록을 분석한 생활 패턴 섹션.
class _LifePatternSection extends StatelessWidget {
  const _LifePatternSection({required this.report});

  final PatternReport report;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('생활 패턴', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(width: 8),
            const SmallPill(label: '전체 기록'),
          ],
        ),
        const SizedBox(height: 11),
        if (!report.hasEnoughData)
          SoftCard(
            color: colors.cream,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ToriMascot(expression: ToriExpression.sleeping, size: 88),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '아직 패턴을 찾는 중이에요',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '같은 키워드가 며칠 더 쌓이면 토리가 키워드와 기분, '
                        '만족도의 관계를 알려줄게요.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else ...[
          SoftCard(
            color: colors.cream,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ToriMascot(expression: ToriExpression.thinking, size: 92),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '토리가 찾은 관계',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      for (final sentence in report.sentences)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 7),
                          child: _PatternBullet(text: sentence),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('키워드별 평균 만족도', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 11),
          SoftCard(
            child: Column(
              children: [
                for (var i = 0; i < report.keywords.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  _KeywordStatRow(insight: report.keywords[i]),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PatternBullet extends StatelessWidget {
  const _PatternBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6, right: 8),
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: colors.primary,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: colors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _KeywordStatRow extends StatelessWidget {
  const _KeywordStatRow({required this.insight});

  final KeywordInsight insight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fraction = (insight.averageSatisfaction / 5).clamp(0.0, 1.0);
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: insight.topMood.color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            insight.topMood.emoji,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    insight.keyword,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${insight.count}일',
                    style: TextStyle(
                      color: colors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 6,
                  backgroundColor: colors.surfaceSoft,
                  valueColor: AlwaysStoppedAnimation(colors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          insight.averageSatisfaction.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: colors.primaryDark,
          ),
        ),
      ],
    );
  }
}

class _MoodDonutPainter extends CustomPainter {
  _MoodDonutPainter(this.counts, this.trackColor);

  final Map<DiaryMood, int> counts;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final total = counts.values.fold<int>(0, (sum, value) => sum + value);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final background = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..color = trackColor;
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
  _ScoreTrendPainter(this.entries, this.lineColor, this.gridColor);

  final List<DiaryEntry> entries;
  final Color lineColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = gridColor
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
      ..color = lineColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, line);
    final dot = Paint()..color = lineColor;
    for (final point in points) {
      canvas.drawCircle(point, 3.5, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _ScoreTrendPainter oldDelegate) {
    return oldDelegate.entries != entries;
  }
}
