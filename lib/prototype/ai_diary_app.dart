import 'package:flutter/material.dart';

import 'diary_controller.dart';
import 'screens/diary_screen.dart';
import 'screens/mood_grass_screen.dart';
import 'screens/my_screen.dart';
import 'screens/record_screen.dart';
import 'widgets/harutalk_ui.dart';

class AiDiaryApp extends StatelessWidget {
  const AiDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '하루톡',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: HarutalkColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: HarutalkColors.primary,
          brightness: Brightness.light,
          surface: Colors.white,
        ),
        fontFamily: 'Segoe UI',
        fontFamilyFallback: const ['Noto Sans KR', 'Roboto'],
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: HarutalkColors.ink,
            fontSize: 28,
            height: 1.2,
            fontWeight: FontWeight.w800,
          ),
          headlineMedium: TextStyle(
            color: HarutalkColors.ink,
            fontSize: 22,
            height: 1.25,
            fontWeight: FontWeight.w800,
          ),
          titleLarge: TextStyle(
            color: HarutalkColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
          titleMedium: TextStyle(
            color: HarutalkColors.ink,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: TextStyle(
            color: HarutalkColors.ink,
            fontSize: 15,
            height: 1.55,
          ),
          bodyMedium: TextStyle(
            color: HarutalkColors.muted,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          height: 68,
          elevation: 0,
          backgroundColor: HarutalkColors.surface,
          indicatorColor: Colors.transparent,
          iconTheme: WidgetStatePropertyAll(
            IconThemeData(color: HarutalkColors.muted, size: 22),
          ),
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(
              color: HarutalkColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            backgroundColor: HarutalkColors.primary,
            foregroundColor: Colors.white,
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
      home: const AiDiaryShell(),
    );
  }
}

class AiDiaryShell extends StatefulWidget {
  const AiDiaryShell({super.key});

  @override
  State<AiDiaryShell> createState() => _AiDiaryShellState();
}

class _AiDiaryShellState extends State<AiDiaryShell> {
  late final DiaryController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = DiaryController();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    await _controller.load();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = [
      RecordScreen(
        controller: _controller,
        onOpenDiary: () => setState(() => _index = 1),
      ),
      DiaryScreen(controller: _controller),
      MoodGrassScreen(controller: _controller),
      MyScreen(controller: _controller),
    ];

    return Scaffold(
      body: ColoredBox(
        color: const Color(0xFFF0F4F1),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: pages[_index],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: HarutalkColors.surface,
              border: Border(top: BorderSide(color: HarutalkColors.border)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0F52675A),
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (index) => setState(() => _index = index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.edit_note_outlined),
                  selectedIcon: Icon(Icons.edit_note),
                  label: '기록',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book),
                  label: '한줄',
                ),
                NavigationDestination(
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(Icons.grid_view_rounded),
                  label: '감정잔디',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: '마이',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
