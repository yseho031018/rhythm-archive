import 'package:flutter/material.dart';

import '../diary_controller.dart';
import '../diary_entry.dart';
import '../widgets/harutalk_ui.dart';

class MoodGrassScreen extends StatefulWidget {
  const MoodGrassScreen({
    super.key,
    required this.controller,
    required this.onRecord,
    required this.onOpenEntry,
  });

  final DiaryController controller;

  /// 빈 날짜에서 "이 날 기록하기"를 눌렀을 때 그 날짜로 기록을 시작한다.
  final ValueChanged<DateTime> onRecord;

  /// 기록이 있는 날짜에서 상세 한 줄을 연다.
  final ValueChanged<String> onOpenEntry;

  @override
  State<MoodGrassScreen> createState() => _MoodGrassScreenState();
}

class _MoodGrassScreenState extends State<MoodGrassScreen> {
  DateTime? _selectedDay;
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _month.year == now.year && _month.month == now.month;
  }

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
      _selectedDay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDay = _month;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leading = firstDay.weekday % 7;
    final cells = leading + daysInMonth;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final selectedEntry = _selectedDay == null
            ? null
            : widget.controller.entryForDay(_selectedDay!);
        final colors = context.colors;
        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
          children: [
            const AppPageHeader(
              title: '감정잔디',
              subtitle: '매일의 마음이 모여 이번 달의 색이 돼요.',
              trailing: SmallPill(label: '오늘'),
            ),
            const SizedBox(height: 24),
            SoftCard(
              padding: const EdgeInsets.fromLTRB(17, 18, 17, 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _shiftMonth(-1),
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                      Expanded(
                        child: Text(
                          '${_month.year}년 ${_month.month}월',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        // 미래 달은 데이터가 없으므로 현재 달까지만 이동.
                        onPressed: _isCurrentMonth
                            ? null
                            : () => _shiftMonth(1),
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      for (final day in ['일', '월', '화', '수', '목', '금', '토'])
                        Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: TextStyle(
                                color: colors.muted,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cells,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                    itemBuilder: (context, index) {
                      if (index < leading) return const SizedBox.shrink();
                      final day = index - leading + 1;
                      final date = DateTime(_month.year, _month.month, day);
                      final entry = widget.controller.entryForDay(date);
                      final selected =
                          _selectedDay != null &&
                          isSameDiaryDay(_selectedDay!, date);
                      final future = date.isAfter(
                        DateTime(now.year, now.month, now.day),
                      );
                      return InkWell(
                        onTap: future
                            ? null
                            : () => setState(() => _selectedDay = date),
                        borderRadius: BorderRadius.circular(11),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 170),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                entry?.mood.color.withValues(
                                  alpha: selected ? 1 : 0.78,
                                ) ??
                                colors.surfaceSoft,
                            borderRadius: BorderRadius.circular(11),
                            border: selected
                                ? Border.all(
                                    color: colors.primaryDark,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: entry != null
                                  ? Colors.white
                                  : future
                                  ? colors.muted.withValues(alpha: 0.45)
                                  : colors.muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            _MoodLegend(),
            const SizedBox(height: 24),
            Text('선택한 날', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 11),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _selectedDay == null
                  ? const _SelectedDayCard(
                      key: ValueKey('hint'),
                      icon: Icons.touch_app_outlined,
                      title: '날짜를 눌러보세요',
                      body: '그날의 감정과 토리가 정리한 한 줄을 볼 수 있어요.',
                    )
                  : selectedEntry == null
                  ? _EmptyDayCard(
                      key: ValueKey(('empty', _selectedDay)),
                      date: _selectedDay!,
                      onRecord: () => widget.onRecord(_selectedDay!),
                    )
                  : _SelectedDayCard(
                      key: ValueKey(selectedEntry.id),
                      emoji: selectedEntry.mood.emoji,
                      title: formatDiaryDate(
                        selectedEntry.date,
                        includeYear: false,
                      ),
                      body: selectedEntry.summary,
                      score: selectedEntry.satisfaction,
                      onOpen: () => widget.onOpenEntry(selectedEntry.id),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _MoodLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 11,
      runSpacing: 8,
      children: [
        for (final mood in DiaryMood.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: mood.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                mood.label,
                style: TextStyle(
                  color: context.colors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _EmptyDayCard extends StatelessWidget {
  const _EmptyDayCard({super.key, required this.date, required this.onRecord});

  final DateTime date;
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 49,
                height: 49,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.edit_calendar_rounded,
                  color: context.colors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${date.month}월 ${date.day}일은 비어 있어요',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '이 날의 감정을 짧게 남겨볼까요?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRecord,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('이 날 기록하기'),
          ),
        ],
      ),
    );
  }
}

class _SelectedDayCard extends StatelessWidget {
  const _SelectedDayCard({
    super.key,
    this.icon,
    this.emoji,
    required this.title,
    required this.body,
    this.score,
    this.onOpen,
  });

  final IconData? icon;
  final String? emoji;
  final String title;
  final String body;
  final int? score;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 49,
                height: 49,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: emoji != null
                    ? Text(emoji!, style: const TextStyle(fontSize: 25))
                    : Icon(icon, color: context.colors.primary, size: 24),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (score != null) SmallPill(label: '$score점'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(body, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          if (onOpen != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.menu_book_outlined, size: 18),
                label: const Text('기록 보기'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
