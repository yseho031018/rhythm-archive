import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm_archive/prototype/diary_controller.dart';
import 'package:rhythm_archive/prototype/diary_entry.dart';
import 'package:rhythm_archive/prototype/diary_repository.dart';
import 'package:rhythm_archive/prototype/screens/record_screen.dart';

class MemoryDiaryRepository implements DiaryRepository {
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

void main() {
  testWidgets('기록 플로우: 기분→키워드→AI생성→전체화면→저장', (tester) async {
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

    // STEP 1: 기분 선택 → 다음
    await tester.tap(find.text('행복'));
    await tester.pumpAndSettle();
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

    // STEP 3: 점수는 기본값(3) → AI 한 줄 만들기
    await tester.tap(find.text('AI 한 줄 만들기'));
    await tester.pumpAndSettle();

    // STEP 4: 전체화면 결과 — 핵심 요소가 보여야 한다.
    expect(find.text('오늘의 한 줄'), findsOneWidget);
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
}
