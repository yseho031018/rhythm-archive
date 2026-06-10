import 'package:flutter/material.dart';

import '../diary_controller.dart';
import '../diary_entry.dart';
import '../widgets/harutalk_ui.dart';

class MoodGrassScreen extends StatefulWidget {
  const MoodGrassScreen({super.key, required this.controller});

  final DiaryController controller;

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
                        onPressed: _isCurrentMonth ? null : () => _shiftMonth(1),
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
                              style: const TextStyle(
                                color: HarutalkColors.muted,
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
                                  alpha: selected ? 1 : 0.72,
                                ) ??
                                const Color(0xFFF0F2EF),
                            borderRadius: BorderRadius.circular(11),
                            border: selected
                                ? Border.all(
                                    color: HarutalkColors.primaryDark,
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
                                  ? const Color(0xFFD0D4D0)
                                  : const Color(0xFFA5AAA6),
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
                  ? _SelectedDayCard(
                      key: ValueKey(_selectedDay),
                      icon: Icons.edit_note_rounded,
                      title:
                          '${_selectedDay!.month}월 ${_selectedDay!.day}일은 비어 있어요',
                      body: '짧게 기록하면 이곳에 오늘의 색이 채워져요.',
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
                style: const TextStyle(
                  color: HarutalkColors.muted,
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

class _SelectedDayCard extends StatelessWidget {
  const _SelectedDayCard({
    super.key,
    this.icon,
    this.emoji,
    required this.title,
    required this.body,
    this.score,
  });

  final IconData? icon;
  final String? emoji;
  final String title;
  final String body;
  final int? score;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 49,
            height: 49,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: HarutalkColors.primarySoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: emoji != null
                ? Text(emoji!, style: const TextStyle(fontSize: 25))
                : Icon(icon, color: HarutalkColors.primary, size: 24),
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
    );
  }
}
