import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// Premium Design System — Calm Luxury for Rhythm
// ============================================================

class AppColors {
  // Warm ivory / linen background (quiet luxury feel)
  static const ivory = Color(0xFFF8F5EF);
  static const surface = Color(0xFFFEFCF7);
  static const surfaceAlt = Color(0xFFFAF7F1);

  // Elegant warm borders
  static const border = Color(0xFFEDE6DB);
  static const borderStrong = Color(0xFFE0D6C7);

  // Sophisticated deep teal-green (primary brand)
  static const primary = Color(0xFF2B4F4E);
  static const primaryDark = Color(0xFF1F3837);
  static const primaryLight = Color(0xFF3D6362);

  // Warm bronze / gold accent for premium touches
  static const accent = Color(0xFF9C7C5B);
  static const accentLight = Color(0xFFB89A75);

  // Rich text hierarchy
  static const textPrimary = Color(0xFF2C2C2C);
  static const textSecondary = Color(0xFF6B665E);
  static const textMuted = Color(0xFF8C8579);

  // Subtle overlays
  static const overlay = Color(0x0A000000);
}

class AppRadii {
  static const card = 18.0;
  static const chip = 22.0;
  static const button = 14.0;
  static const energyDot = 28.0;
}

class AppShadows {
  static const card = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 28,
      offset: Offset(0, 14),
      spreadRadius: -2,
    ),
    BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
  ];

  static const subtle = [
    BoxShadow(color: Color(0x08000000), blurRadius: 16, offset: Offset(0, 6)),
  ];
}

Color emotionColor(List<String> emotions) {
  if (emotions.contains('불안')) {
    return const Color(0xFF6B5B9A); // deep elegant violet
  }
  if (emotions.contains('피곤')) {
    return const Color(0xFF6B7278); // muted slate
  }
  if (emotions.contains('성취감')) {
    return const Color(0xFFBF8A4A); // warm amber-bronze
  }
  if (emotions.contains('기쁨') || emotions.contains('설렘')) {
    return const Color(0xFFC46B7A); // refined rose
  }
  if (emotions.contains('집중')) {
    return AppColors.primary;
  }
  return const Color(0xFF5B7A6F); // calm sage
}

// ============================================================
// Particle System — emotional motion driven by energy + keywords
// ============================================================

/// Movement archetype derived from `(energy, emotions)`. Each mode tunes
/// attraction, noise amplitude, damping, and orbital pull independently.
enum BehaviorMode {
  /// Low velocity, soft drift, generous damping. (피곤 / 무기력 / 낮은 에너지)
  calm,

  /// Wide oscillation, bright halos, lively orbit. (기쁨 / 설렘 + 높은 에너지)
  vibrant,

  /// Heavy noise, weak attractor, scattered trajectories. (불안)
  chaotic,

  /// Tight orbit around the attractor, narrow scatter, strong glow.
  /// (집중 / 성취감)
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

/// 2D value-noise with smoothstep interpolation. Returns `[-1, 1]`.
/// Cheap enough to call twice per particle per frame; gives organic wiggle
/// without the cost of a full Perlin gradient table.
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

/// Per-frame context shared with every particle. Named `ParticleContext` to
/// avoid colliding with Flutter's built-in `PaintingContext` from
/// `flutter/rendering.dart`.
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
  final double dt; // seconds since the previous tick (clamped)
  final double time; // monotonic seconds since field creation
  final Offset attractor; // point particles are pulled toward
  final BehaviorMode mode;
  final double energy; // 1.0 .. 5.0
  final Color baseColor; // dominant emotion color
}

