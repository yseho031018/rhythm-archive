import 'dart:convert';
import 'dart:math';
import 'dart:ui'; // Premium filters and BackdropFilter

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// Premium Obsidian Dark Luxury Design System for Rhythm
// ============================================================

class AppColors {
  // Deep obsidian luxury dark backgrounds
  static const background = Color(0xFF070B0C);
  static const surface = Color(0xFF0F1618);
  static const surfaceAlt = Color(0xFF172023);

  // Elegant metallic borders (satin slate / platinum and soft gold)
  static const border = Color(0xFF1F2D30);
  static const borderStrong = Color(0xFF2E4145);
  static const borderGold = Color(0x3DC5A880);

  // Sophisticated deep forest brand teal-green
  static const primary = Color(0xFF143031);
  static const primaryDark = Color(0xFF0B1B1C);
  static const primaryLight = Color(0xFF224E50);

  // Radiant premium gold and warm champagne accents
  static const accent = Color(0xFFD4AF37); // Warm polished gold
  static const accentLight = Color(0xFFEAC98C); // Champagne sparkle
  static const accentBronze = Color(0xFFC5A880); // Satin warm bronze

  // Elegant silk off-white & silver text hierarchy
  static const textPrimary = Color(0xFFE6ECEF);
  static const textSecondary = Color(0xFF9CA9AD);
  static const textMuted = Color(0xFF67777A);
  static const textGold = Color(0xFFC5A880);

  // Translucent overlays
  static const overlay = Color(0x13FFFFFF);
  static const glassBackground = Color(0x1F0B1112);
}

class AppRadii {
  static const card = 20.0;
  static const chip = 16.0;
  static const button = 16.0;
  static const energyDot = 32.0;
}

class AppShadows {
  static const card = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 36,
      offset: Offset(0, 16),
      spreadRadius: -4,
    ),
  ];

  static const subtle = [
    BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, 6)),
  ];
}

Color emotionColor(List<String> emotions) {
  if (emotions.contains('불안')) {
    return const Color(0xFF9E86E5); // Bright amethyst violet glow
  }
  if (emotions.contains('피곤')) {
    return const Color(0xFF758591); // Sleek charcoal-steel grey
  }
  if (emotions.contains('성취감')) {
    return const Color(0xFFF9C851); // Radiant amber/yellow-gold
  }
  if (emotions.contains('기쁨') || emotions.contains('설렘')) {
    return const Color(0xFFFF8B9C); // Lighter hot rose-coral glow
  }
  if (emotions.contains('집중')) {
    return const Color(0xFF1BE0B5); // Electric aqua/emerald teal
  }
  return const Color(0xFF6EC99E); // Calm sage/mint green glow
}

enum EmotionType { calm, anxious, achievement, focused, tired, joyful }

EmotionType resolveEmotionType(String keyword) {
  switch (keyword) {
    case '불안':
      return EmotionType.anxious;
    case '성취감':
      return EmotionType.achievement;
    case '집중':
      return EmotionType.focused;
    case '피곤':
    case '무기력':
      return EmotionType.tired;
    case '기쁨':
    case '설렘':
      return EmotionType.joyful;
    case '평온':
    default:
      return EmotionType.calm;
  }
}

class WaveConfig {
  const WaveConfig({
    required this.type,
    required this.label,
    required this.amplitude,
    required this.frequency,
    required this.smoothness,
    required this.chaos,
    required this.speed,
    required this.colors,
    required this.blendMode,
    this.rise = 0,
  });

  final EmotionType type;
  final String label;
  final double amplitude;
  final double frequency;
  final double smoothness;
  final double chaos;
  final double speed;
  final List<Color> colors;
  final BlendMode blendMode;
  final double rise;

  WaveConfig scaledByEnergy(int energy, int index) {
    final energyFactor = (energy - 3) / 2;
    return WaveConfig(
      type: type,
      label: label,
      amplitude: amplitude + energyFactor * 8 + index * 4,
      frequency: frequency + index * 0.18,
      smoothness: smoothness,
      chaos: chaos + max(0, energyFactor) * 0.08,
      speed: speed + energy * 0.04 + index * 0.08,
      colors: colors,
      blendMode: blendMode,
      rise: rise,
    );
  }
}

