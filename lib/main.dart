import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/app_styles.dart';
import 'models/rhythm_entry.dart';
import 'ui/header.dart';
import 'ui/home_tab.dart';
import 'ui/history_tab.dart';
import 'ui/nav_bar.dart';
import 'ui/pattern_tab.dart';

void main() {
  runApp(const RhythmApp());
}

class RhythmApp extends StatelessWidget {
  const RhythmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rhythm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Segoe UI',
        fontFamilyFallback: const [
          'Roboto',
          'Noto Sans CJK KR',
          'Apple SD Gothic Neo',
        ],
        colorScheme: const ColorScheme.dark(
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          primary: AppColors.accent,
          onPrimary: AppColors.background,
          secondary: AppColors.accentBronze,
          outline: AppColors.border,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -0.3,
            color: AppColors.textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            height: 1.3,
            color: AppColors.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: AppColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.45,
            color: AppColors.textSecondary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.4,
            color: AppColors.textMuted,
          ),
          labelLarge: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      home: const RhythmHomePage(),
    );
  }
}

class RhythmHomePage extends StatefulWidget {
  const RhythmHomePage({super.key});

  @override
  State<RhythmHomePage> createState() => _RhythmHomePageState();
}

class _RhythmHomePageState extends State<RhythmHomePage>
    with SingleTickerProviderStateMixin {
  static const _storageKey = 'rhythm_entries_v1';
  static const _emotionOptions = [
    '피곤',
    '성취감',
    '불안',
    '평온',
    '기쁨',
    '무기력',
    '집중',
    '설렘',
  ];
  static const _activityOptions = [
    '업무',
    '운동',
    '독서',
    '공부',
    '산책',
    '휴식',
    '친구',
    '여행',
  ];

  late final Ticker _ticker;
  final ValueNotifier<double> _waveTime = ValueNotifier<double>(0);
  final TextEditingController _noteController = TextEditingController();

  int _tabIndex = 0;
  int _energy = 3;
  final Set<String> _selectedEmotions = {};
  final Set<String> _selectedActivities = {'공부'};
  List<RhythmEntry> _entries = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      _waveTime.value = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    })..start();
    _loadEntries();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _waveTime.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey);
    if (raw == null || raw.isEmpty) {
      _entries = _sampleEntries();
      // 샘플 데이터는 메모리에만 유지, 저장소 오염 방지
    } else {
      _entries =
          raw.map((item) => RhythmEntry.fromJson(jsonDecode(item))).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    setState(() => _loaded = true);
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    // 샘플 데이터는 저장하지 않음
    final realEntries = _entries.where((e) => !e.isSample).toList();
    await prefs.setStringList(
      _storageKey,
      realEntries.map((entry) => jsonEncode(entry.toJson())).toList(),
    );
  }

  Future<void> _addTodayEntry() async {
    if (_selectedEmotions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('감정 키워드를 하나 이상 선택해주세요.'),
          backgroundColor: AppColors.primaryLight,
        ),
      );
      return;
    }

    // ID 생성 개선: 시간 + 랜덤 접미사로 중복 방지
    final id =
        '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}';

    final entry = RhythmEntry(
      id: id,
      createdAt: DateTime.now(),
      energy: _energy,
      emotions: _selectedEmotions.toList(),
      activities: _selectedActivities.toList(),
      note: _noteController.text.trim(),
    );
    setState(() {
      _entries = [entry, ..._entries];
      _noteController.clear();
    });
    await _saveEntries();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('오늘의 리듬을 성공적으로 기록했습니다.'),
        backgroundColor: AppColors.primaryLight,
      ),
    );
  }

  Future<void> _resetDemoData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          '데이터 초기화',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          '모든 기록이 삭제되고 데모 데이터로 초기화됩니다. 계속하시겠습니까?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              '취소',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              '초기화',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _entries = _sampleEntries();
      _energy = 3;
      _selectedEmotions.clear();
      _selectedActivities
        ..clear()
        ..add('공부');
      _noteController.clear();
    });
    await _saveEntries();
  }

  List<RhythmEntry> _sampleEntries() {
    final now = DateTime.now();
    return [
      RhythmEntry(
        id: 'sample-1',
        createdAt: now.subtract(const Duration(days: 1)),
        energy: 4,
        emotions: const ['성취감', '집중'],
        activities: const ['공부', '운동'],
        note: '발표 준비를 많이 진행했다. 나만의 예술적 리듬을 시각적으로 보는 경험이 매우 매력적이다.',
        isSample: true,
      ),
      RhythmEntry(
        id: 'sample-2',
        createdAt: now.subtract(const Duration(days: 2)),
        energy: 2,
        emotions: const ['피곤', '불안'],
        activities: const ['업무', '휴식'],
        note: '일정이 겹쳐서 에너지가 다소 낮았다. 충분한 수면이 필요한 날이다.',
        isSample: true,
      ),
      RhythmEntry(
        id: 'sample-3',
        createdAt: now.subtract(const Duration(days: 3)),
        energy: 5,
        emotions: const ['기쁨', '설렘'],
        activities: const ['친구', '산책'],
        note: '밖에서 걸으며 가볍게 이야기하니 에너지가 솟았다. 초록빛 파장이 너무 신선하게 드러난다.',
        isSample: true,
      ),
      RhythmEntry(
        id: 'sample-4',
        createdAt: now.subtract(const Duration(days: 4)),
        energy: 3,
        emotions: const ['평온'],
        activities: const ['독서', '휴식'],
        note: '조용하고 안락하게 흘러간 날. 복잡한 생각 정리도 조금 했다.',
        isSample: true,
      ),
    ];
  }

  RhythmEntry? get _previewEntry {
    if (_selectedEmotions.isEmpty) return null;
    return RhythmEntry(
      id: 'preview',
      createdAt: DateTime.now(),
      energy: _energy,
      emotions: _selectedEmotions.toList(),
      activities: _selectedActivities.toList(),
      note: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeTab(
        energy: _energy,
        selectedEmotions: _selectedEmotions,
        selectedActivities: _selectedActivities,
        emotionOptions: _emotionOptions,
        activityOptions: _activityOptions,
        noteController: _noteController,
        animation: _waveTime,
        previewEntry: _previewEntry,
        onEnergyChanged: (value) => setState(() => _energy = value.round()),
        onEmotionToggle: _toggleEmotion,
        onActivityToggle: _toggleActivity,
        onSave: _addTodayEntry,
      ),
      HistoryTab(entries: _entries),
      PatternTab(entries: _entries),
    ];

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF071111),
              AppColors.background,
              Color(0xFF040606),
            ],
            stops: [0, 0.46, 1],
          ),
        ),
        child: SafeArea(
          child: !_loaded
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        children: [
                          RhythmHeader(onReset: _resetDemoData),
                          const SizedBox(height: 14),
                          Expanded(child: pages[_tabIndex]),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
      bottomNavigationBar: RhythmNavBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
      ),
    );
  }

  void _toggleEmotion(String emotion) {
    setState(() {
      if (_selectedEmotions.contains(emotion)) {
        _selectedEmotions.remove(emotion);
      } else if (_selectedEmotions.length < 3) {
        _selectedEmotions.add(emotion);
      }
    });
  }

  void _toggleActivity(String activity) {
    setState(() {
      if (_selectedActivities.contains(activity)) {
        _selectedActivities.remove(activity);
      } else if (_selectedActivities.length < 3) {
        _selectedActivities.add(activity);
      }
    });
  }
}
