import 'package:flutter/material.dart';

import '../diary_controller.dart';
import '../diary_entry.dart';
import '../widgets/harutalk_ui.dart';
import '../widgets/tori_mascot.dart';

enum MoodGrassRange {
  monthly('월간'),
  yearly('연간');

  const MoodGrassRange(this.label);

  final String label;
}

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
  late int _year;
  MoodGrassRange _range = MoodGrassRange.monthly;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _year = now.year;
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

  bool get _isCurrentYear => _year == DateTime.now().year;

  void _shiftYear(int delta) {
    setState(() {
      _year += delta;
      _selectedDay = null;
    });
  }

  void _selectRange(MoodGrassRange range) {
    setState(() {
      _range = range;
      _selectedDay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final selectedEntry = _selectedDay == null
            ? null
            : widget.controller.entryForDay(_selectedDay!);
        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
          children: [
            AppPageHeader(
              title: '감정잔디',
              subtitle: _range == MoodGrassRange.monthly
                  ? '매일의 마음이 모여 이번 달의 색이 돼요.'
                  : '한 해의 마음 흐름을 넓게 돌아봐요.',
              trailing: const SmallPill(label: '오늘'),
            ),
            const SizedBox(height: 20),
            _MoodGrassRangeTabs(selected: _range, onSelect: _selectRange),
            const SizedBox(height: 14),
            if (_range == MoodGrassRange.monthly)
              _MonthlyMoodGrass(
                controller: widget.controller,
                month: _month,
                selectedDay: _selectedDay,
                canGoNext: !_isCurrentMonth,
                onPrevious: () => _shiftMonth(-1),
                onNext: () => _shiftMonth(1),
                onSelectDay: (date) => setState(() => _selectedDay = date),
              )
            else
              _YearlyMoodGrass(
                controller: widget.controller,
                year: _year,
                selectedDay: _selectedDay,
                canGoNext: !_isCurrentYear,
                onPrevious: () => _shiftYear(-1),
                onNext: () => _shiftYear(1),
                onSelectDay: (date) => setState(() => _selectedDay = date),
              ),
            const SizedBox(height: 15),
            _MoodLegend(),
            const SizedBox(height: 24),
            if (widget.controller.entries.isEmpty && _selectedDay == null)
              ToriEmptyStateCard(
                title: '첫 번째 감정 색을 채워볼까요?',
                body: '오늘 한 줄을 남기면 감정잔디에\n나만의 첫 색이 생겨요.',
                actionLabel: '오늘 기록하기',
                onAction: () => widget.onRecord(DateTime.now()),
                expression: ToriExpression.hello,
              )
            else ...[
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
          ],
        );
      },
    );
  }
}

class _MoodGrassRangeTabs extends StatelessWidget {
  const _MoodGrassRangeTabs({required this.selected, required this.onSelect});

