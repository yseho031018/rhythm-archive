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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: harutalkThemeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: '하루톡',
          debugShowCheckedModeBanner: false,
          theme: buildHarutalkTheme(Brightness.light),
          darkTheme: buildHarutalkTheme(Brightness.dark),
          themeMode: mode,
          home: const AiDiaryShell(),
        );
      },
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
      DiaryScreen(
        controller: _controller,
        onRecord: () => setState(() => _index = 0),
      ),
      MoodGrassScreen(
        controller: _controller,
        onRecord: (date) {
          _controller.startRecord(date: date);
          setState(() => _index = 0);
        },
        onOpenEntry: (entryId) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  DiaryDetailScreen(controller: _controller, entryId: entryId),
            ),
          );
        },
      ),
      MyScreen(
        controller: _controller,
        onRecord: () => setState(() => _index = 0),
      ),
    ];

    final colors = context.colors;
    return Scaffold(
      body: ColoredBox(
        color: colors.surfaceSoft,
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
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(top: BorderSide(color: colors.border)),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow,
                  blurRadius: 16,
                  offset: const Offset(0, -4),
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
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart_rounded),
                  label: '통계',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
