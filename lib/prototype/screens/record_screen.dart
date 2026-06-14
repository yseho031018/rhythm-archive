import 'package:flutter/material.dart';

import '../diary_controller.dart';
import '../diary_entry.dart';
import '../widgets/harutalk_ui.dart';
import '../widgets/tori_chat_header.dart';
import '../widgets/tori_mascot.dart';
import 'summary_editor.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({
    super.key,
    required this.controller,
    required this.onOpenDiary,
    this.onOpenMoodGrass,
  });

  final DiaryController controller;
  final VoidCallback onOpenDiary;
  final VoidCallback? onOpenMoodGrass;

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  int _step = 0;

  DiaryController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: _buildStep(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
            child: _RecordMemoryCard(controller: controller, step: _step),
          ),
          _BottomActionBar(
            onSkip: _skip,
            onNext: _canMoveNext ? _next : null,
            skipLabel: _skipLabel,
            nextLabel: _nextLabel,
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    final messages = [
      '안녕! 나는 토리야.\n오늘은 어떤 기분으로 보냈어?',
      '그랬구나 ${controller.selectedMood?.emoji ?? ''}\n무엇과 함께한 하루였어?',
      '마지막 질문이야!\n오늘 하루에 몇 점을 주고 싶어?',
    ];
    final expressions = [
      ToriExpression.hello,
      ToriExpression.thinking,
      ToriExpression.writing,
    ];

    return ListView(
      key: ValueKey(_step),
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      children: [
        ToriChatHeader(
          message: messages[_step],
          step: _step,
          totalSteps: 3,
          expression: expressions[_step],
          onClose: _reset,
          onBack: _step > 0 ? _previous : null,
        ),
        const SizedBox(height: 16),
        _RecordDateChip(
          date: controller.recordDate,
          hasEntry: controller.entryForDay(controller.recordDate) != null,
          onTap: _pickDate,
        ),
        const SizedBox(height: 24),
        Text(switch (_step) {
          0 => '오늘 기분은 어땠어?',
          1 => '무엇과 함께한 하루였어?',
          _ => '오늘 하루에 몇 점을 줄래?',
        }, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 17),
        if (_step == 0) ...[
          _MoodChoices(controller: controller),
          const SizedBox(height: 28),
          _MoodGrassPreviewCard(
            controller: controller,
            onTap: widget.onOpenMoodGrass,
          ),
        ],
        if (_step == 1)
          _KeywordChoices(
            controller: controller,
            onDirectInput: _showDirectInput,
            onRemoveCustom: _confirmRemoveKeyword,
          ),
        if (_step == 2) _ScoreChoices(controller: controller),
      ],
    );
  }

  bool get _canMoveNext {
    return switch (_step) {
      0 => controller.selectedMood != null,
      1 => controller.selectedKeywords.isNotEmpty,
      _ => !controller.generating,
    };
  }

  String get _nextLabel {
    if (_step == 0 && controller.selectedMood == null) return '기분을 골라줘';
    if (_step == 1 && controller.selectedKeywords.isEmpty) return '키워드를 골라줘';
    return _step == 2 ? '토리 한 줄 만들기' : '다음';
  }

  String get _skipLabel => switch (_step) {
    0 => '보통으로 넘기기',
    1 => '일상으로 넘기기',
    _ => '3점으로 넘기기',
  };

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _generate();
    }
  }

  void _previous() {
    if (_step == 0) return;
    setState(() => _step--);
  }

  void _skip() {
    if (_step == 0 && controller.selectedMood == null) {
      controller.selectMood(DiaryMood.normal);
    } else if (_step == 1 && controller.selectedKeywords.isEmpty) {
      controller.toggleKeyword('일상');
    } else if (_step == 2) {
      controller.setSatisfaction(3);
    }
    _next();
  }

  void _reset() {
    controller.startRecord(date: controller.recordDate);
    setState(() {
      _step = 0;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (context) => _HarutalkDatePickerDialog(
        initialDate: controller.recordDate,
        firstDate: DateTime(now.year - 1, 1, 1),
        lastDate: DateTime(now.year, now.month, now.day),
        controller: controller,
      ),
    );
    if (picked != null) controller.setRecordDate(picked);
  }

  Future<void> _showDirectInput() async {
    final keyword = await showDialog<String>(
      context: context,
      builder: (context) => const _KeywordInputDialog(),
    );
    if (keyword == null || !mounted) return;
    // 추가한 키워드는 저장되어 다음에도 그리드에 다시 나타난다.
    final saved = await controller.addCustomKeyword(keyword);
    if (!saved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.storageError ?? '키워드를 저장하지 못했어요.')),
      );
    }
  }

  Future<void> _confirmRemoveKeyword(String keyword) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const HarutalkDialogIcon(
          icon: Icons.label_off_outlined,
          destructive: true,
        ),
        title: const Text('키워드 삭제'),
        content: Text(
          "'$keyword' 키워드를 목록에서 지울까요?",
          textAlign: TextAlign.center,
        ),
        actions: [
          HarutalkDialogActions(
            cancelLabel: '취소',
            confirmLabel: '삭제',
            onCancel: () => Navigator.pop(context, false),
            onConfirm: () => Navigator.pop(context, true),
            destructive: true,
          ),
        ],
      ),
    );
    if (remove == true) await controller.removeCustomKeyword(keyword);
  }

  Future<void> _generate() async {
    final entry = await controller.generatePreview();
    if (entry == null || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => _GeneratedDiaryScreen(
          entry: entry,
          controller: controller,
          onSaved: () {
            Navigator.pop(context);
            _reset();
            widget.onOpenDiary();
          },
        ),
      ),
    );
  }
}