class WaveBehavior {
  const WaveBehavior._();

  static WaveConfig configFor(String keyword) {
    switch (resolveEmotionType(keyword)) {
      case EmotionType.anxious:
        return const WaveConfig(
          type: EmotionType.anxious,
          label: '불규칙',
          amplitude: 43,
          frequency: 2.8,
          smoothness: 0.18,
          chaos: 0.72,
          speed: 1.6,
          colors: [Color(0xFFB58CFF), Color(0xFFFF7AC8), Color(0xFF7A5CFF)],
          blendMode: BlendMode.screen,
        );
      case EmotionType.achievement:
        return const WaveConfig(
          type: EmotionType.achievement,
          label: '상승',
          amplitude: 52,
          frequency: 1.28,
          smoothness: 0.95,
          chaos: 0.04,
          speed: 1.22,
          colors: [Color(0xFFFFD86B), Color(0xFFFFA94D), Color(0xFFFFFFFF)],
          blendMode: BlendMode.plus,
          rise: 52,
        );
      case EmotionType.focused:
        return const WaveConfig(
          type: EmotionType.focused,
          label: '집중',
          amplitude: 30,
          frequency: 2.05,
          smoothness: 0.88,
          chaos: 0.04,
          speed: 0.92,
          colors: [Color(0xFF1BE0B5), Color(0xFF83F7D5), Color(0xFF3AA8FF)],
          blendMode: BlendMode.screen,
        );
      case EmotionType.tired:
        return const WaveConfig(
          type: EmotionType.tired,
          label: '저하',
          amplitude: 20,
          frequency: 0.95,
          smoothness: 0.82,
          chaos: 0.1,
          speed: 0.48,
          colors: [Color(0xFF758591), Color(0xFFAEB8BE), Color(0xFF55636A)],
          blendMode: BlendMode.srcOver,
          rise: -12,
        );
      case EmotionType.joyful:
        return const WaveConfig(
          type: EmotionType.joyful,
          label: '활기',
          amplitude: 38,
          frequency: 2.35,
          smoothness: 0.56,
          chaos: 0.2,
          speed: 1.35,
          colors: [Color(0xFFFF8B9C), Color(0xFFFFD166), Color(0xFFFF6F91)],
          blendMode: BlendMode.screen,
        );
      case EmotionType.calm:
        return const WaveConfig(
          type: EmotionType.calm,
          label: '평온',
          amplitude: 26,
          frequency: 1.1,
          smoothness: 0.96,
          chaos: 0.03,
          speed: 0.62,
          colors: [Color(0xFF6EC99E), Color(0xFFA6E7C6), Color(0xFFEAC98C)],
          blendMode: BlendMode.srcOver,
        );
    }
  }
}

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

class RhythmEntry {
  const RhythmEntry({
    required this.id,
    required this.createdAt,
    required this.energy,
    required this.emotions,
    required this.activities,
    required this.note,
  });

