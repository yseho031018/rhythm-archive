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
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
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

// ============================================================
// Particle System — emotional motion driven by energy + keywords
// ============================================================

enum BehaviorMode {
  calm,
  vibrant,
  chaotic,
  focused,
}

BehaviorMode resolveBehaviorMode(int energy, List<String> emotions) {
  if (emotions.contains('불안')) return BehaviorMode.chaotic;
  if (emotions.contains('집중') || emotions.contains('성취감')) {
    return BehaviorMode.focused;
  }
  if (energy >= 4 &&
      (emotions.contains('기쁨') || emotions.contains('설렘'))) {
    return BehaviorMode.vibrant;
  }
  if (energy <= 2 ||
      emotions.contains('피곤') ||
      emotions.contains('무기력')) {
    return BehaviorMode.calm;
  }
  return BehaviorMode.vibrant;
}

double perlinNoise(double x, double y) {
  double hash(int xi, int yi) {
    final s = sin(xi * 127.1 + yi * 311.7) * 43758.5453;
    return (s - s.floorToDouble()) * 2.0 - 1.0;
  }

  double smooth(double t) => t * t * (3 - 2 * t);
  double mix(double a, double b, double t) => a + (b - a) * t;

  final xi = x.floor();
  final yi = y.floor();
  final xf = x - xi;
  final yf = y - yi;
  final u = smooth(xf);
  final v = smooth(yf);
  final n00 = hash(xi, yi);
  final n10 = hash(xi + 1, yi);
  final n01 = hash(xi, yi + 1);
  final n11 = hash(xi + 1, yi + 1);
  return mix(mix(n00, n10, u), mix(n01, n11, u), v);
}

class ParticleContext {
  const ParticleContext({
    required this.size,
    required this.dt,
    required this.time,
    required this.attractor,
    required this.mode,
    required this.energy,
    required this.baseColor,
  });

  final Size size;
  final double dt;
  final double time;
  final Offset attractor;
  final BehaviorMode mode;
  final double energy;
  final Color baseColor;
}

class Particle {
  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.maxLife,
    required this.noiseOffset,
    this.acceleration = Offset.zero,
  })  : life = maxLife,
        opacity = 0.0;

  Offset position;
  Offset velocity;
  Offset acceleration;
  double size;
  double opacity;
  double life;
  final double maxLife;
  Color color;
  final double noiseOffset;

  bool get isDead => life <= 0;

  void update(ParticleContext ctx) {
    final dt = ctx.dt;

    final nx = perlinNoise(
      noiseOffset + position.dx * 0.005,
      ctx.time * 0.25,
    );
    final ny = perlinNoise(
      ctx.time * 0.25 + 17.3,
      noiseOffset + position.dy * 0.005,
    );

    final toAttractor = ctx.attractor - position;
    final dist = toAttractor.distance.clamp(1.0, 2000.0);
    final pullDir = toAttractor / dist;
    final tangent = Offset(-pullDir.dy, pullDir.dx);

    late final double pullStrength;
    late final double noiseStrength;
    late final double orbitStrength;
    late final double damping;
    switch (ctx.mode) {
      case BehaviorMode.calm:
        pullStrength = 6.0;
        noiseStrength = 14.0;
        orbitStrength = 12.0;
        damping = 0.94;
      case BehaviorMode.vibrant:
        pullStrength = 24.0;
        noiseStrength = 52.0;
        orbitStrength = 42.0;
        damping = 0.93;
      case BehaviorMode.chaotic:
        pullStrength = 5.0;
        noiseStrength = 130.0;
        orbitStrength = 18.0;
        damping = 0.88;
      case BehaviorMode.focused:
        pullStrength = 70.0;
        noiseStrength = 16.0;
        orbitStrength = 58.0;
        damping = 0.90;
    }

    acceleration = pullDir * pullStrength +
        tangent * orbitStrength +
        Offset(nx, ny) * noiseStrength;

    velocity = (velocity + acceleration * dt) * damping;
    position += velocity * dt;

    life -= dt;
    final lifeT = (life / maxLife).clamp(0.0, 1.0);
    final fadeIn = ((1 - lifeT) / 0.2).clamp(0.0, 1.0);
    final fadeOut = (lifeT / 0.6).clamp(0.0, 1.0);
    opacity = (fadeIn * fadeOut).clamp(0.0, 1.0);
  }

  void draw(ParticleContext ctx, Canvas canvas) {
    if (opacity <= 0.01) return;

    // Soft outer luxurious glow
    final haloPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.38)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 1.8);
    canvas.drawCircle(position, size * 2.3, haloPaint);

    if (size >= 4) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: opacity * 0.6)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.75);
      canvas.drawCircle(position, size * 1.2, glowPaint);
    }

    // High-crisp diamond core
    final corePaint = Paint()..color = color.withValues(alpha: opacity);
    canvas.drawCircle(position, size, corePaint);

    if (ctx.mode == BehaviorMode.focused ||
        ctx.mode == BehaviorMode.vibrant) {
      final spec = Paint()
        ..color = Colors.white.withValues(alpha: opacity * 0.9);
      canvas.drawCircle(
        position - Offset(size * 0.3, size * 0.3),
        size * 0.35,
        spec,
      );
    }
  }
}