class _MoodChoices extends StatelessWidget {
  const _MoodChoices({required this.controller});

  final DiaryController controller;

  @override
  Widget build(BuildContext context) {
    // 5가지 감정을 항상 한 줄에 균등 배치(고정폭 Wrap 대신 유연폭 Row).
    return Row(
      children: [
        for (final mood in DiaryMood.values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _ChoiceTile(
                emoji: mood.emoji,
                label: mood.label,
                selected: controller.selectedMood == mood,
                onTap: () => controller.selectMood(mood),
              ),
            ),
          ),
      ],
    );
  }
}

class _MoodGrassPreviewCard extends StatelessWidget {
  const _MoodGrassPreviewCard({required this.controller, this.onTap});

  final DiaryController controller;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: 13));
    final days = List.generate(14, (index) => start.add(Duration(days: index)));
    final recordedCount = days
        .where((date) => controller.entryForDay(date) != null)
        .length;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '최근 마음',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (onTap != null)
              TextButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.grid_view_rounded, size: 17),
                label: const Text('감정잔디 보기'),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SoftCard(
          onTap: onTap,
          color: colors.cream,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: days.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.35,
                ),
                itemBuilder: (context, index) {
                  final date = days[index];
                  final entry = controller.entryForDay(date);
                  final isToday = isSameDiaryDay(date, today);
                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          entry?.mood.color.withValues(alpha: 0.82) ??
                          colors.surface,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: isToday ? colors.primaryDark : colors.border,
                        width: isToday ? 1.6 : 1,
                      ),
                    ),
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: entry == null ? colors.muted : Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.spa_rounded, size: 17, color: colors.primary),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      recordedCount == 0
                          ? '첫 한 줄을 남기면 여기에 오늘의 색이 생겨요.'
                          : '최근 2주 동안 마음의 색 $recordedCount개가 쌓였어요.',
                      style: TextStyle(
                        color: colors.muted,
                        fontSize: 11.5,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colors.primaryDark,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HarutalkDatePickerDialog extends StatefulWidget {
  const _HarutalkDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.controller,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DiaryController controller;

  @override
  State<_HarutalkDatePickerDialog> createState() =>
      _HarutalkDatePickerDialogState();
}

class _HarutalkDatePickerDialogState extends State<_HarutalkDatePickerDialog> {
  late DateTime _selectedDate;
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
    _month = DateTime(_selectedDate.year, _selectedDate.month);
  }

  bool get _canGoPrevious {
    final previous = DateTime(_month.year, _month.month - 1);
    return !previous.isBefore(
      DateTime(widget.firstDate.year, widget.firstDate.month),
    );
  }

  bool get _canGoNext {
    final next = DateTime(_month.year, _month.month + 1);
    return !next.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month));
  }

  void _shiftMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  bool _isEnabled(DateTime date) {
    return !date.isBefore(widget.firstDate) && !date.isAfter(widget.lastDate);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final firstDay = DateTime(_month.year, _month.month);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leading = firstDay.weekday % 7;
    final dates = List.generate(
      daysInMonth,
      (index) => DateTime(_month.year, _month.month, index + 1),
    );

    return Dialog(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: Theme.of(context).dialogTheme.shape,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.sizeOf(context).height - 48,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HarutalkDialogIcon(icon: Icons.calendar_month_rounded),
              const SizedBox(height: 14),
              Text(
                '기록할 날짜를 골라주세요',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.surfaceSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: '이전 달',
                      onPressed: _canGoPrevious ? () => _shiftMonth(-1) : null,
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Expanded(
                      child: Text(
                        '${_month.year}년 ${_month.month}월',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: '다음 달',
                      onPressed: _canGoNext ? () => _shiftMonth(1) : null,
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
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
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 5.0;
                  final tileSize = (constraints.maxWidth - gap * 6) / 7;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (var index = 0; index < leading; index++)
                        SizedBox.square(dimension: tileSize),
                      for (final date in dates)
                        _HarutalkCalendarDay(
                          size: tileSize,
                          date: date,
                          enabled: _isEnabled(date),
                          selected: isSameDiaryDay(_selectedDate, date),
                          mood: widget.controller.entryForDay(date)?.mood,
                          onTap: (date) => setState(() => _selectedDate = date),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              HarutalkDialogActions(
                cancelLabel: '취소',
                confirmLabel: '이 날짜 선택',
                onCancel: () => Navigator.pop(context),
                onConfirm: () => Navigator.pop(context, _selectedDate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HarutalkCalendarDay extends StatelessWidget {
  const _HarutalkCalendarDay({
    required this.size,
    required this.date,
    required this.enabled,
    required this.selected,
    required this.mood,
    required this.onTap,
  });

  final double size;
  final DateTime date;
  final bool enabled;
  final bool selected;
  final DiaryMood? mood;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox.square(
      dimension: size,
      child: InkWell(
        onTap: enabled ? () => onTap(date) : null,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? colors.primary : Colors.transparent,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '${date.day}',
                style: TextStyle(
                  color: selected
                      ? colors.onPrimary
                      : enabled
                      ? colors.ink
                      : colors.muted.withValues(alpha: 0.35),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (mood != null && !selected)
                Positioned(
                  bottom: 4,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: mood!.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordMemoryCard extends StatelessWidget {
  const _RecordMemoryCard({required this.controller, required this.step});

  final DiaryController controller;
  final int step;

  String get _message {
    final mood = controller.selectedMood;
    final keywords = controller.selectedKeywords;

    if (step == 0) {
      if (mood == null) {
        return '정답은 없어. 지금 마음과 가장 가까운 기분 하나면 충분해.';
      }
      return '${mood.emoji} ${mood.label}한 하루였구나. 다음 이야기도 들려줘!';
    }

    if (step == 1) {
      if (keywords.isEmpty) {
        return '여러 개 골라도 괜찮아. 오늘을 잘 설명하는 것만 남겨줘.';
      }
      return '${mood?.emoji ?? '🌿'} ${keywords.join(' · ')}와 함께한 하루로 기억하고 있어.';
    }

    return '${mood?.emoji ?? '🌿'} ${keywords.isEmpty ? '오늘의 하루' : keywords.join(' · ')} · ${controller.satisfaction}점\n이제 토리가 한 줄로 정리해볼게.';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasAnswer = switch (step) {
      0 => controller.selectedMood != null,
      1 => controller.selectedKeywords.isNotEmpty,
      _ => true,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 16, 13),
      decoration: BoxDecoration(
        color: hasAnswer ? colors.primarySoft : colors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasAnswer
              ? colors.primary.withValues(alpha: 0.45)
              : colors.border,
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: hasAnswer
                  ? colors.primary.withValues(alpha: 0.14)
                  : colors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasAnswer ? Icons.spa_rounded : Icons.chat_bubble_outline_rounded,
              size: 21,
              color: hasAnswer ? colors.primaryDark : colors.muted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasAnswer ? '토리가 기억한 오늘' : '토리의 한마디',
                  style: TextStyle(
                    color: hasAnswer ? colors.primaryDark : colors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    _message,
                    key: ValueKey(_message),
                    style: TextStyle(
                      color: colors.muted,
                      fontSize: 12.5,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeywordChoices extends StatelessWidget {
  const _KeywordChoices({
    required this.controller,
    required this.onDirectInput,
    required this.onRemoveCustom,
  });

  final DiaryController controller;
  final VoidCallback onDirectInput;
  final ValueChanged<String> onRemoveCustom;

  static const icons = {
    '공부': Icons.menu_book_rounded,
    '친구': Icons.people_alt_rounded,
    '게임': Icons.sports_esports_rounded,
    '카페': Icons.local_cafe_rounded,
    '과제': Icons.assignment_rounded,
    '운동': Icons.fitness_center_rounded,
  };

  // 활동별 고유 색(목업의 컬러 일러스트 아이콘 톤에 맞춤).
  static const colors = {
    '공부': Color(0xFF4F83CC), // 블루
    '친구': Color(0xFFF2994A), // 오렌지
    '게임': Color(0xFF9B6BD6), // 퍼플
    '카페': Color(0xFFB07C53), // 브라운
    '과제': Color(0xFF45A36B), // 그린
    '운동': Color(0xFF3FAE9A), // 틸
  };

  static const _fallbackColor = Color(0xFF6E9E84);

  @override
  Widget build(BuildContext context) {
    // 기본 키워드 + 저장된 사용자 키워드 + 이번 기록에서만 선택된 키워드(예: 건너뛰기의 '일상').
    final seen = <String>{};
    final options = <String>[];
    for (final keyword in [
      ...controller.allKeywords,
      ...controller.selectedKeywords,
    ]) {
      if (seen.add(keyword)) options.add(keyword);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 420;
        final spacing = compact ? 8.0 : 10.0;
        const columns = 4;
        final gridWidth = constraints.maxWidth.clamp(0.0, 516.0);
        final items = [
          for (final keyword in options)
            (
              keyword: keyword,
              icon: icons[keyword] ?? Icons.label_rounded,
              color: colors[keyword] ?? _fallbackColor,
              selected: controller.selectedKeywords.contains(keyword),
              onTap: () => controller.toggleKeyword(keyword),
              onLongPress: controller.customKeywords.contains(keyword)
                  ? () => onRemoveCustom(keyword)
                  : null,
            ),
          (
            keyword: '직접 입력',
            icon: Icons.add_rounded,
            color: context.colors.muted,
            selected: false,
            onTap: onDirectInput,
            onLongPress: null,
          ),
        ];
        final lastRowCount = items.length % columns;
        final fullTileWidth = (gridWidth - spacing * (columns - 1)) / columns;
        final lastRowTileWidth = lastRowCount == 0
            ? fullTileWidth
            : (gridWidth - spacing * (lastRowCount - 1)) / lastRowCount;
        final lastRowStart = items.length - lastRowCount;

        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: gridWidth,
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (var index = 0; index < items.length; index++)
                  _ChoiceTile(
                    width: lastRowCount != 0 && index >= lastRowStart
                        ? lastRowTileWidth
                        : fullTileWidth,
                    height: compact ? 88 : 100,
                    icon: items[index].icon,
                    accentColor: items[index].color,
                    label: items[index].keyword,
                    selected: items[index].selected,
                    onTap: items[index].onTap,
                    onLongPress: items[index].onLongPress,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScoreChoices extends StatelessWidget {
  const _ScoreChoices({required this.controller});

  final DiaryController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        for (var score = 1; score <= 5; score++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: score == 5 ? 0 : 8),
              child: InkWell(
                onTap: () => controller.setSatisfaction(score),
                borderRadius: BorderRadius.circular(30),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: controller.satisfaction == score
                        ? colors.primary
                        : colors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: controller.satisfaction == score
                          ? colors.primary
                          : colors.border,
                    ),
                  ),
                  child: Text(
                    '$score',
                    style: TextStyle(
                      color: controller.satisfaction == score
                          ? colors.onPrimary
                          : colors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.width,
    this.height = 100,
    this.emoji,
    this.icon,
    this.accentColor,
    this.onLongPress,
  });

  /// null이면 부모(예: Expanded) 폭을 채운다.
  final double? width;
  final double height;
  final String? emoji;
  final IconData? icon;
  final Color? accentColor;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: selected ? colors.primarySoft : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? colors.primary : colors.border,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (emoji != null)
              Text(emoji!, style: const TextStyle(fontSize: 29))
            else if (accentColor != null)
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accentColor!.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: 24, color: accentColor),
              )
            else
              Icon(
                icon,
                size: 29,
                color: selected ? colors.primaryDark : colors.muted,
              ),
            SizedBox(height: accentColor != null ? 8 : 7),
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? colors.primaryDark : colors.ink,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.onSkip,
    required this.onNext,
    required this.skipLabel,
    required this.nextLabel,
  });

  final VoidCallback onSkip;
  final VoidCallback? onNext;
  final String skipLabel;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                textStyle: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(skipLabel),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(onPressed: onNext, child: Text(nextLabel)),
            ),
          ],
        ),
      ),
    );
  }
}

/// 키워드 입력 다이얼로그. TextEditingController를 자기 State에서 소유·해제해
/// 다이얼로그 종료 애니메이션 중 컨트롤러가 조기 dispose되는 문제를 피한다.
class _KeywordInputDialog extends StatefulWidget {
  const _KeywordInputDialog();

  @override
  State<_KeywordInputDialog> createState() => _KeywordInputDialogState();
}

class _KeywordInputDialogState extends State<_KeywordInputDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isNotEmpty) Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const HarutalkDialogIcon(icon: Icons.add_comment_outlined),
      title: const Text('오늘의 키워드'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 10,
        decoration: const InputDecoration(
          hintText: '예: 발표, 가족, 산책',
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        HarutalkDialogActions(
          cancelLabel: '취소',
          confirmLabel: '추가',
          onCancel: () => Navigator.pop(context),
          onConfirm: _submit,
        ),
      ],
    );
  }
}

class _RecordDateChip extends StatelessWidget {
  const _RecordDateChip({
    required this.date,
    required this.hasEntry,
    required this.onTap,
  });

  final DateTime date;
  final bool hasEntry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isToday = isSameDiaryDay(date, DateTime.now());
    final label = isToday
        ? '오늘 · ${date.month}월 ${date.day}일'
        : formatDiaryDate(date, includeYear: false);
    // 과거 날짜를 고른 상태는 세이지 톤으로 강조해 "오늘이 아님"을 분명히 한다.
    final accent = isToday ? colors.muted : colors.primaryDark;
    final background = isToday ? colors.surfaceSoft : colors.primarySoft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_rounded, size: 16, color: accent),
                  const SizedBox(width: 7),
                  Text(
                    label,
                    style: TextStyle(
                      color: accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(Icons.expand_more_rounded, size: 16, color: accent),
                ],
              ),
            ),
          ),
        ),
        if (hasEntry)
          Padding(
            padding: const EdgeInsets.only(top: 7, left: 4),
            child: Text(
              '이미 기록이 있는 날이에요. 저장하면 새 한 줄로 덮어써요.',
              style: TextStyle(
                color: colors.accent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _GeneratedDiaryScreen extends StatefulWidget {
  const _GeneratedDiaryScreen({
    required this.entry,
    required this.controller,
    required this.onSaved,
  });

  final DiaryEntry entry;
  final DiaryController controller;
  final VoidCallback onSaved;

  @override
  State<_GeneratedDiaryScreen> createState() => _GeneratedDiaryScreenState();
}

class _GeneratedDiaryScreenState extends State<_GeneratedDiaryScreen> {
  late DiaryEntry _entry;
  bool _working = false;

  // 키워드를 대표하는 한 줄 앞 이모지(목업의 📚 자리).
  static const _keywordEmoji = {
    '공부': '📚',
    '친구': '👫',
    '게임': '🎮',
    '카페': '☕',
    '과제': '📝',
    '운동': '🏃',
    '일상': '🌿',
  };

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  String get _leadingEmoji {
    for (final keyword in _entry.keywords) {
      final emoji = _keywordEmoji[keyword];
      if (emoji != null) return emoji;
    }
    return _entry.mood.emoji;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      // 앱 셸과 동일하게 모바일 폭(560)으로 제약 — 와이드 화면 전체 폭 방지.
      backgroundColor: colors.surfaceSoft,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ColoredBox(
              color: colors.background,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _working
                              ? null
                              : () => Navigator.pop(context),
                          tooltip: '결과 닫기',
                          icon: const Icon(Icons.close_rounded),
                        ),
                        Expanded(
                          child: Text(
                            '토리가 만든 한 줄',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ToriMascot(
                              expression: ToriExpression.complete,
                              size: 104,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: colors.cream,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  '한 줄을 만들었어! 🎉\n마음에 드는지 확인해줘.',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Text(
                          '오늘의 한 줄',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colors.border),
                            boxShadow: [
                              BoxShadow(
                                color: colors.shadow,
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Text(
                            '$_leadingEmoji  ${_entry.summary}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  height: 1.55,
                                  color: colors.primaryDark,
                                ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _working ? null : _regenerate,
                            icon: _working
                                ? SizedBox.square(
                                    dimension: 15,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.primary,
                                    ),
                                  )
                                : const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('토리가 다시 정리'),
                            style: TextButton.styleFrom(
                              foregroundColor: colors.primary,
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _GeneratedInputSummary(entry: _entry),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
                          decoration: BoxDecoration(
                            color: colors.surfaceSoft,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const ToriMascot(
                                expression: ToriExpression.journal,
                                size: 48,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '내가 정리한 한 줄이 마음에 들지 않으면 수정해도 괜찮아!',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.4,
                                    fontWeight: FontWeight.w600,
                                    color: colors.muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: OutlinedButton.icon(
                                onPressed: _working ? null : _edit,
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text('수정하기'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colors.primaryDark,
                                  minimumSize: const Size.fromHeight(54),
                                  side: BorderSide(color: colors.border),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 6,
                              child: FilledButton.icon(
                                onPressed: _working ? null : _save,
                                icon: _working
                                    ? SizedBox.square(
                                        dimension: 17,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colors.onPrimary,
                                        ),
                                      )
                                    : const Icon(Icons.check_rounded),
                                label: const Text('저장하기'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _regenerate() async {
    setState(() => _working = true);
    final entry = await widget.controller.regeneratePreview(_entry);
    if (!mounted) return;
    setState(() {
      _entry = entry;
      _working = false;
    });
  }

  Future<void> _edit() async {
    final summary = await showSummaryEditor(
      context,
      initialValue: _entry.summary,
    );
    if (summary == null || !mounted) return;
    setState(() => _entry = _entry.copyWith(summary: summary));
  }

  Future<void> _save() async {
    setState(() => _working = true);
    final saved = await widget.controller.saveEntry(_entry);
    if (!mounted) return;
    if (!saved) {
      setState(() => _working = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.controller.storageError ?? '저장하지 못했어요.')),
      );
      return;
    }
    widget.onSaved();
  }
}

class _GeneratedInputSummary extends StatelessWidget {
  const _GeneratedInputSummary({required this.entry});

  final DiaryEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cream,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.checklist_rounded, size: 18, color: colors.primary),
              const SizedBox(width: 7),
              Text('토리가 들은 오늘', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              SmallPill(label: '${entry.mood.emoji} ${entry.mood.label}'),
              for (final keyword in entry.keywords)
                SmallPill(
                  label: keyword,
                  color: colors.surface,
                  foreground: colors.ink,
                ),
              SmallPill(
                label: '${entry.satisfaction}점',
                icon: Icons.star_rounded,
                color: colors.accentSoft,
                foreground: colors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