/// Single luminous particle. Owns its kinematic state and renders itself
/// with a 3-layer halo → mid-glow → core for a premium soft-glow look.
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

    // ── 1. Wiggle vector from 2D noise (decoupled X / Y channels) ─────
    final nx = perlinNoise(
      noiseOffset + position.dx * 0.005,
      ctx.time * 0.25,
    );
    final ny = perlinNoise(
      ctx.time * 0.25 + 17.3,
      noiseOffset + position.dy * 0.005,
    );

    // ── 2. Vector toward attractor (normalized) ───────────────────────
    final toAttractor = ctx.attractor - position;
    final dist = toAttractor.distance.clamp(1.0, 2000.0);
    final pullDir = toAttractor / dist;
    final tangent = Offset(-pullDir.dy, pullDir.dx); // 90° rotated

    // ── 3. Mode-specific tuning ───────────────────────────────────────
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

    // Semi-implicit Euler with velocity damping for stable motion.
    velocity = (velocity + acceleration * dt) * damping;
    position += velocity * dt;

    // ── 4. Life + fade envelope ───────────────────────────────────────
    life -= dt;
    final lifeT = (life / maxLife).clamp(0.0, 1.0);
    // Fade in over first 20% of life, fade out over last 60%.
    final fadeIn = ((1 - lifeT) / 0.2).clamp(0.0, 1.0);
    final fadeOut = (lifeT / 0.6).clamp(0.0, 1.0);
    opacity = (fadeIn * fadeOut).clamp(0.0, 1.0);
  }

  void draw(ParticleContext ctx, Canvas canvas) {
    if (opacity <= 0.01) return;

    // Outer halo — large soft blur, low alpha. The "premium" glow comes
    // from this layer being noticeably bigger than the core.
    final haloPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.32)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 1.6);
    canvas.drawCircle(position, size * 2.1, haloPaint);

    // Mid-glow — a softer wash that bridges halo and core.
    if (size >= 4) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: opacity * 0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.6);
      canvas.drawCircle(position, size * 1.15, glowPaint);
    }

    // Crisp core.
    final corePaint = Paint()..color = color.withValues(alpha: opacity);
    canvas.drawCircle(position, size, corePaint);

    // Specular highlight for active modes — adds that "jewel" sheen.
    if (ctx.mode == BehaviorMode.focused ||
        ctx.mode == BehaviorMode.vibrant) {
      final spec = Paint()
        ..color = Colors.white.withValues(alpha: opacity * 0.85);
      canvas.drawCircle(
        position - Offset(size * 0.3, size * 0.3),
        size * 0.32,
        spec,
      );
    }
  }
}

/// Owns a pool of particles, advances them each frame, and replenishes
/// the population to keep density proportional to current energy.
class ParticleField {
  ParticleField({this.maxParticles = 90});

  final int maxParticles;
  final List<Particle> _particles = [];
  final Random _rng = Random();
  final Stopwatch _clock = Stopwatch()..start();
  double _lastTime = 0;
  ParticleContext? _lastCtx;

  int get count => _particles.length;

  /// Advance one frame. `dt` is auto-computed from an internal stopwatch
  /// and clamped so that a paused window doesn't catapult particles off
  /// screen on resume.
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

    // Density target scales with energy: 40 (e=1) → 80 (e=5).
    final target = (40 + energy * 10).toInt().clamp(20, maxParticles);
    final deficit = target - _particles.length;
    if (deficit > 0) {
      // Spawn gradually to avoid pop-in flashes.
      final spawn = (deficit * 0.12).ceil().clamp(0, 5);
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
  }

  Particle _spawn(ParticleContext ctx) {
    // Spawn on a ring around the attractor, with radius widening for
    // higher energy. Initial velocity is tangential for orbital feel.
    final angle = _rng.nextDouble() * pi * 2;
    final radius = 70 + _rng.nextDouble() * (80 + ctx.energy * 20);
    final position =
        ctx.attractor + Offset(cos(angle), sin(angle)) * radius;
    final tangent = Offset(-sin(angle), cos(angle));
    final speed = 8 + _rng.nextDouble() * (10 + ctx.energy * 4);
    final velocity = tangent * speed;

    // Size: 3..14px, mapped from energy (1..5) with per-particle jitter.
    final base = 3 + (ctx.energy - 1) * 2.75; // 3..14
    final size =
        (base * (0.55 + _rng.nextDouble() * 0.75)).clamp(3.0, 14.0);

    // Color: blend the dominant emotion color toward white or a warm
    // bronze accent for variety. Keeps the palette cohesive.
    final accent = _rng.nextBool()
        ? Colors.white
        : const Color(0xFFEAC98C); // warm bronze sparkle
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
        scaffoldBackgroundColor: AppColors.ivory,
        fontFamily: 'Segoe UI',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.accent,
        ),
        // Premium typography scale
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -0.4,
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
            fontWeight: FontWeight.w700,
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
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: AppColors.textPrimary,
          ),
        ),
        // Elegant card / surface defaults
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.card),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        // Refined input / chip styles
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceAlt,
          selectedColor: AppColors.primary,
          disabledColor: AppColors.border,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          secondaryLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          side: const BorderSide(color: AppColors.border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.chip),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        // Premium slider (still used as fallback)
        sliderTheme: SliderThemeData(
          activeTrackColor: AppColors.primary,
          inactiveTrackColor: AppColors.borderStrong,
          thumbColor: AppColors.primary,
          overlayColor: AppColors.primary.withAlpha(30),
          trackHeight: 3.5,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
        ),
        // Button styles
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.button),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            elevation: 0,
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            hoverColor: AppColors.overlay,
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
    ).showSnackBar(const SnackBar(content: Text('오늘의 리듬을 저장했습니다.')));
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
        note: '발표 준비를 많이 진행했다.',
      ),
      RhythmEntry(
        id: 'sample-2',
        createdAt: now.subtract(const Duration(days: 2)),
        energy: 2,
        emotions: const ['피곤', '불안'],
        activities: const ['업무', '휴식'],
        note: '일정이 겹쳐서 에너지가 낮았다.',
      ),
      RhythmEntry(
        id: 'sample-3',
        createdAt: now.subtract(const Duration(days: 3)),
        energy: 5,
        emotions: const ['기쁨', '설렘'],
        activities: const ['친구', '산책'],
        note: '밖에서 걸으니 기분이 좋아졌다.',
      ),
      RhythmEntry(
        id: 'sample-4',
        createdAt: now.subtract(const Duration(days: 4)),
        energy: 3,
        emotions: const ['평온'],
        activities: const ['독서', '휴식'],
        note: '차분하게 보낸 하루.',
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
                    padding: const EdgeInsets.all(16),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: '오늘',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: '히스토리',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: '패턴',
          ),
        ],
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

