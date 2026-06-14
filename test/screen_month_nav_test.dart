import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm_archive/prototype/backup_file_service.dart';
import 'package:rhythm_archive/prototype/diary_controller.dart';
import 'package:rhythm_archive/prototype/diary_entry.dart';
import 'package:rhythm_archive/prototype/diary_repository.dart';
import 'package:rhythm_archive/prototype/screens/diary_screen.dart';
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

class FakeBackupFileService extends BackupFileService {
  const FakeBackupFileService(this.raw);

  final String raw;

  @override
  Future<String?> pickBackup() async => raw;
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
  testWidgets('한줄: 기록이 없으면 첫 기록 행동을 안내한다', (tester) async {
    final controller = await _loadedController();
    var started = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiaryScreen(
            controller: controller,
            onRecord: () => started = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('아직 남긴 한 줄이 없어요'), findsOneWidget);
    expect(find.text('이전 기록'), findsNothing);
    await tester.tap(find.text('오늘 기록 시작하기'));
    expect(started, isTrue);
  });

  testWidgets('감정잔디: 기록이 없으면 오늘 첫 색을 채울 수 있다', (tester) async {
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

    await tester.scrollUntilVisible(
      find.text('첫 번째 감정 색을 채워볼까요?'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.scrollUntilVisible(
      find.text('오늘 기록하기'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('오늘 기록하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('오늘 기록하기'));

    expect(recordedFor, isNotNull);
    expect(isSameDiaryDay(recordedFor!, DateTime.now()), isTrue);
  });

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
    final controller = await _loadedController([
      DiaryEntry(
        id: 'stats-entry',
        date: DateTime.now(),
        mood: DiaryMood.normal,
        keywords: const ['공부'],
        satisfaction: 3,
        summary: '통계를 위한 기록',
      ),
    ]);
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
    final controller = await _loadedController([
      DiaryEntry(
        id: 'period-entry',
        date: DateTime.now(),
        mood: DiaryMood.happy,
        keywords: const ['친구'],
        satisfaction: 5,
        summary: '기간 전환을 위한 기록',
      ),
    ]);
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

  testWidgets('통계: 데이터 관리에서 전체 기록을 확인 후 삭제한다', (tester) async {
    final controller = await _loadedController([
      DiaryEntry(
        id: 'data-entry',
        date: DateTime.now(),
        mood: DiaryMood.happy,
        keywords: const ['친구'],
        satisfaction: 5,
        summary: '친구와 웃은 하루',
      ),
    ]);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MyScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('내 데이터'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Drift · SQLite · 기록 1개'), findsOneWidget);
    expect(find.text('백업 파일 저장'), findsOneWidget);
    expect(find.text('백업 파일 복원'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('모든 기록 삭제'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('모든 기록 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('모든 기록 삭제'));
    await tester.pumpAndSettle();
    expect(find.text('모든 기록을 삭제할까요?'), findsOneWidget);

    await tester.tap(find.text('전체 삭제'));
    await tester.pumpAndSettle();

    expect(controller.entries, isEmpty);
    expect(find.text('Drift · SQLite · 기록 0개'), findsOneWidget);
    expect(find.text('첫 기록이 통계의 시작이에요'), findsOneWidget);
    expect(find.text('기분 비율'), findsNothing);
    expect(find.text('만족도 흐름'), findsNothing);
  });

  testWidgets('통계: 백업 복원 전 파일 내용을 미리 보여주고 취소할 수 있다', (tester) async {
    final controller = await _loadedController([
      DiaryEntry(
        id: 'current-entry',
        date: DateTime(2026, 6, 13),
        mood: DiaryMood.normal,
        keywords: const ['공부'],
        satisfaction: 3,
        summary: '현재 기록',
      ),
    ]);
    final backupSource = await _loadedController([
      DiaryEntry(
        id: 'backup-entry',
        date: DateTime(2026, 6, 14),
        mood: DiaryMood.happy,
        keywords: const ['친구'],
        satisfaction: 5,
        summary: '백업 기록',
      ),
    ]);
    await backupSource.addCustomKeyword('산책');
    final raw = backupSource.createBackupJson(
      exportedAt: DateTime(2026, 6, 14, 15),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyScreen(
            controller: controller,
            backupFileService: FakeBackupFileService(raw),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('백업 파일 복원'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('백업 파일 복원'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -120));
    await tester.pumpAndSettle();
    await tester.tap(find.text('백업 파일 복원'));
    await tester.pumpAndSettle();

    expect(find.text('백업을 복원할까요?'), findsOneWidget);
    expect(find.text('2026.06.14 15:00'), findsOneWidget);
    expect(find.text('현재 기록 1개 → 백업 기록 1개'), findsOneWidget);
    expect(find.text('사용자 키워드'), findsOneWidget);

    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(controller.entries.single.id, 'current-entry');
  });
}
