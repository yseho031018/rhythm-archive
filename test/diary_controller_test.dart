import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm_archive/prototype/diary_controller.dart';
import 'package:rhythm_archive/prototype/diary_entry.dart';
import 'package:rhythm_archive/prototype/diary_repository.dart';
import 'package:rhythm_archive/prototype/shared_preferences_diary_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryDiaryRepository implements DiaryRepository {
  MemoryDiaryRepository([List<DiaryEntry>? entries])
    : stored = entries == null ? null : [...entries];

  List<DiaryEntry>? stored;

  @override
  Future<List<DiaryEntry>?> loadAll() async {
    return stored == null ? null : [...stored!];
  }

  @override
  Future<void> saveAll(List<DiaryEntry> entries) async {
    stored = [...entries];
  }
}

class FailingDiaryRepository implements DiaryRepository {
  @override
  Future<List<DiaryEntry>?> loadAll() async => [];

  @override
  Future<void> saveAll(List<DiaryEntry> entries) {
    throw StateError('save failed');
  }
}

void main() {
  group('DiaryEntry', () {
    test('JSON 변환 후에도 모든 값이 유지된다', () {
      final entry = DiaryEntry(
        id: 'entry-1',
        date: DateTime(2026, 6, 10),
        mood: DiaryMood.happy,
        keywords: const ['공부', '카페'],
        satisfaction: 4,
        summary: '오늘의 한 줄',
      );

      final restored = DiaryEntry.fromJson(entry.toJson());

      expect(restored.id, entry.id);
      expect(restored.date, entry.date);
      expect(restored.mood, entry.mood);
      expect(restored.keywords, entry.keywords);
      expect(restored.satisfaction, entry.satisfaction);
      expect(restored.summary, entry.summary);
    });
  });

  group('SharedPreferencesDiaryRepository', () {
    test('저장한 한 줄 기록을 다시 불러온다', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = SharedPreferencesDiaryRepository(
        storageKey: 'harutalk_test_entries',
      );
      final entry = DiaryEntry(
        id: 'saved-entry',
        date: DateTime(2026, 6, 10),
        mood: DiaryMood.normal,
        keywords: const ['공부'],
        satisfaction: 3,
        summary: '저장된 오늘의 한 줄',
      );

      expect(await repository.loadAll(), isNull);
      await repository.saveAll([entry]);
      final restored = await repository.loadAll();

      expect(restored, hasLength(1));
      expect(restored!.single.summary, entry.summary);
      expect(restored.single.mood, entry.mood);
    });
  });

  group('DiaryController', () {
    test('첫 실행에는 샘플 기록을 저장하고 불러온다', () async {
      final repository = MemoryDiaryRepository();
      final controller = DiaryController(
        repository: repository,
        generationDelay: Duration.zero,
      );

      await controller.load();

      expect(controller.loaded, isTrue);
      expect(controller.entries, isNotEmpty);
      expect(repository.stored, isNotEmpty);
      expect(controller.entries.every((entry) => entry.isSample), isTrue);
    });

    test('기분과 키워드를 선택하면 미리보기만 생성한다', () async {
      final repository = MemoryDiaryRepository([]);
      final controller = DiaryController(
        repository: repository,
        generationDelay: Duration.zero,
      );
      await controller.load();

      controller.selectMood(DiaryMood.happy);
      controller.toggleKeyword('공부');
      controller.setSatisfaction(4);

      final entry = await controller.generatePreview();

      expect(entry, isNotNull);
      expect(entry!.summary, contains('공부'));
      expect(controller.entries, isEmpty);
      expect(controller.canGenerate, isTrue);
    });

    test('저장·수정·삭제가 저장소와 함께 반영된다', () async {
      final repository = MemoryDiaryRepository([]);
      final controller = DiaryController(
        repository: repository,
        generationDelay: Duration.zero,
      );
      await controller.load();
      controller.selectMood(DiaryMood.normal);
      controller.toggleKeyword('친구');

      final preview = await controller.generatePreview();
      await controller.saveEntry(preview!);
      expect(controller.entries, hasLength(1));
      expect(repository.stored, hasLength(1));

      await controller.updateSummary(preview.id, '직접 수정한 한 줄');
      expect(controller.entries.single.summary, '직접 수정한 한 줄');
      expect(repository.stored!.single.summary, '직접 수정한 한 줄');

      await controller.deleteEntry(preview.id);
      expect(controller.entries, isEmpty);
      expect(repository.stored, isEmpty);
    });

    test('같은 날짜의 기록을 저장하면 기존 기록을 교체한다', () async {
      final repository = MemoryDiaryRepository([]);
      final controller = DiaryController(
        repository: repository,
        generationDelay: Duration.zero,
      );
      await controller.load();

      final first = DiaryEntry(
        id: 'first',
        date: DateTime.now(),
        mood: DiaryMood.normal,
        keywords: const ['친구'],
        satisfaction: 3,
        summary: '첫 기록',
      );
      final second = first.copyWith(
        id: 'second',
        mood: DiaryMood.tired,
        summary: '교체된 기록',
      );

      await controller.saveEntry(first);
      await controller.saveEntry(second);

      expect(controller.entries, hasLength(1));
      expect(controller.entries.single.id, 'second');
      expect(repository.stored, hasLength(1));
    });

    test('다시 생성하면 선택 정보는 유지하고 한 줄만 달라진다', () async {
      final controller = DiaryController(
        repository: MemoryDiaryRepository([]),
        generationDelay: Duration.zero,
      );
      await controller.load();
      controller.selectMood(DiaryMood.happy);
      controller.toggleKeyword('운동');

      final first = await controller.generatePreview();
      final second = await controller.regeneratePreview(first!);

      expect(second.mood, first.mood);
      expect(second.keywords, first.keywords);
      expect(second.summary, isNot(first.summary));
    });

    test('저장 실패가 발생해도 앱 상태를 유지하고 오류를 알린다', () async {
      final controller = DiaryController(
        repository: FailingDiaryRepository(),
        generationDelay: Duration.zero,
      );
      await controller.load();
      final entry = DiaryEntry(
        id: 'failed-entry',
        date: DateTime.now(),
        mood: DiaryMood.normal,
        keywords: const ['공부'],
        satisfaction: 3,
        summary: '저장에 실패할 기록',
      );

      final saved = await controller.saveEntry(entry);

      expect(saved, isFalse);
      expect(controller.entryById(entry.id), isNotNull);
      expect(controller.storageError, isNotNull);
    });
  });
}