  final String id;
  final DateTime createdAt;
  final int energy;
  final List<String> emotions;
  final List<String> activities;
  final String note;

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'energy': energy,
    'emotions': emotions,
    'activities': activities,
    'note': note,
  };

  factory RhythmEntry.fromJson(Map<String, dynamic> json) {
    return RhythmEntry(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      energy: json['energy'] as int,
      emotions: List<String>.from(json['emotions'] as List),
      activities: List<String>.from(json['activities'] as List),
      note: json['note'] as String? ?? '',
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

  late final AnimationController _controller;
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
    _loadEntries();
  }

  @override
  void dispose() {
    _controller.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey);
    if (raw == null || raw.isEmpty) {
      _entries = _sampleEntries();
      await _saveEntries();
    } else {
      _entries =
          raw.map((item) => RhythmEntry.fromJson(jsonDecode(item))).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    setState(() => _loaded = true);
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      _entries.map((entry) => jsonEncode(entry.toJson())).toList(),
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

    final entry = RhythmEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
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
      ),
      RhythmEntry(
        id: 'sample-2',
        createdAt: now.subtract(const Duration(days: 2)),
        energy: 2,
        emotions: const ['피곤', '불안'],
        activities: const ['업무', '휴식'],
        note: '일정이 겹쳐서 에너지가 다소 낮았다. 충분한 수면이 필요한 날이다.',
      ),
      RhythmEntry(
        id: 'sample-3',
        createdAt: now.subtract(const Duration(days: 3)),
        energy: 5,
        emotions: const ['기쁨', '설렘'],
        activities: const ['친구', '산책'],
        note: '밖에서 걸으며 가볍게 이야기하니 에너지가 솟았다. 초록빛 파장이 너무 신선하게 드러난다.',
      ),
      RhythmEntry(
        id: 'sample-4',
        createdAt: now.subtract(const Duration(days: 4)),
        energy: 3,
        emotions: const ['평온'],
        activities: const ['독서', '휴식'],
        note: '조용하고 안락하게 흘러간 날. 복잡한 생각 정리도 조금 했다.',
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
      _HomeTab(
        energy: _energy,
        selectedEmotions: _selectedEmotions,
        selectedActivities: _selectedActivities,
        emotionOptions: _emotionOptions,
        activityOptions: _activityOptions,
        noteController: _noteController,
        animation: _controller,
        previewEntry: _previewEntry,
        onEnergyChanged: (value) => setState(() => _energy = value.round()),
        onEmotionToggle: _toggleEmotion,
        onActivityToggle: _toggleActivity,
        onSave: _addTodayEntry,
      ),
      _HistoryTab(entries: _entries),
      _PatternTab(entries: _entries),
    ];

    return Scaffold(
      body: SafeArea(
        child: !_loaded
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      children: [
                        _Header(onReset: _resetDemoData),
                        const SizedBox(height: 14),
                        Expanded(child: pages[_tabIndex]),
                      ],
                    ),
                  ),
                ),
              ),
      ),
      bottomNavigationBar: _FloatingNavBar(
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

// ============================================================
// Premium Header Component
// ============================================================

class _Header extends StatelessWidget {
  const _Header({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Brand symbol with luxurious metallic frame
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.waves_rounded,
              color: AppColors.accentLight,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    'Rhythm',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                      height: 1.05,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '•',
                    style: TextStyle(color: AppColors.accent, fontSize: 20),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'v0.1.0 데모',
                    style: TextStyle(
                      color: AppColors.accentBronze,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '매일 30초, 감정의 파도를 예술로 기록합니다.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: '데모 데이터 초기화',
          onPressed: onReset,
          icon: const Icon(Icons.refresh_rounded, size: 20),
          style: IconButton.styleFrom(
            foregroundColor: AppColors.textMuted,
            backgroundColor: AppColors.surfaceAlt.withValues(alpha: 0.55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(10),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Premium Floating Navigation Bar
// ============================================================

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.auto_awesome_outlined, Icons.auto_awesome, '오늘'),
      (Icons.calendar_month_outlined, Icons.calendar_month, '히스토리'),
      (Icons.insights_outlined, Icons.insights, '패턴'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutBack,
                  alignment: Alignment(-1.0 + (selectedIndex * 1.0), 0.0),
                  child: FractionallySizedBox(
                    widthFactor: 0.3,
                    heightFactor: 0.72,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accent.withValues(alpha: 0.16),
                            AppColors.accentLight.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(items.length, (index) {
                    final isSelected = selectedIndex == index;
                    final item = items[index];
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onDestinationSelected(index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              scale: isSelected ? 1.15 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                isSelected ? item.$2 : item.$1,
                                color: isSelected
                                    ? AppColors.accentLight
                                    : AppColors.textSecondary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item.$3,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Premium Energy Selector — Animated Glassmorphic Cards
// ============================================================

class _EnergySelector extends StatelessWidget {
  const _EnergySelector({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  static const _labels = ['매우 낮음', '낮음', '보통', '높음', '매우 높음'];
  static const _descriptions = [
    '충분한 수면과 휴식이 필요한 상태',
    '차분하고 정돈된 상태',
    '안정적이고 균형 잡힌 에너지',
    '활기차고 긍정적인 집중력',
    '강한 의욕과 최고의 몰입 상태',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '에너지 레벨',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.28),
                  width: 0.8,
                ),
              ),
              child: Text(
                '$value / 5',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accentLight,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final level = index + 1;
            final isSelected = level == value;

            final Color activeGlowColor;
            if (level <= 2) {
              activeGlowColor = const Color(0xFF758591);
            } else if (level == 3) {
              activeGlowColor = AppColors.accentBronze;
            } else {
              activeGlowColor = AppColors.accent;
            }

            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(level),
                child: AnimatedScale(
                  scale: isSelected ? 1.03 : 0.95,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutBack,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.surfaceAlt.withValues(alpha: 0.8)
                          : AppColors.surface.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? activeGlowColor.withValues(alpha: 0.7)
                            : AppColors.border,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: activeGlowColor.withValues(alpha: 0.2),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? activeGlowColor
                                : AppColors.surfaceAlt,
                            shape: BoxShape.circle,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: activeGlowColor.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '$level',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isSelected
                                    ? AppColors.background
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _labels[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.accentLight.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '에너지 레벨 $value: ${_descriptions[value - 1]}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Premium Chip Component
// ============================================================

class _PremiumChip extends StatelessWidget {
  const _PremiumChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.activeColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final defaultActiveColor = activeColor ?? AppColors.accent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? defaultActiveColor.withValues(alpha: 0.18)
                : AppColors.surfaceAlt.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? defaultActiveColor.withValues(alpha: 0.85)
                  : AppColors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: defaultActiveColor.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: defaultActiveColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipSection extends StatelessWidget {
  const _ChipSection({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.onToggle,
    this.isEmotion = false,
  });

  final String title;
  final String subtitle;
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final bool isEmotion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final active = selected.contains(option);
            final color = isEmotion
                ? emotionColor([option])
                : AppColors.accentLight;
            return _PremiumChip(
              label: option,
              isSelected: active,
              onTap: () => onToggle(option),
              activeColor: color,
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ============================================================
// Home Tab Components — Panel, Canvas, and Input UI
// ============================================================

class _HomeTab extends StatelessWidget {
  const _HomeTab({
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
        final input = _Panel(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              const Text(
                '오늘의 리듬 기록',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 18),
              _EnergySelector(
                value: energy,
                onChanged: (v) => onEnergyChanged(v.toDouble()),
              ),
              const SizedBox(height: 18),
              _ChipSection(
                title: '감정 키워드',
                subtitle: '최대 3개 선택',
                options: emotionOptions,
                selected: selectedEmotions,
                onToggle: onEmotionToggle,
                isEmotion: true,
              ),
              const SizedBox(height: 18),
              _ChipSection(
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
                  fillColor: AppColors.surfaceAlt.withValues(alpha: 0.35),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.accent),
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
                    borderRadius: BorderRadius.circular(16),
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
        );

        final hasWavePreview = selectedEmotions.isNotEmpty;
        final canvas = _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Wave Graph (움직이는 리듬 파동)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: hasWavePreview
                      ? _WaveCanvas(
                          energy: energy,
                          emotions: selectedEmotions,
                          entry: previewEntry,
                          animation: animation,
                        )
                      : const _EmptyWavePlaceholder(),
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
        return ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            SizedBox(height: 490, child: input),
            const SizedBox(height: 16),
            SizedBox(height: 440, child: canvas),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _EmptyWavePlaceholder extends StatelessWidget {
  const _EmptyWavePlaceholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.92),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
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

class _WaveCanvas extends StatefulWidget {
  const _WaveCanvas({
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
  State<_WaveCanvas> createState() => _WaveCanvasState();
}

class _WaveCanvasState extends State<_WaveCanvas> {
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

// ============================================================
// History Tab Component
// ============================================================

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.entries});

  final List<RhythmEntry> entries;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '히스토리',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: entries.isEmpty
                ? const Center(
                    child: Text(
                      '아직 등록된 기록이 없습니다.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ListView.separated(
                    itemCount: entries.length,
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final eColor = emotionColor(entry.emotions);
                      final dateStr =
                          '${entry.createdAt.month}월 ${entry.createdAt.day}일';

                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Elegant glowing energy badge
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: eColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: eColor.withValues(alpha: 0.75),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: eColor.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.energy}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: eColor,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date + emotions
                                  Row(
                                    children: [
                                      Text(
                                        dateStr,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          entry.emotions.join('  ·  '),
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                            color: eColor,
                                            height: 1.2,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Activities as custom chips
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: entry.activities.map((act) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 3.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface.withValues(
                                            alpha: 0.8,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: AppColors.border,
                                            width: 0.6,
                                          ),
                                        ),
                                        child: Text(
                                          act,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  // Optional notes inside luxury block
                                  if (entry.note.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface.withValues(
                                          alpha: 0.45,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: AppColors.border,
                                          width: 0.6,
                                        ),
                                      ),
                                      child: Text(
                                        entry.note,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                          height: 1.45,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Pattern Tab Component
// ============================================================

class _PatternTab extends StatelessWidget {
  const _PatternTab({required this.entries});

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
        _Panel(
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
        _Panel(
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

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(22)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: AppShadows.card,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

// ============================================================
// Rhythm Wave Visualizer — Moving emotional sine wave graph
// ============================================================

class RhythmWavePainter extends CustomPainter {
  RhythmWavePainter({
    required this.progress,
    required this.entry,
    required this.previewEnergy,
    required this.previewEmotions,
    required this.touchPoint,
    required this.touchStart,
  });

  final double progress;
  final RhythmEntry? entry;
  final int previewEnergy;
  final Set<String> previewEmotions;
  final Offset? touchPoint;
  final double touchStart;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final emotions = entry?.emotions ?? previewEmotions.toList();
    final baseColor = emotionColor(emotions);
    final energy = entry?.energy ?? previewEnergy;
    final configs = _waveConfigsFor(emotions, energy);
    final waveCount = configs.length;

    _paintBackground(canvas, rect, baseColor);
    _paintGrid(canvas, size);
    _paintAxisLabels(canvas, size);

    for (var i = 0; i < waveCount; i++) {
      final config = configs[i];
      final baseline =
          size.height * (0.34 + i * (0.34 / max(1, waveCount - 1)));

      _paintWave(
        canvas: canvas,
        size: size,
        config: config,
        baseline: baseline,
        phase: progress * pi * 2 * config.speed + i * 0.85,
        glow: i == 0,
      );
    }

    _paintTouchPulse(canvas, baseColor);
    _paintHeader(canvas, size, energy, emotions);
  }

  void _paintBackground(Canvas canvas, Rect rect, Color baseColor) {
    final background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF030607),
          Color.lerp(baseColor, const Color(0xFF061113), 0.82)!,
          const Color(0xFF080B0C),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, background);

    final glow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.15),
        radius: 0.95,
        colors: [
          baseColor.withValues(alpha: 0.28),
          AppColors.accent.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.42, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, glow);
  }

  void _paintGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    final strongPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.16)
      ..strokeWidth = 1.2;

    for (var i = 1; i < 6; i++) {
      final y = size.height * i / 6;
      canvas.drawLine(Offset(22, y), Offset(size.width - 18, y), gridPaint);
    }
    for (var i = 1; i < 7; i++) {
      final x = size.width * i / 7;
      canvas.drawLine(Offset(x, 56), Offset(x, size.height - 28), gridPaint);
    }

    final mid = size.height * 0.52;
    canvas.drawLine(Offset(20, mid), Offset(size.width - 18, mid), strongPaint);
  }

  void _paintAxisLabels(Canvas canvas, Size size) {
    final labels = ['차분', '흐름', '고조'];
    for (var i = 0; i < labels.length; i++) {
      final y = size.height * (0.74 - i * 0.24);
      final painter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: AppColors.textMuted.withValues(alpha: 0.7),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, Offset(20, y));
    }
  }

  void _paintWave({
    required Canvas canvas,
    required Size size,
    required WaveConfig config,
    required double baseline,
    required double phase,
    required bool glow,
  }) {
    final path = Path();
    final fillPath = Path()..moveTo(0, size.height);
    final color = config.colors.first;
    final amplitude = config.amplitude.clamp(14.0, 76.0);

    const step = 5.0;
    for (double x = 0; x <= size.width + step; x += step) {
      final normalized = x / size.width;
      final y = _sampleEmotionWave(
        normalized: normalized,
        baseline: baseline,
        amplitude: amplitude,
        phase: phase,
        config: config,
      );
      if (x == 0) {
        path.moveTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath
      ..lineTo(size.width, size.height)
      ..close();

    if (glow) {
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.20), Colors.transparent],
        ).createShader(Offset.zero & size);
      canvas.drawPath(fillPath, fillPaint);
    }

    if (glow) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
      canvas.drawPath(path, glowPaint);
    }

    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: config.colors.map((c) => c.withValues(alpha: 0.94)).toList(),
      ).createShader(Offset.zero & size)
      ..blendMode = config.blendMode
      ..style = PaintingStyle.stroke
      ..strokeWidth = glow ? 3.2 : 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);
  }

  double _sampleEmotionWave({
    required double normalized,
    required double baseline,
    required double amplitude,
    required double phase,
    required WaveConfig config,
  }) {
    final sine = sin(normalized * pi * 2 * config.frequency + phase);
    final overtone = sin(
      normalized * pi * 2 * (config.frequency * 0.5) - phase * 0.7,
    );
    final noise = _valueNoise(normalized * 10 + phase * 0.23);
    final jag =
        (sin(normalized * pi * 2 * config.frequency * 3 + phase) >= 0
            ? 1.0
            : -1.0) *
        (0.35 + noise.abs() * 0.65);

    var shape = sine * config.smoothness + jag * (1 - config.smoothness);
    shape += overtone * 0.22;
    shape += noise * config.chaos;

    switch (config.type) {
      case EmotionType.anxious:
        shape += _sharpSpike(normalized, phase) * config.chaos;
      case EmotionType.achievement:
        shape += normalized * 0.7 - 0.35;
      case EmotionType.focused:
        shape =
            sin(normalized * pi * 2 * config.frequency + phase) * 0.78 +
            sin(normalized * pi * 4 * config.frequency + phase * 0.5) * 0.12;
      case EmotionType.calm:
        shape = sine * 0.86 + overtone * 0.12;
      case EmotionType.tired:
        shape = sine * 0.52 + overtone * 0.08 - normalized * 0.18;
      case EmotionType.joyful:
        shape += sin(normalized * pi * 10 + phase * 1.8) * 0.13;
    }

    return baseline - config.rise * normalized + shape * amplitude;
  }

  double _sharpSpike(double normalized, double phase) {
    final moving = (normalized * 5.0 + phase / (pi * 2)) % 1.0;
    final spike = 1 - (moving - 0.5).abs() * 2;
    return pow(max(0, spike), 6).toDouble() * 1.7;
  }

  double _valueNoise(double value) {
    final left = value.floorToDouble();
    final right = left + 1;
    final t = value - left;
    final smoothT = t * t * (3 - 2 * t);
    return _hashNoise(left) * (1 - smoothT) + _hashNoise(right) * smoothT;
  }

  double _hashNoise(double value) {
    final hash = sin(value * 127.1 + 311.7) * 43758.5453;
    return (hash - hash.floorToDouble()) * 2 - 1;
  }

  void _paintTouchPulse(Canvas canvas, Color baseColor) {
    final point = touchPoint;
    if (point == null) return;
    final rawAge = progress - touchStart;
    final age = rawAge < 0 ? rawAge + 1 : rawAge;
    if (age > 0.45) return;

    final t = (age / 0.45).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = baseColor.withValues(alpha: (1 - t) * 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * (1 - t)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(point, 28 + 130 * t, paint);
  }

  void _paintHeader(
    Canvas canvas,
    Size size,
    int energy,
    List<String> emotions,
  ) {
    final title = TextPainter(
      text: TextSpan(
        text: 'Energy $energy  ·  ${emotions.join('  /  ')}',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.65),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 48);
    title.paint(canvas, const Offset(22, 22));

    final caption = TextPainter(
      text: TextSpan(
        text: '감정 파동 그래프',
        style: TextStyle(
          color: AppColors.textGold.withValues(alpha: 0.82),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 48);
    caption.paint(canvas, const Offset(22, 45));
  }

  List<WaveConfig> _waveConfigsFor(List<String> emotions, int energy) {
    final source = emotions.isEmpty ? ['평온'] : emotions;
    final configs = <WaveConfig>[];
    for (var i = 0; i < source.length.clamp(1, 4); i++) {
      configs.add(
        WaveBehavior.configFor(
          source[i % source.length],
        ).scaledByEnergy(energy, i),
      );
    }
    return configs;
  }

  @override
  bool shouldRepaint(covariant RhythmWavePainter oldDelegate) {
    return true;
  }
}

// ============================================================
// Weekly Spline Chart Painter (Bézier Splines + Gradient Fill)
// ============================================================

class WeeklyRhythmPainter extends CustomPainter {
  WeeklyRhythmPainter({required this.entries});

  final List<RhythmEntry> entries;

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(24, size.height - 32),
      Offset(size.width - 24, size.height - 32),
      axisPaint,
    );

    if (entries.isEmpty) return;

    final recent = entries.take(7).toList().reversed.toList();
    final List<Offset> points = [];

    for (var i = 0; i < recent.length; i++) {
      final x = recent.length == 1
          ? size.width / 2
          : 24 + i * ((size.width - 48) / (recent.length - 1));
      final y =
          size.height - 32 - (recent[i].energy / 5.2) * (size.height - 64);
      points.add(Offset(x, y));
    }

    if (points.isNotEmpty) {
      final path = Path();
      final fillPath = Path();

      path.moveTo(points[0].dx, points[0].dy);
      fillPath.moveTo(points[0].dx, size.height - 32);
      fillPath.lineTo(points[0].dx, points[0].dy);

      for (var i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final controlX1 = p0.dx + (p1.dx - p0.dx) / 2;
        final controlY1 = p0.dy;
        final controlX2 = p0.dx + (p1.dx - p0.dx) / 2;
        final controlY2 = p1.dy;

        path.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
        fillPath.cubicTo(
          controlX1,
          controlY1,
          controlX2,
          controlY2,
          p1.dx,
          p1.dy,
        );
      }

      fillPath.lineTo(points.last.dx, size.height - 32);
      fillPath.close();

      // Curved gradient fill
      final fillGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.accent.withValues(alpha: 0.28),
          AppColors.accent.withValues(alpha: 0.0),
        ],
      ).createShader(Offset.zero & size);

      final fillPaint = Paint()
        ..shader = fillGradient
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, fillPaint);

      // Main curved spline path
      final linePaint = Paint()
        ..color = AppColors.accentLight
        ..strokeWidth = 3.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, linePaint);

      // Render nodes with customized colors and shadow glow
      final dotPaint = Paint()..style = PaintingStyle.fill;
      final dotStroke = Paint()
        ..color = AppColors.surfaceAlt
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      for (var i = 0; i < points.length; i++) {
        final p = points[i];
        final eColor = emotionColor(recent[i].emotions);

        final glowPaint = Paint()
          ..color = eColor.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawCircle(p, 8.5, glowPaint);

        dotPaint.color = eColor;
        canvas.drawCircle(p, 5.5, dotPaint);
        canvas.drawCircle(p, 5.5, dotStroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant WeeklyRhythmPainter oldDelegate) {
    return oldDelegate.entries != entries;
  }
}

String? topKey(Map<String, int> counts) {
  if (counts.isEmpty) return null;
  return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
}
