import 'package:flutter/material.dart';

import '../diary_controller.dart';
import '../diary_entry.dart';
import '../widgets/tori_chat_header.dart';
import '../widgets/tori_mascot.dart';
import 'summary_editor.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({
    super.key,
    required this.controller,
    required this.onOpenDiary,
  });

  final DiaryController controller;
  final VoidCallback onOpenDiary;

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  int _step = 0;
  String? _directKeyword;

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
          _BottomActionBar(
            onSkip: _skip,
            onNext: _canMoveNext ? _next : null,
            nextLabel: _step == 2 ? 'AI 한 줄 만들기' : '다음',
            showDirectInput: _step == 1,
            onDirectInput: _showDirectInput,
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
        ),
        const SizedBox(height: 30),
        Text(switch (_step) {
          0 => '오늘 기분은 어땠어?',
          1 => '무엇과 함께한 하루였어?',
          _ => '오늘 하루에 몇 점을 줄래?',
        }, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 17),
        if (_step == 0) _MoodChoices(controller: controller),
        if (_step == 1)
          _KeywordChoices(
            controller: controller,
            directKeyword: _directKeyword,
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

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _generate();
    }
  }

  void _skip() {
    if (_step == 0 && controller.selectedMood == null) {
      controller.selectMood(DiaryMood.normal);
    } else if (_step == 1 && controller.selectedKeywords.isEmpty) {
      controller.toggleKeyword('일상');
      _directKeyword = '일상';
    } else if (_step == 2) {
      controller.setSatisfaction(3);
    }
    _next();
  }

  void _reset() {
    setState(() {
      _step = 0;
      _directKeyword = null;
    });
  }

  Future<void> _showDirectInput() async {
    final textController = TextEditingController();
    final keyword = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오늘의 키워드'),
        content: TextField(
          controller: textController,
          autofocus: true,
          maxLength: 10,
          decoration: const InputDecoration(
            hintText: '예: 발표, 가족, 산책',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              final value = textController.text.trim();
              if (value.isNotEmpty) Navigator.pop(context, value);
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
    textController.dispose();
    if (keyword == null || !mounted) return;
    if (_directKeyword != null &&
        controller.selectedKeywords.contains(_directKeyword)) {
      controller.toggleKeyword(_directKeyword!);
    }
    controller.toggleKeyword(keyword);
    setState(() => _directKeyword = keyword);
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
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final mood in DiaryMood.values)
          _ChoiceTile(
            width: 96,
            emoji: mood.emoji,
            label: mood.label,
            selected: controller.selectedMood == mood,
            onTap: () => controller.selectMood(mood),
          ),
      ],
    );
  }
}

class _KeywordChoices extends StatelessWidget {
  const _KeywordChoices({
    required this.controller,
    required this.directKeyword,
  });

  final DiaryController controller;
  final String? directKeyword;

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

  static const _fallbackColor = Color(0xFF4B9875);

  @override
  Widget build(BuildContext context) {
    final options = [...DiaryController.keywordOptions];
    if (directKeyword != null) options.add(directKeyword!);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final keyword in options)
          _ChoiceTile(
            width: 96,
            icon: icons[keyword] ?? Icons.edit_rounded,
            accentColor: colors[keyword] ?? _fallbackColor,
            label: keyword,
            selected: controller.selectedKeywords.contains(keyword),
            onTap: () => controller.toggleKeyword(keyword),
          ),
      ],
    );
  }
}

class _ScoreChoices extends StatelessWidget {
  const _ScoreChoices({required this.controller});

  final DiaryController controller;

  @override
  Widget build(BuildContext context) {
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
                        ? const Color(0xFF4B9875)
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: controller.satisfaction == score
                          ? const Color(0xFF4B9875)
                          : const Color(0xFFE0E7E2),
                    ),
                  ),
                  child: Text(
                    '$score',
                    style: TextStyle(
                      color: controller.satisfaction == score
                          ? Colors.white
                          : const Color(0xFF434A45),
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
    required this.width,
    required this.label,
    required this.selected,
    required this.onTap,
    this.emoji,
    this.icon,
    this.accentColor,
  });

  final double width;
  final String? emoji;
  final IconData? icon;
  final Color? accentColor;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width,
        height: 100,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE1F1E7) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF4B9875) : const Color(0xFFE5E9E6),
            width: selected ? 1.6 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D52675A),
              blurRadius: 12,
              offset: Offset(0, 4),
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
                  color: accentColor!.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: 24, color: accentColor),
              )
            else
              Icon(
                icon,
                size: 29,
                color: selected
                    ? const Color(0xFF2E7559)
                    : const Color(0xFF6D7770),
              ),
            SizedBox(height: accentColor != null ? 8 : 7),
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF2E7559)
                    : const Color(0xFF555B57),
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
    required this.nextLabel,
    required this.showDirectInput,
    required this.onDirectInput,
  });

  final VoidCallback onSkip;
  final VoidCallback? onNext;
  final String nextLabel;
  final bool showDirectInput;
  final VoidCallback onDirectInput;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8F6),
        border: Border(top: BorderSide(color: Color(0xFFEAEDEB))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (showDirectInput) ...[
              OutlinedButton.icon(
                onPressed: onDirectInput,
                icon: const Icon(Icons.edit_outlined, size: 17),
                label: const Text('직접 입력'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            TextButton(onPressed: onSkip, child: const Text('건너뛰기')),
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
    return Scaffold(
      // 앱 셸과 동일하게 모바일 폭(560)으로 제약 — 와이드 화면 전체 폭 방지.
      backgroundColor: const Color(0xFFF0F4F1),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ColoredBox(
              color: const Color(0xFFF7FAF7),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 6, 12, 0),
                    child: Row(
                      children: [
                        const Spacer(),
                        TextButton(
                          onPressed: _working ? null : _save,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF2E7559),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          child: const Text('완료'),
                        ),
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
                                  color: const Color(0xFFF5F1E6),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  '기록 완료! 🎉\n정말 수고했어!',
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE3EBE5)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0D52675A),
                                blurRadius: 14,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Text(
                            '$_leadingEmoji  ${_entry.summary}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  height: 1.55,
                                  color: const Color(0xFF245D56),
                                ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _working ? null : _regenerate,
                            icon: _working
                                ? const SizedBox.square(
                                    dimension: 15,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF4B9875),
                                    ),
                                  )
                                : const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('AI가 다시 정리'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF4B9875),
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
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
                            color: const Color(0xFFEFF4F0),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const ToriMascot(
                                expression: ToriExpression.journal,
                                size: 48,
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  '내가 정리한 한 줄이 마음에 들지 않으면 수정해도 괜찮아!',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.4,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF5E6B62),
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
                                  foregroundColor: const Color(0xFF2E7559),
                                  minimumSize: const Size.fromHeight(54),
                                  side: const BorderSide(
                                    color: Color(0xFFCBD9CF),
                                  ),
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
                                    ? const SizedBox.square(
                                        dimension: 17,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
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