  final MoodGrassRange selected;
  final ValueChanged<MoodGrassRange> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (final range in MoodGrassRange.values)
            Expanded(
              child: InkWell(
                onTap: () => onSelect(range),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: range == selected
                        ? colors.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: range == selected
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
                    range.label,
                    style: TextStyle(
                      color: range == selected
                          ? colors.primaryDark
                          : colors.muted,
                      fontSize: 12,
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

class _MonthlyMoodGrass extends StatelessWidget {
  const _MonthlyMoodGrass({
    required this.controller,
    required this.month,
    required this.selectedDay,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    required this.onSelectDay,
  });

  final DiaryController controller;
  final DateTime month;
  final DateTime? selectedDay;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = month.weekday % 7;
    final cells = leading + daysInMonth;
    final colors = context.colors;

    return SoftCard(
      padding: const EdgeInsets.fromLTRB(17, 18, 17, 18),
      child: Column(
        children: [
          _GrassPeriodHeader(
            label: '${month.year}년 ${month.month}월',
            onPrevious: onPrevious,
            onNext: canGoNext ? onNext : null,
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              if (index < leading) return const SizedBox.shrink();
              final day = index - leading + 1;
              final date = DateTime(month.year, month.month, day);
              final entry = controller.entryForDay(date);
              final selected =
                  selectedDay != null && isSameDiaryDay(selectedDay!, date);
              final future = date.isAfter(
                DateTime(now.year, now.month, now.day),
              );
              return InkWell(
                key: ValueKey('month-day-${date.toIso8601String()}'),
                onTap: future ? null : () => onSelectDay(date),
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
                        ? Border.all(color: colors.primaryDark, width: 2)
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
    );
  }
}

class _YearlyMoodGrass extends StatefulWidget {
  const _YearlyMoodGrass({
    required this.controller,
    required this.year,
    required this.selectedDay,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    required this.onSelectDay,
  });

  final DiaryController controller;
  final int year;
  final DateTime? selectedDay;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelectDay;

  @override
  State<_YearlyMoodGrass> createState() => _YearlyMoodGrassState();
}

class _YearlyMoodGrassState extends State<_YearlyMoodGrass> {
  static const _cellSize = 17.0;
  static const _gap = 3.0;
  static const _step = _cellSize + _gap;

  final ScrollController _scrollController = ScrollController();
  bool _canScrollBack = false;
  bool _canScrollForward = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollButtons);
    WidgetsBinding.instance.addPostFrameCallback((_) => _positionYear());
  }

  @override
  void didUpdateWidget(covariant _YearlyMoodGrass oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.year != widget.year) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _positionYear());
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateScrollButtons)
      ..dispose();
    super.dispose();
  }

  void _updateScrollButtons() {
    if (!_scrollController.hasClients || !mounted) return;
    final position = _scrollController.position;
    final canBack = position.pixels > 1;
    final canForward = position.pixels < position.maxScrollExtent - 1;
    if (canBack == _canScrollBack && canForward == _canScrollForward) return;
    setState(() {
      _canScrollBack = canBack;
      _canScrollForward = canForward;
    });
  }

  void _scrollYear(int direction) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final target = (position.pixels + position.viewportDimension * direction)
        .clamp(0.0, position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _positionYear() {
    if (!_scrollController.hasClients) return;
    final now = DateTime.now();
    final position = _scrollController.position;
    if (widget.year != now.year) {
      _scrollController.jumpTo(0);
      _updateScrollButtons();
      return;
    }

    final first = DateTime(widget.year);
    final start = first.subtract(Duration(days: first.weekday % 7));
    final focusDay = DateTime(widget.year, now.month, 15);
    final focusWeek = focusDay.difference(start).inDays ~/ 7;
    final target = (focusWeek * _step - position.viewportDimension / 2).clamp(
      0.0,
      position.maxScrollExtent,
    );
    _scrollController.jumpTo(target);
    _updateScrollButtons();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final now = DateTime.now();
    final first = DateTime(widget.year);
    final last = DateTime(widget.year, 12, 31);
    final start = first.subtract(Duration(days: first.weekday % 7));
    final totalDays = last.difference(start).inDays + 1;
    final weekCount = (totalDays / 7).ceil();
    final heatmapWidth = weekCount * _step - _gap;
    final yearEntries = widget.controller.entries
        .where((entry) => entry.date.year == widget.year)
        .length;

    return SoftCard(
      padding: const EdgeInsets.fromLTRB(17, 18, 17, 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GrassPeriodHeader(
            label: '${widget.year}년',
            onPrevious: widget.onPrevious,
            onNext: widget.canGoNext ? widget.onNext : null,
          ),
          const SizedBox(height: 5),
          Text(
            '기록 $yearEntries일 · 가로로 밀어 한 해를 살펴보세요.',
            style: TextStyle(
              color: colors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Column(
                  children: [
                    for (var weekday = 0; weekday < 7; weekday++)
                      SizedBox(
                        width: 22,
                        height: _step,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            weekday.isOdd ? ['월', '수', '금'][weekday ~/ 2] : '',
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
              ),
              const SizedBox(width: 7),
              Expanded(
                child: SingleChildScrollView(
                  key: const ValueKey('year-heatmap-scroll'),
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: heatmapWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 21,
                          child: Stack(
                            children: [
                              for (var month = 1; month <= 12; month++)
                                Positioned(
                                  left:
                                      DateTime(
                                        widget.year,
                                        month,
                                      ).difference(start).inDays ~/
                                      7 *
                                      _step,
                                  child: Text(
                                    '$month월',
                                    style: TextStyle(
                                      color: colors.muted,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var week = 0; week < weekCount; week++) ...[
                              if (week > 0) const SizedBox(width: _gap),
                              Column(
                                children: [
                                  for (var weekday = 0; weekday < 7; weekday++)
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: weekday == 6 ? 0 : _gap,
                                      ),
                                      child: _YearGrassCell(
                                        size: _cellSize,
                                        date: start.add(
                                          Duration(days: week * 7 + weekday),
                                        ),
                                        year: widget.year,
                                        entry: widget.controller.entryForDay(
                                          start.add(
                                            Duration(days: week * 7 + weekday),
                                          ),
                                        ),
                                        selected:
                                            widget.selectedDay != null &&
                                            isSameDiaryDay(
                                              widget.selectedDay!,
                                              start.add(
                                                Duration(
                                                  days: week * 7 + weekday,
                                                ),
                                              ),
                                            ),
                                        future: start
                                            .add(
                                              Duration(
                                                days: week * 7 + weekday,
                                              ),
                                            )
                                            .isAfter(
                                              DateTime(
                                                now.year,
                                                now.month,
                                                now.day,
                                              ),
                                            ),
                                        onTap: widget.onSelectDay,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: colors.surfaceSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: '연초 방향으로 이동',
                  onPressed: _canScrollBack ? () => _scrollYear(-1) : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Text(
                    _canScrollForward ? '버튼으로 12월까지 이동할 수 있어요' : '12월까지 보고 있어요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: '연말 방향으로 이동',
                  onPressed: _canScrollForward ? () => _scrollYear(1) : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _YearGrassCell extends StatelessWidget {
  const _YearGrassCell({
    required this.size,
    required this.date,
    required this.year,
    required this.entry,
    required this.selected,
    required this.future,
    required this.onTap,
  });

  final double size;
  final DateTime date;
  final int year;
  final DiaryEntry? entry;
  final bool selected;
  final bool future;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final inYear = date.year == year;
    final enabled = inYear && !future;
    final label =
        '${date.year}년 ${date.month}월 ${date.day}일'
        '${entry == null ? '' : ' · ${entry!.mood.label}'}';

    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        button: enabled,
        child: InkWell(
          key: ValueKey('year-day-${date.toIso8601String()}'),
          onTap: enabled ? () => onTap(date) : null,
          borderRadius: BorderRadius.circular(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: !inYear
                  ? Colors.transparent
                  : entry?.mood.color.withValues(alpha: 0.82) ??
                        colors.surfaceSoft.withValues(alpha: future ? 0.35 : 1),
              borderRadius: BorderRadius.circular(4),
              border: selected
                  ? Border.all(color: colors.primaryDark, width: 2)
                  : inYear
                  ? Border.all(color: colors.border.withValues(alpha: 0.7))
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _GrassPeriodHeader extends StatelessWidget {
  const _GrassPeriodHeader({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          key: const ValueKey('grass-period-previous'),
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        IconButton(
          key: const ValueKey('grass-period-next'),
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
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
