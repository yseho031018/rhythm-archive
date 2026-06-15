import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm_archive/prototype/diary_controller.dart';
import 'package:rhythm_archive/prototype/diary_entry.dart';
import 'package:rhythm_archive/prototype/diary_repository.dart';
import 'package:rhythm_archive/prototype/shared_preferences_diary_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryDiaryRepository extends DiaryRepository {
  MemoryDiaryRepository([List<DiaryEntry>? entries])
    : stored = entries == null ? null : [...entries];

  List<DiaryEntry>? stored;
  List<String>? storedKeywords;

  @override
  Future<List<DiaryEntry>?> loadAll() async {
    return stored == null ? null : [...stored!];
  }

  @override
  Future<void> saveAll(List<DiaryEntry> entries) async {
    stored = [...entries];
  }

  @override
  Future<List<String>?> loadKeywords() async {
    return storedKeywords == null ? null : [...storedKeywords!];
  }

  @override
  Future<void> saveKeywords(List<String> keywords) async {
    storedKeywords = [...keywords];
  }
}

class FailingDiaryRepository extends DiaryRepository {
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

    test('기존 프로토타입 기록은 연간 감정잔디용 데이터로 보강한다', () async {
      final existingEntry = DiaryEntry(
        id: 'existing-entry',
        date: DateTime(DateTime.now().year, DateTime.now().month, 1),
        mood: DiaryMood.happy,
        keywords: const ['친구'],
        satisfaction: 5,
        summary: '기존 사용자 기록',
      );
      final repository = MemoryDiaryRepository([existingEntry]);
      final controller = DiaryController(
        repository: repository,
        seedSampleHistory: true,
        generationDelay: Duration.zero,
      );

      await controller.load();

      expect(controller.entries.length, greaterThan(20));
      expect(
        controller.entries.where(
          (entry) => entry.date.month < DateTime.now().month,
        ),
        isNotEmpty,
      );
      expect(
        controller.entries.any((entry) => entry.id == existingEntry.id),
        isTrue,
      );
      expect(repository.stored, hasLength(controller.entries.length));
      expect(
        controller.entries.where(
          (entry) => !entry.date.isBefore(DateTime.now()),
        ),
        isEmpty,
      );
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

    test('과거 날짜로 기록을 시작하면 그 날짜로 저장된다', () async {
      final repository = MemoryDiaryRepository([]);
      final controller = DiaryController(
        repository: repository,
        generationDelay: Duration.zero,
      );
      await controller.load();

      final pastDay = DateTime(2026, 6, 3, 14, 30);
      controller.startRecord(date: pastDay);

      // startRecord는 선택값을 비우고 날짜만 정한다(시각은 버린다).
      expect(controller.selectedMood, isNull);
      expect(controller.selectedKeywords, isEmpty);
      expect(controller.recordDate, DateTime(2026, 6, 3));

      controller.selectMood(DiaryMood.happy);
      controller.toggleKeyword('운동');
      final preview = await controller.generatePreview();

      expect(preview!.date, DateTime(2026, 6, 3));

      await controller.saveEntry(preview);
      expect(controller.entryForDay(DateTime(2026, 6, 3)), isNotNull);
      // 저장 후에는 작성 날짜가 오늘로 돌아온다.
      final now = DateTime.now();
      expect(controller.recordDate, DateTime(now.year, now.month, now.day));
    });

    test('같은 과거 날짜에 다시 기록하면 기존 기록을 덮어쓴다', () async {
      final controller = DiaryController(
        repository: MemoryDiaryRepository([]),
        generationDelay: Duration.zero,
      );
      await controller.load();
      final day = DateTime(2026, 6, 5);

      controller.startRecord(date: day);
      controller.selectMood(DiaryMood.sad);
      controller.toggleKeyword('공부');
      await controller.saveEntry((await controller.generatePreview())!);

      controller.startRecord(date: day);
      controller.selectMood(DiaryMood.happy);
      controller.toggleKeyword('친구');
      await controller.saveEntry((await controller.generatePreview())!);

      final onDay = controller.entries
          .where((entry) => entry.date == day)
          .toList();
      expect(onDay, hasLength(1));
      expect(onDay.single.mood, DiaryMood.happy);
    });

    test('직접 입력한 키워드는 저장되고 선택 상태가 된다', () async {
      final repository = MemoryDiaryRepository([]);
      final controller = DiaryController(
        repository: repository,
        generationDelay: Duration.zero,
      );
      await controller.load();

      await controller.addCustomKeyword(' 산책 ');

      expect(controller.customKeywords, ['산책']);
      expect(controller.selectedKeywords, contains('산책'));
      expect(controller.allKeywords, contains('산책'));
      expect(repository.storedKeywords, ['산책']);
    });

    test('저장된 사용자 키워드는 다시 불러온 뒤에도 남는다', () async {
      final repository = MemoryDiaryRepository([]);
      final first = DiaryController(
        repository: repository,
        generationDelay: Duration.zero,
      );
      await first.load();
      await first.addCustomKeyword('산책');

      final second = DiaryController(
        repository: repository,
        generationDelay: Duration.zero,
      );
      await second.load();

      expect(second.customKeywords, contains('산책'));
      // 다시 불러왔을 때는 선택되어 있지 않다(목록에만 남는다).
      expect(second.selectedKeywords, isEmpty);
    });

    test('기본 키워드를 직접 입력하면 중복 추가 없이 선택만 된다', () async {
      final controller = DiaryController(
        repository: MemoryDiaryRepository([]),
        generationDelay: Duration.zero,
      );
      await controller.load();

      await controller.addCustomKeyword('공부');

      expect(controller.customKeywords, isEmpty);
      expect(controller.selectedKeywords, contains('공부'));
    });

    test('사용자 키워드를 삭제하면 목록·선택·저장소에서 빠진다', () async {
      final repository = MemoryDiaryRepository([]);
      final controller = DiaryController(
        repository: repository,
        generationDelay: Duration.zero,
      );
      await controller.load();
      await controller.addCustomKeyword('산책');

      await controller.removeCustomKeyword('산책');

      expect(controller.customKeywords, isEmpty);
      expect(controller.selectedKeywords, isNot(contains('산책')));
      expect(repository.storedKeywords, isEmpty);
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

    test('백업 JSON은 기록과 사용자 키워드를 다른 저장소에 복원한다', () async {
      final source = DiaryController(
        repository: MemoryDiaryRepository([]),
        generationDelay: Duration.zero,
      );
      await source.load();
      await source.addCustomKeyword('산책');
      await source.saveEntry(
        DiaryEntry(
          id: 'backup-entry',
          date: DateTime(2026, 6, 14),
          mood: DiaryMood.happy,
          keywords: const ['산책'],
          satisfaction: 5,
          summary: '산책하며 기분을 환기한 하루',
        ),
      );

      final backup = source.createBackupJson(
        exportedAt: DateTime(2026, 6, 14, 15),
      );
      final targetRepository = MemoryDiaryRepository([]);
      final target = DiaryController(
        repository: targetRepository,
        generationDelay: Duration.zero,
      );
      await target.load();

      final result = await target.restoreBackupJson(backup);

      expect(result.success, isTrue);
      expect(result.restoredCount, 1);
      expect(target.entries.single.id, 'backup-entry');
      expect(target.customKeywords, ['산책']);
      expect(targetRepository.stored!.single.summary, '산책하며 기분을 환기한 하루');
      expect(targetRepository.storedKeywords, ['산책']);
    });

    test('백업 미리보기는 생성 날짜와 기록 범위를 저장 전에 알려준다', () async {
      final controller = DiaryController(
        repository: MemoryDiaryRepository([]),
        generationDelay: Duration.zero,
      );
      await controller.load();
      await controller.addCustomKeyword('산책');
      await controller.saveEntry(
        DiaryEntry(
          id: 'preview-first',
          date: DateTime(2026, 6, 10),
          mood: DiaryMood.normal,
          keywords: const ['공부'],
          satisfaction: 3,
          summary: '공부 흐름을 지킨 하루',
        ),
      );
      await controller.saveEntry(
        DiaryEntry(
          id: 'preview-last',
          date: DateTime(2026, 6, 14),
          mood: DiaryMood.happy,
          keywords: const ['산책'],
          satisfaction: 5,
          summary: '산책하며 웃은 하루',
        ),
      );

      final preview = controller.inspectBackupJson(
        controller.createBackupJson(exportedAt: DateTime(2026, 6, 14, 15)),
      );

      expect(preview.exportedAt, DateTime(2026, 6, 14, 15));
      expect(preview.entryCount, 2);
      expect(preview.keywordCount, 1);
      expect(preview.earliestEntry, DateTime(2026, 6, 10));
      expect(preview.latestEntry, DateTime(2026, 6, 14));
    });

    test('잘못된 백업은 현재 기록을 변경하지 않는다', () async {
      final repository = MemoryDiaryRepository([
        DiaryEntry(
          id: 'existing',
          date: DateTime(2026, 6, 14),
          mood: DiaryMood.normal,
          keywords: const ['공부'],
          satisfaction: 3,
          summary: '기존 기록',
        ),
      ]);
      final controller = DiaryController(
        repository: repository,
        generationDelay: Duration.zero,
      );
      await controller.load();

      final result = await controller.restoreBackupJson('{"app":"other"}');

      expect(result.success, isFalse);
      expect(controller.entries.single.id, 'existing');
      expect(repository.stored!.single.id, 'existing');
    });

    test('잘못된 백업은 미리보기에서도 거부한다', () {
      final controller = DiaryController(
        repository: MemoryDiaryRepository([]),
        generationDelay: Duration.zero,
      );

      expect(
        () => controller.inspectBackupJson('{"app":"other"}'),
        throwsA(isA<FormatException>()),
      );
    });

    test('형식이 깨진 기록이 포함된 백업도 현재 기록을 변경하지 않는다', () async {
      final repository = MemoryDiaryRepository([
        DiaryEntry(
          id: 'existing',
          date: DateTime(2026, 6, 14),
          mood: DiaryMood.normal,
          keywords: const ['공부'],
          satisfaction: 3,
          summary: '기존 기록',
        ),
      ]);
      final controller = DiaryController(
        repository: repository,
        generationDelay: Duration.zero,
      );
      await controller.load();

      final result = await controller.restoreBackupJson('''
        {
          "app": "harutalk",
          "version": 1,
          "entries": [{"id": 123}],
          "customKeywords": []
        }
      ''');

      expect(result.success, isFalse);
      expect(result.message, '올바른 하루톡 백업 파일이 아니에요.');
      expect(controller.entries.single.id, 'existing');
      expect(repository.stored!.single.id, 'existing');
      expect(controller.storageError, isNull);
    });

    test('전체 데이터 삭제는 기록과 사용자 키워드를 함께 비운다', () async {
      final repository = MemoryDiaryRepository([
        DiaryEntry(
          id: 'delete-me',
          date: DateTime(2026, 6, 14),
          mood: DiaryMood.tired,
          keywords: const ['과제'],
          satisfaction: 2,
          summary: '삭제할 기록',
        ),
      ])..storedKeywords = ['발표'];
      final controller = DiaryController(
        repository: repository,
        generationDelay: Duration.zero,
      );
      await controller.load();

      final cleared = await controller.clearAllData();

      expect(cleared, isTrue);
      expect(controller.entries, isEmpty);
      expect(controller.customKeywords, isEmpty);
      expect(repository.stored, isEmpty);
      expect(repository.storedKeywords, isEmpty);
    });
  });
}