// ============================================================
// Interactive Ripples on Canvas
// ============================================================

class CanvasRipple {
  CanvasRipple({
    required this.position,
    required this.color,
    this.maxRadius = 160.0,
    this.duration = 1.2,
  }) : age = 0;

  final Offset position;
  final Color color;
  final double maxRadius;
  final double duration;
  double age;

  bool get isDead => age >= duration;

  void update(double dt) {
    age += dt;
  }

  void draw(Canvas canvas) {
    final t = (age / duration).clamp(0.0, 1.0);
    final radius = t * maxRadius;
    final opacity = (1.0 - t).clamp(0.0, 1.0);

    final paint = Paint()
      ..color = color.withValues(alpha: opacity * 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * (1.0 - t)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    canvas.drawCircle(position, radius, paint);
  }
}

class ParticleField {
  ParticleField({this.maxParticles = 100});

  final int maxParticles;
  final List<Particle> _particles = [];
  final List<CanvasRipple> _ripples = [];
  final Random _rng = Random();
  final Stopwatch _clock = Stopwatch()..start();
  double _lastTime = 0;
  ParticleContext? _lastCtx;

  int get count => _particles.length;

  void update({
    required Size size,
    required double energy,
    required Color baseColor,
    required Offset attractor,
    required BehaviorMode mode,
  }) {
    final now = _clock.elapsedMicroseconds / 1e6;
    final dt = _lastTime == 0
        ? 1 / 60
        : (now - _lastTime).clamp(0.001, 0.05);
    _lastTime = now;

    final ctx = ParticleContext(
      size: size,
      dt: dt,
      time: now,
      attractor: attractor,
      mode: mode,
      energy: energy,
      baseColor: baseColor,
    );

    for (final p in _particles) {
      p.update(ctx);
    }
    _particles.removeWhere((p) => p.isDead);

    for (final r in _ripples) {
      r.update(dt);
    }
    _ripples.removeWhere((r) => r.isDead);

    final target = (45 + energy * 11).toInt().clamp(25, maxParticles);
    final deficit = target - _particles.length;
    if (deficit > 0) {
      final spawn = (deficit * 0.15).ceil().clamp(0, 6);
      for (var i = 0; i < spawn; i++) {
        _particles.add(_spawn(ctx));
      }
    }

    _lastCtx = ctx;
  }

  void draw(Canvas canvas) {
    final ctx = _lastCtx;
    if (ctx == null) return;
    
    for (final p in _particles) {
      p.draw(ctx, canvas);
    }

    for (final r in _ripples) {
      r.draw(canvas);
    }
  }