class _Header extends StatelessWidget {
  const _Header({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Elegant premium brand mark
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryDark.withAlpha(140),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(45),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.waves_rounded, color: Colors.white, size: 26),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rhythm',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '매일 30초, 감정의 파도를 기록합니다.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
        // Refined reset action
        IconButton(
          tooltip: '데모 데이터 초기화',
          onPressed: onReset,
          icon: const Icon(Icons.refresh_rounded, size: 20),
          style: IconButton.styleFrom(
            foregroundColor: AppColors.textMuted,
            backgroundColor: AppColors.surfaceAlt,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Premium Energy Selector — elegant dot-based control
// ============================================================
class _EnergySelector extends StatelessWidget {
  const _EnergySelector({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  static const _labels = ['매우 낮음', '낮음', '보통', '높음', '매우 높음'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '에너지 레벨',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: 16),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$value / 5',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.3,
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
            final color = isSelected
                ? AppColors.primary
                : AppColors.borderStrong;

            return GestureDetector(
              onTap: () => onChanged(level),
              behavior: HitTestBehavior.opaque,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOutCubic,
                    width: AppRadii.energyDot,
                    height: AppRadii.energyDot,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color,
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(38),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$level',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _labels[index],
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textMuted,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

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
            children: [
              const Text(
                '오늘의 리듬',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 18),
              _EnergySelector(
                value: energy,
                onChanged: (v) => onEnergyChanged(v.toDouble()),
              ),
              const SizedBox(height: 10),
              _ChipSection(
                title: '감정 키워드',
                subtitle: '최대 3개',
                options: emotionOptions,
                selected: selectedEmotions,
                onToggle: onEmotionToggle,
              ),
              const SizedBox(height: 12),
              _ChipSection(
                title: '주요 활동',
                subtitle: '최대 3개',
                options: activityOptions,
                selected: selectedActivities,
                onToggle: onActivityToggle,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '짧은 메모',
                  hintText: '오늘의 리듬을 한 문장으로 남겨보세요.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.save),
                label: const Text('오늘의 리듬 저장'),
              ),
            ],
          ),
        );
        final canvas = _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Particle Canvas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.3),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _ParticleCanvas(
                    energy: energy,
                    emotions: selectedEmotions,
                    entry: previewEntry,
                    animation: animation,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '입력값이 색상, 파동, 입자의 흐름으로 표현됩니다.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );

        if (wide) {
          return Row(
            children: [
              Expanded(flex: 4, child: input),
              const SizedBox(width: 14),
              Expanded(flex: 5, child: canvas),
            ],
          );
        }
        return ListView(
          children: [
            SizedBox(height: 480, child: input),
            const SizedBox(height: 14),
            SizedBox(height: 420, child: canvas),
          ],
        );
      },
    );
  }
}

/// Hosts the long-lived `ParticleField` and drives it from the parent
/// `AnimationController`. The painter is recreated every tick, but the
/// field — and therefore particle state — survives across rebuilds.
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
    return AnimatedBuilder(
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
  });

