import 'package:flutter/material.dart';

/// 코지 페이퍼(따뜻한 일기장) 팔레트. 라이트/다크 두 벌을 ThemeExtension으로 제공해
/// 위젯에서 `context.colors.primary`처럼 토큰으로 색을 참조한다.
@immutable
class HarutalkColors extends ThemeExtension<HarutalkColors> {
  const HarutalkColors({
    required this.background,
    required this.surface,
    required this.surfaceSoft,
    required this.cream,
    required this.primary,
    required this.primaryDark,
    required this.primarySoft,
    required this.onPrimary,
    required this.accent,
    required this.accentSoft,
    required this.ink,
    required this.muted,
    required this.border,
    required this.shadow,
  });

  final Color background;
  final Color surface;
  final Color surfaceSoft;
  final Color cream;
  final Color primary;
  final Color primaryDark;
  final Color primarySoft;
  final Color onPrimary;
  final Color accent;
  final Color accentSoft;
  final Color ink;
  final Color muted;
  final Color border;
  final Color shadow;

  static const light = HarutalkColors(
    background: Color(0xFFFBF6EC),
    surface: Color(0xFFFFFDF7),
    surfaceSoft: Color(0xFFF1E9DA),
    cream: Color(0xFFF4EBD9),
    primary: Color(0xFF56886B),
    primaryDark: Color(0xFF3C6750),
    primarySoft: Color(0xFFE5EEE2),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFFCF8862),
    accentSoft: Color(0xFFF6E4D8),
    ink: Color(0xFF3A352E),
    muted: Color(0xFF8B8374),
    border: Color(0xFFE7DCC8),
    shadow: Color(0x12342A14),
  );

  static const dark = HarutalkColors(
    background: Color(0xFF201C17),
    surface: Color(0xFF2B2620),
    surfaceSoft: Color(0xFF353027),
    cream: Color(0xFF332C22),
    primary: Color(0xFF7FB092),
    primaryDark: Color(0xFFABCFB7),
    primarySoft: Color(0xFF2F3A31),
    onPrimary: Color(0xFF1B271F),
    accent: Color(0xFFE0A07E),
    accentSoft: Color(0xFF3E332B),
    ink: Color(0xFFEFE7D8),
    muted: Color(0xFFA89F8D),
    border: Color(0xFF3C362D),
    shadow: Color(0x55000000),
  );

  @override
  HarutalkColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSoft,
    Color? cream,
    Color? primary,
    Color? primaryDark,
    Color? primarySoft,
    Color? onPrimary,
    Color? accent,
    Color? accentSoft,
    Color? ink,
    Color? muted,
    Color? border,
    Color? shadow,
  }) {
    return HarutalkColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      cream: cream ?? this.cream,
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primarySoft: primarySoft ?? this.primarySoft,
      onPrimary: onPrimary ?? this.onPrimary,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  HarutalkColors lerp(ThemeExtension<HarutalkColors>? other, double t) {
    if (other is! HarutalkColors) return this;
    return HarutalkColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t)!,
      cream: Color.lerp(cream, other.cream, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension HarutalkColorsX on BuildContext {
  /// 현재 테마의 코지 페이퍼 팔레트.
  HarutalkColors get colors =>
      Theme.of(this).extension<HarutalkColors>() ?? HarutalkColors.light;
}

/// 앱 전역 테마 모드. 토글 버튼이 이 값을 바꾸면 MaterialApp이 다시 그린다.
final ValueNotifier<ThemeMode> harutalkThemeMode = ValueNotifier<ThemeMode>(
  ThemeMode.system,
);

ThemeData buildHarutalkTheme(Brightness brightness) {
  final palette = brightness == Brightness.dark
      ? HarutalkColors.dark
      : HarutalkColors.light;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: palette.background,
    extensions: [palette],
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: palette.primary,
          brightness: brightness,
        ).copyWith(
          surface: palette.surface,
          primary: palette.primary,
          onPrimary: palette.onPrimary,
        ),
    fontFamily: 'Segoe UI',
    fontFamilyFallback: const ['Noto Sans KR', 'Roboto'],
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: palette.ink,
        fontSize: 28,
        height: 1.2,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: TextStyle(
        color: palette.ink,
        fontSize: 22,
        height: 1.25,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: TextStyle(
        color: palette.ink,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: TextStyle(
        color: palette.ink,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(color: palette.ink, fontSize: 15, height: 1.55),
      bodyMedium: TextStyle(color: palette.muted, fontSize: 14, height: 1.5),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      elevation: 0,
      backgroundColor: palette.surface,
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? palette.primary
              : palette.muted,
          size: 22,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? palette.primaryDark
              : palette.muted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        backgroundColor: palette.primary,
        foregroundColor: palette.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.primaryDark,
        side: BorderSide(color: palette.border),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: palette.primaryDark),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 520),
      elevation: 8,
      shadowColor: palette.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: BorderSide(color: palette.border),
      ),
      iconColor: palette.primaryDark,
      titleTextStyle: TextStyle(
        color: palette.ink,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      contentTextStyle: TextStyle(
        color: palette.muted,
        fontSize: 14,
        height: 1.5,
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      actionsPadding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      headerBackgroundColor: palette.primary,
      headerForegroundColor: palette.onPrimary,
      weekdayStyle: TextStyle(
        color: palette.muted,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      dividerColor: palette.border,
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return palette.onPrimary;
        if (states.contains(WidgetState.disabled)) {
          return palette.muted.withValues(alpha: 0.4);
        }
        return palette.ink;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? palette.primary
            : Colors.transparent,
      ),
      todayForegroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? palette.onPrimary
            : palette.primaryDark,
      ),
      todayBackgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? palette.primary
            : Colors.transparent,
      ),
      todayBorder: BorderSide(color: palette.primary),
      yearForegroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? palette.onPrimary
            : palette.ink,
      ),
      yearBackgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? palette.primary
            : Colors.transparent,
      ),
    ),
    iconTheme: IconThemeData(color: palette.muted),
  );
}

/// 라이트/다크를 전환하는 작은 토글 버튼(통계 화면 헤더 등에서 사용).
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.colors;
    return IconButton(
      tooltip: isDark ? '라이트 모드' : '다크 모드',
      onPressed: () {
        harutalkThemeMode.value = isDark ? ThemeMode.light : ThemeMode.dark;
      },
      style: IconButton.styleFrom(
        backgroundColor: colors.surfaceSoft,
        foregroundColor: colors.primaryDark,
      ),
      icon: Icon(
        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        size: 20,
      ),
    );
  }
}