  Particle _spawn(ParticleContext ctx) {
    final angle = _rng.nextDouble() * pi * 2;
    final radius = 70 + _rng.nextDouble() * (85 + ctx.energy * 20);
    final position =
        ctx.attractor + Offset(cos(angle), sin(angle)) * radius;
    final tangent = Offset(-sin(angle), cos(angle));
    final speed = 8 + _rng.nextDouble() * (12 + ctx.energy * 4);
    final velocity = tangent * speed;

    final base = 3 + (ctx.energy - 1) * 2.85;
    final size =
        (base * (0.55 + _rng.nextDouble() * 0.75)).clamp(3.0, 15.0);

    final accent = _rng.nextBool()
        ? Colors.white
        : const Color(0xFFF7DCA7); // Warm sparkling champagne
    final color = Color.lerp(
      ctx.baseColor,
      accent,
      _rng.nextDouble() * 0.55,
    )!;

    return Particle(
      position: position,
      velocity: velocity,
      color: color,
      size: size,
      maxLife: 3.5 + _rng.nextDouble() * 4.5,
      noiseOffset: _rng.nextDouble() * 100,
    );
  }

  // Interactive spark spawn burst when tapped
  void spawnTouchBurst(Offset offset, Color baseColor, double energy) {
    for (var i = 0; i < 20; i++) {
      final angle = _rng.nextDouble() * pi * 2;
      final speed = 40.0 + _rng.nextDouble() * 125.0;
      final velocity = Offset(cos(angle), sin(angle)) * speed;
      
      final size = 2.0 + _rng.nextDouble() * 4.5;
      final color = Color.lerp(
        baseColor,
        Colors.white,
        0.3 + _rng.nextDouble() * 0.55,
      )!;

      _particles.add(Particle(
        position: offset,
        velocity: velocity,
        color: color,
        size: size,
        maxLife: 0.8 + _rng.nextDouble() * 1.3,
        noiseOffset: _rng.nextDouble() * 100.0,
      ));
    }
  }

  // Interactive drag sparks
  void spawnDragSpark(Offset offset, Color baseColor) {
    final angle = _rng.nextDouble() * pi * 2;
    final speed = 15.0 + _rng.nextDouble() * 35.0;
    final velocity = Offset(cos(angle), sin(angle)) * speed;
    
    _particles.add(Particle(
      position: offset,
      velocity: velocity,
      color: Color.lerp(baseColor, Colors.white, 0.45)!,
      size: 2.2 + _rng.nextDouble() * 3.0,
      maxLife: 0.6 + _rng.nextDouble() * 0.6,
      noiseOffset: _rng.nextDouble() * 100.0,
    ));
  }

  void addRipple(Offset position, Color color) {
    _ripples.add(CanvasRipple(
      position: position,
      color: color,
    ));
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
  final Set<String> _selectedEmotions = {'평온'};
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(
      content: Text('오늘의 리듬을 성공적으로 기록했습니다.'),
      backgroundColor: AppColors.primaryLight,
    ));
  }