  final String title;
  final String subtitle;
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final active = selected.contains(option);
            return FilterChip(
              label: Text(option),
              selected: active,
              onSelected: (_) => onToggle(option),
            );
          }).toList(),
        ),
      ],
    );
  }
}

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
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final eColor = emotionColor(entry.emotions);
                final dateStr =
                    '${entry.createdAt.month}월 ${entry.createdAt.day}일';

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Elegant energy badge
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: eColor.withAlpha(22),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: eColor.withAlpha(70),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${entry.energy}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
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
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    entry.emotions.join('  ·  '),
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: eColor,
                                      height: 1.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Activities
                            Text(
                              entry.activities.join('  ·  '),
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textMuted,
                                height: 1.35,
                              ),
                            ),
                            // Optional note
                            if (entry.note.isNotEmpty) ...[
                              const SizedBox(height: 7),
                              Text(
                                entry.note,
                                style: const TextStyle(
                                  fontSize: 13.2,
                                  color: AppColors.textPrimary,
                                  height: 1.35,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
      children: [
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '패턴 카드',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricCard(
                    icon: Icons.battery_charging_full,
                    label: '평균 에너지',
                    value: averageEnergy.toStringAsFixed(1),
                  ),
                  _MetricCard(
                    icon: Icons.palette_outlined,
                    label: '자주 나온 감정',
                    value: topEmotion,
                  ),
                  _MetricCard(
                    icon: Icons.directions_run,
                    label: '자주 한 활동',
                    value: topActivity,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                _insightText(averageEnergy, topEmotion, topActivity),
                style: const TextStyle(
                  fontSize: 16.5,
                  height: 1.55,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Panel(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '최근 7일 에너지 흐름',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 168,
                child: CustomPaint(
                  painter: WeeklyRhythmPainter(entries: entries),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _insightText(double averageEnergy, String emotion, String activity) {
    if (entries.length < 3) {
      return '아직 기록이 적습니다. 3일 이상 쌓이면 간단한 패턴 힌트를 보여줍니다.';
    }
    final tone = averageEnergy >= 3.5 ? '높은 편' : '낮은 편';
    return '최근 ${entries.length}개의 기록에서 평균 에너지는 $tone입니다. '
        '$emotion 감정과 $activity 활동이 자주 나타났습니다. '
        '최종 버전에서는 1주 단위 힌트와 관찰 노트로 확장할 예정입니다.';
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 19, color: AppColors.primary),
          ),
          const SizedBox(height: 13),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
              height: 1.05,
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppShadows.card,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

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

    // Rich atmospheric premium gradient (deep, emotional, luxurious)
    final background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0F1F22),
          Color.lerp(baseColor, const Color(0xFF0A1416), 0.55)!,
          Color.lerp(baseColor, const Color(0xFF1A2528), 0.35)!,
          const Color(0xFFEDE4D5),
        ],
        stops: const [0.0, 0.38, 0.62, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, background);

    // Very subtle vignette for depth
    final vignette = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.1, -0.2),
        radius: 1.15,
        colors: [Colors.transparent, Colors.black.withAlpha(45)],
        stops: const [0.6, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);

    final center = Offset(size.width * 0.5, size.height * 0.51);

    // Elegant concentric waves — more refined and emotional
    final wavePaint = Paint()
      ..color = Colors.white.withAlpha(92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (var ring = 0; ring < 5; ring++) {
      final phase = progress * pi * 2 + ring * 0.7;
      final radius = 38.0 + ring * 38 + sin(phase) * (7 + energy * 0.8);
      canvas.drawCircle(center, radius + energy * 2.2, wavePaint);
    }

    // Soft central emotional glow
    final glowPaint = Paint()
      ..color = baseColor.withAlpha(26 + (energy * 4))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32);
    canvas.drawCircle(center, 48 + energy * 4, glowPaint);

    // Premium particle field — fully owned by `Particle` objects.
    // The field advances physics here; the painter just commands draw.
    field.update(
      size: size,
      energy: energy.toDouble(),
      baseColor: baseColor,
      attractor: center,
      mode: mode,
    );
    field.draw(canvas);

    // Elegant status typography
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Energy $energy  ·  ${emotions.join('  /  ')}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 48);
    textPainter.paint(canvas, const Offset(22, 22));
  }

  @override
  bool shouldRepaint(covariant RhythmParticlePainter oldDelegate) {
    // The field mutates internally every frame, so we always repaint.
    // (The parent `AnimationController` is what gates the framerate.)
    return true;
  }
}

class WeeklyRhythmPainter extends CustomPainter {
  WeeklyRhythmPainter({required this.entries});

  final List<RhythmEntry> entries;

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = AppColors.borderStrong
      ..strokeWidth = 1.0;

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()..style = PaintingStyle.fill;
    final dotStroke = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Subtle elegant baseline
    canvas.drawLine(
      Offset(18, size.height - 26),
      Offset(size.width - 18, size.height - 26),
      axisPaint,
    );

    if (entries.isEmpty) return;

    final recent = entries.take(7).toList().reversed.toList();
    final path = Path();

    for (var i = 0; i < recent.length; i++) {
      final x = recent.length == 1
          ? size.width / 2
          : 18 + i * ((size.width - 36) / (recent.length - 1));
      final y = size.height - 26 - (recent[i].energy / 5) * (size.height - 52);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      final eColor = emotionColor(recent[i].emotions);

      // Premium dot with white ring
      dotPaint.color = eColor;
      canvas.drawCircle(Offset(x, y), 7.5, dotPaint);
      canvas.drawCircle(Offset(x, y), 7.5, dotStroke);
    }
    canvas.drawPath(path, linePaint);
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
