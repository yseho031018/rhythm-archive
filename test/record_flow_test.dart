import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm_archive/prototype/diary_controller.dart';
import 'package:rhythm_archive/prototype/diary_entry.dart';
import 'package:rhythm_archive/prototype/diary_repository.dart';
import 'package:rhythm_archive/prototype/screens/record_screen.dart';

class MemoryDiaryRepository extends DiaryRepository {
  MemoryDiaryRepository([List<DiaryEntry>? entries])
    : stored = entries == null ? null : [...entries];

  List<DiaryEntry>? stored;
  List<String>? storedKeywords;

  @override
  Future<List<DiaryEntry>?> loadAll() async =>
      stored == null ? null : [...stored!];

  @override
  Future<void> saveAll(List<DiaryEntry> entries) async {
    stored = [...entries];
  }

  @override
  Future<void> saveKeywords(List<String> keywords) async {
    storedKeywords = [...keywords];
  }
}

void main() {
  testWidgets('기록 화면에서 하루톡 날짜 선택 팝업을 연다', (tester) async {
    final controller = DiaryController(
      repository: MemoryDiaryRepository([]),
      generationDelay: Duration.zero,
    );
    await controller.load();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordScreen(controller: controller, onOpenDiary: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('오늘 ·'));
    await tester.pumpAndSettle();

    expect(find.text('기록할 날짜를 골라주세요'), findsOneWidget);
    expect(find.text('이 날짜 선택'), findsOneWidget);
    expect(
      find.text('${DateTime.now().year}년 ${DateTime.now().month}월'),
      findsOneWidget,
    );

    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(find.text('기록할 날짜를 골라주세요'), findsNothing);
  });

  testWidgets('기록 화면의 최근 마음에서 감정잔디를 연다', (tester) async {
    final controller = DiaryController(
      repository: MemoryDiaryRepository([]),
      generationDelay: Duration.zero,
    );
    await controller.load();
    var openedMoodGrass = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordScreen(
            controller: controller,
            onOpenDiary: () {},
            onOpenMoodGrass: () => openedMoodGrass = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('감정잔디 보기'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('감정잔디 보기'));

    expect(openedMoodGrass, isTrue);
  });

  testWidgets('처음으로 버튼은 작성 중 선택을 모두 초기화한다', (tester) async {
    final controller = DiaryController(
      repository: MemoryDiaryRepository([]),
      generationDelay: Duration.zero,
    );
    await controller.load();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordScreen(controller: controller, onOpenDiary: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('행복'));
    await tester.pumpAndSettle();
    expect(controller.selectedMood, DiaryMood.happy);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(controller.selectedMood, isNull);
    expect(controller.selectedKeywords, isEmpty);
    expect(find.text('기분을 골라줘'), findsOneWidget);
    expect(find.text('보통으로 넘기기'), findsOneWidget);
  });

  testWidgets('이전 질문으로 돌아가도 선택한 답변을 유지한다', (tester) async {
    final controller = DiaryController(
      repository: MemoryDiaryRepository([]),
      generationDelay: Duration.zero,
    );
    await controller.load();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordScreen(controller: controller, onOpenDiary: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('행복'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('공부'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.text('오늘 하루에 몇 점을 줄래?'), findsOneWidget);
    expect(find.byTooltip('이전 질문'), findsOneWidget);

    await tester.tap(find.byTooltip('이전 질문'));
    await tester.pumpAndSettle();
    expect(find.text('무엇과 함께한 하루였어?'), findsOneWidget);
    expect(controller.selectedKeywords, contains('공부'));

    await tester.tap(find.byTooltip('이전 질문'));
    await tester.pumpAndSettle();
    expect(find.text('오늘 기분은 어땠어?'), findsOneWidget);
    expect(controller.selectedMood, DiaryMood.happy);
    expect(find.byTooltip('이전 질문'), findsNothing);
  });

  testWidgets('기록 플로우: 기분→키워드→토리 한 줄→전체화면→저장', (tester) async {
    final controller = DiaryController(
      repository: MemoryDiaryRepository([]),
      generationDelay: Duration.zero,
    );
    await controller.load();

    var openedDiary = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordScreen(
            controller: controller,
            onOpenDiary: () => openedDiary = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('토리의 한마디'), findsOneWidget);
    expect(find.text('기분을 골라줘'), findsOneWidget);

    // STEP 1: 기분 선택 → 다음
    await tester.tap(find.text('행복'));
    await tester.pumpAndSettle();
    expect(find.text('토리가 기억한 오늘'), findsOneWidget);
    expect(find.textContaining('행복한 하루였구나'), findsOneWidget);
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    // STEP 2: '직접 입력'이 하단 바가 아니라 키워드 그리드의 타일로 존재한다.
    expect(find.text('직접 입력'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '직접 입력'), findsNothing);
    // 키워드 선택 → 다음
    await tester.tap(find.text('공부'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    // STEP 3: 점수는 기본값(3) → 토리 한 줄 만들기
    await tester.tap(find.text('토리 한 줄 만들기'));
    await tester.pumpAndSettle();

    // STEP 4: 전체화면 결과 — 핵심 요소가 보여야 한다.
    expect(find.text('오늘의 한 줄'), findsOneWidget);
    // 글씨/마스코트가 커지며 입력 요약이 리스트 하단에 있어 스크롤해서 확인한다.
    await tester.scrollUntilVisible(
      find.text('토리가 들은 오늘'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('토리가 들은 오늘'), findsOneWidget);
    expect(find.text('저장하기'), findsOneWidget);
    expect(find.text('수정하기'), findsOneWidget);
    // 토리 안심 멘트
    expect(find.textContaining('수정해도 괜찮아'), findsOneWidget);
    // 모바일 폭(560)으로 제약 — 와이드 화면에서 전체 폭으로 퍼지지 않는다.
    expect(
      find.byWidgetPredicate(
        (w) => w is ConstrainedBox && w.constraints.maxWidth == 560,
      ),
      findsOneWidget,
    );

    // 저장 → 전체화면이 닫히고 onOpenDiary 콜백이 호출된다.
    await tester.tap(find.text('저장하기'));
    await tester.pumpAndSettle();

    expect(openedDiary, isTrue);
    expect(controller.entries, hasLength(1));
    expect(find.text('오늘의 한 줄'), findsNothing); // 전체화면 닫힘
  });

  testWidgets('토리 한 줄 만들기: 생성 중 "생각 중" 버퍼링 화면을 거쳐 결과로 간다', (
    tester,
  ) async {
    final controller = DiaryController(
      repository: MemoryDiaryRepository([]),
      generationDelay: const Duration(milliseconds: 1900),
    );
    await controller.load();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordScreen(controller: controller, onOpenDiary: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 기분 → 키워드 → 점수(기본값)
    await tester.tap(find.text('행복'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('공부'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    // 토리 한 줄 만들기 → 버퍼링 화면 진입 (반복 애니메이션이 있어 pumpAndSettle 대신 명시적 pump)
    await tester.tap(find.text('토리 한 줄 만들기'));
    await tester.pump(); // _generate가 라우트를 push
    await tester.pump(const Duration(milliseconds: 400)); // 라우트 전환 + 첫 프레임

    // 아직 결과는 없고, 토리가 "생각 중"인 버퍼링 화면이 보여야 한다.
    expect(controller.generating, isTrue);
    expect(find.text('토리가 한 줄을 쓰고 있어요'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('오늘의 한 줄'), findsNothing);

    // 지연이 끝나면 결과 화면으로 전환된다.
    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pump(const Duration(milliseconds: 400)); // pop + push 전환
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('토리가 한 줄을 쓰고 있어요'), findsNothing);
    expect(find.text('오늘의 한 줄'), findsOneWidget);
    expect(controller.generating, isFalse);
  });

  testWidgets('직접 입력한 키워드가 그리드 타일로 추가된다', (tester) async {
    final repository = MemoryDiaryRepository([]);
    final controller = DiaryController(
      repository: repository,
      generationDelay: Duration.zero,
    );
    await controller.load();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordScreen(controller: controller, onOpenDiary: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 기분 선택 → 키워드 단계로 이동
    await tester.tap(find.text('행복'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    // '직접 입력' 타일 → 다이얼로그에 키워드 입력 → 추가
    await tester.drag(find.byType(ListView).first, const Offset(0, -180));
    await tester.pumpAndSettle();
    await tester.tap(find.text('직접 입력'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '산책');
    await tester.tap(find.text('추가'));
    await tester.pumpAndSettle();

    // 새 키워드가 그리드 타일로 나타나고, 저장소에도 남는다.
    expect(find.text('산책'), findsOneWidget);
    expect(controller.customKeywords, contains('산책'));
    expect(repository.storedKeywords, contains('산책'));
  });
}
