import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm_archive/prototype/diary_controller.dart';
import 'package:rhythm_archive/prototype/diary_entry.dart';
import 'package:rhythm_archive/prototype/diary_repository.dart';
import 'package:rhythm_archive/prototype/screens/mood_grass_screen.dart';
import 'package:rhythm_archive/prototype/screens/my_screen.dart';

class MemoryDiaryRepository extends DiaryRepository {
  MemoryDiaryRepository([List<DiaryEntry>? entries])
    : stored = entries == null ? null : [...entries];

  List<DiaryEntry>? stored;

  @override
  Future<List<DiaryEntry>?> loadAll() async =>
      stored == null ? null : [...stored!];

  @override
  Future<void> saveAll(List<DiaryEntry> entries) async {
    stored = [...entries];
  }
}

Future<DiaryController> _loadedController([List<DiaryEntry>? entries]) async {
  final controller = DiaryController(
    repository: MemoryDiaryRepository(entries ?? []),
    generationDelay: Duration.zero,
  );
  await controller.load();
  return controller;
}

void main() {
  testWidgets('감정잔디: 이전 달 화살표로 월이 바뀐다', (tester) async {
    final controller = await _loadedController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MoodGrassScreen(
            controller: controller,
            onRecord: (_) {},
            onOpenEntry: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final now = DateTime.now();
    expect(find.text('${now.year}년 ${now.month}월'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();

    final prev = DateTime(now.year, now.month - 1);
    expect(find.text('${prev.year}년 ${prev.month}월'), findsOneWidget);
  });

  testWidgets('감정잔디: 빈 날짜에서 "이 날 기록하기"가 그 날짜로 콜백한다', (tester) async {
    final controller = await _loadedController();
    DateTime? recordedFor;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MoodGrassScreen(
            controller: controller,
            onRecord: (date) => recordedFor = date,
            onOpenEntry: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 기록이 없는 1일을 누르면 빈 날짜 카드가 뜬다.
    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('이 날 기록하기'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('이 날 기록하기'));
    await tester.pumpAndSettle();

    final now = DateTime.now();
    expect(recordedFor, DateTime(now.year, now.month, 1));
  });

  testWidgets('감정잔디: 기록이 있는 날짜에서 상세 기록을 연다', (tester) async {
    final now = DateTime.now();
    final entry = DiaryEntry(
      id: 'grass-entry',
      date: DateTime(now.year, now.month, 1),
      mood: DiaryMood.happy,
      keywords: const ['친구'],
      satisfaction: 5,
      summary: '친구와 웃으며 보낸 하루',
    );
    final controller = await _loadedController([entry]);
    String? openedEntryId;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MoodGrassScreen(
            controller: controller,
            onRecord: (_) {},
            onOpenEntry: (entryId) => openedEntryId = entryId,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('기록 보기'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('기록 보기'));
    await tester.pumpAndSettle();

    expect(openedEntryId, entry.id);
  });

  testWidgets('통계: 타이틀/생활 패턴 섹션 + 이전 달 이동', (tester) async {
    final controller = await _loadedController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MyScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    // 목업 워딩 반영 — 타이틀은 상단에 보인다.
    expect(find.text('통계'), findsOneWidget);

    final now = DateTime.now();
    expect(find.text('${now.year}년 ${now.month}월'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();

    final prev = DateTime(now.year, now.month - 1);
    expect(find.text('${prev.year}년 ${prev.month}월'), findsOneWidget);

    // 생활 패턴 섹션은 리스트 하단 → 스크롤해서 확인.
    await tester.scrollUntilVisible(
      find.text('생활 패턴'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('생활 패턴'), findsOneWidget);
  });

  testWidgets('통계: 주간/월간/연간 토글로 집계 기간이 바뀐다', (tester) async {
    final controller = await _loadedController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MyScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    final now = DateTime.now();
    // 기본: 월간
    expect(find.text('이번 달 기록'), findsOneWidget);
    expect(find.text('${now.year}년 ${now.month}월'), findsOneWidget);

    // 연간
    await tester.tap(find.text('연간'));
    await tester.pumpAndSettle();
    expect(find.text('올해 기록'), findsOneWidget);
    expect(find.text('${now.year}년'), findsOneWidget);

    // 주간
    await tester.tap(find.text('주간'));
    await tester.pumpAndSettle();
    expect(find.text('주간 기록'), findsOneWidget);
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(monday.year, monday.month, monday.day);
    final last = start.add(const Duration(days: 6));
    expect(
      find.text('${start.month}월 ${start.day}일 ~ ${last.month}월 ${last.day}일'),
      findsOneWidget,
    );
  });
}