  Future<void> _resetDemoData() async {
    setState(() {
      _entries = _sampleEntries();
      _energy = 3;
      _selectedEmotions
        ..clear()
        ..add('평온');
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
    if (_entries.isNotEmpty) return _entries.first;
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
        if (_selectedEmotions.length > 1) _selectedEmotions.remove(emotion);
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
            child: Icon(Icons.waves_rounded, color: AppColors.accentLight, size: 28),
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
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 20,
                    ),
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
                  alignment: Alignment(
                    -1.0 + (selectedIndex * 1.0),
                    0.0,
                  ),
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
    '강한 의욕과 최고의 몰입 상태'
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
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
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
                                      color: activeGlowColor.withValues(alpha: 0.35),
                                      blurRadius: 8,
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '$level',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isSelected ? AppColors.background : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _labels[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
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
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
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
            final color = isEmotion ? emotionColor([option]) : AppColors.accentLight;
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
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  labelText: '짧은 메모',
                  labelStyle: const TextStyle(color: AppColors.accentBronze, fontWeight: FontWeight.w600),
                  hintText: '오늘의 리듬을 한 문장으로 기록해 보세요.',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceAlt.withValues(alpha: 0.35),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      colors: [
                        AppColors.accentBronze,
                        AppColors.accent,
                      ],
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
                      Icon(Icons.auto_awesome, color: AppColors.background, size: 20),
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
        
        final canvas = _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Particle Canvas (예술 시각화)',
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
                  child: _ParticleCanvas(
                    energy: energy,
                    emotions: selectedEmotions,
                    entry: previewEntry,
                    animation: animation,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.touch_app_outlined, size: 14, color: AppColors.textMuted),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '캔버스를 터치하거나 드래그하여 감정의 파동과 스파클을 일으켜 보세요.',
                      style: TextStyle(
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

class _ParticleCanvas extends StatefulWidget {
  const _ParticleCanvas({
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
  State<_ParticleCanvas> createState() => _ParticleCanvasState();
}

class _ParticleCanvasState extends State<_ParticleCanvas> {
  late final ParticleField _field = ParticleField();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final localPos = box.globalToLocal(details.globalPosition);

        final emotions = widget.entry?.emotions ?? widget.emotions.toList();
        final baseColor = emotionColor(emotions);
        final energy = widget.entry?.energy ?? widget.energy;

        _field.addRipple(localPos, baseColor);
        _field.spawnTouchBurst(localPos, baseColor, energy.toDouble());
      },
      onPanUpdate: (details) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final localPos = box.globalToLocal(details.globalPosition);

        final emotions = widget.entry?.emotions ?? widget.emotions.toList();
        final baseColor = emotionColor(emotions);

        if (Random().nextDouble() < 0.4) {
          _field.spawnDragSpark(localPos, baseColor);
        }
      },
      child: AnimatedBuilder(
        animation: widget.animation,
        builder: (context, _) {
          return CustomPaint(
            painter: RhythmParticlePainter(
              progress: widget.animation.value,
              entry: widget.entry,
              previewEnergy: widget.energy,
              previewEmotions: widget.emotions,
              field: _field,
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
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
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
                                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface.withValues(alpha: 0.8),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColors.border, width: 0.6),
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
                                        color: AppColors.surface.withValues(alpha: 0.45),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.border, width: 0.6),
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
// Rhythm Particle Visualizer — Beautiful Dynamic custom painter
// ============================================================

class RhythmParticlePainter extends CustomPainter {
  RhythmParticlePainter({
    required this.progress,
    required this.entry,
    required this.previewEnergy,
    required this.previewEmotions,
    required this.field,
  });

  final double progress;
  final RhythmEntry? entry;
  final int previewEnergy;
  final Set<String> previewEmotions;
  final ParticleField field;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final emotions = entry?.emotions ?? previewEmotions.toList();
    final baseColor = emotionColor(emotions);
    final energy = entry?.energy ?? previewEnergy;
    final mode = resolveBehaviorMode(energy, emotions);

    // Dynamic, deep cosmic dark gradient
    final background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF040708),
          Color.lerp(baseColor, const Color(0xFF071214), 0.78)!,
          Color.lerp(baseColor, const Color(0xFF0B191B), 0.64)!,
          const Color(0xFF06090A),
        ],
        stops: const [0.0, 0.35, 0.7, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, background);

    // Subtle vignette for cinematic depth
    final vignette = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, 0.0),
        radius: 1.2,
        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.72)],
        stops: const [0.5, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);

    // Delicate golden framing border
    final borderPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.accent.withValues(alpha: 0.28),
          Colors.transparent,
          AppColors.border.withValues(alpha: 0.4),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawRect(rect, borderPaint);

    final center = Offset(size.width * 0.5, size.height * 0.5);

    // Concentric light waves
    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    for (var ring = 0; ring < 5; ring++) {
      final phase = progress * pi * 2 + ring * 0.7;
      final radius = 38.0 + ring * 38 + sin(phase) * (7 + energy * 0.8);
      canvas.drawCircle(center, radius + energy * 2.2, wavePaint);
    }

    // Soft central mood glow
    final glowPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.16 + (energy * 0.03))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 38);
    canvas.drawCircle(center, 56 + energy * 4, glowPaint);

    // Update & Renders particle field
    field.update(
      size: size,
      energy: energy.toDouble(),
      baseColor: baseColor,
      attractor: center,
      mode: mode,
    );
    field.draw(canvas);

    // Floating text label displaying current stats
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Energy $energy  ·  ${emotions.join('  /  ')}',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 48);
    textPainter.paint(canvas, const Offset(22, 22));
  }

  @override
  bool shouldRepaint(covariant RhythmParticlePainter oldDelegate) {
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
      final y = size.height - 32 - (recent[i].energy / 5.2) * (size.height - 64);
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
        fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
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
