import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm_archive/prototype/database/harutalk_database.dart';
import 'package:rhythm_archive/prototype/diary_entry.dart';
import 'package:rhythm_archive/prototype/drift_diary_repository.dart';
import 'package:rhythm_archive/prototype/migrating_diary_repository.dart';
import 'package:rhythm_archive/prototype/shared_preferences_diary_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late HarutalkDatabase database;
  late DriftDiaryRepository repository;

  setUp(() {
    database = HarutalkDatabase(NativeDatabase.memory());
    repository = DriftDiaryRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('Drift 저장소는 기록과 사용자 키워드를 구조화해 보존한다', () async {
    final entry = DiaryEntry(
      id: 'drift-entry',
      date: DateTime(2026, 6, 14),
      mood: DiaryMood.happy,
      keywords: const ['공부', '산책'],
      satisfaction: 4,
      summary: '집중한 뒤 산책으로 기분을 환기한 하루',
    );

    expect(await repository.loadAll(), isNull);
    expect(await repository.loadKeywords(), isNull);

    await repository.saveAll([entry]);
    await repository.saveKeywords(['산책']);

    final restored = await repository.loadAll();
    expect(restored, hasLength(1));
    expect(restored!.single.toJson(), entry.toJson());
    expect(await repository.loadKeywords(), ['산책']);
  });

  test('빈 목록도 초기화된 저장 상태로 구분한다', () async {
    await repository.saveAll([]);
    await repository.saveKeywords([]);

    expect(await repository.loadAll(), isEmpty);
    expect(await repository.loadKeywords(), isEmpty);
  });

  test('기존 SharedPreferences 기록을 최초 한 번 Drift로 이전한다', () async {
    SharedPreferences.setMockInitialValues({});
    final legacy = SharedPreferencesDiaryRepository(
      storageKey: 'migration_entries',
      keywordKey: 'migration_keywords',
    );
    final entry = DiaryEntry(
      id: 'legacy-entry',
      date: DateTime(2026, 6, 13),
      mood: DiaryMood.tired,
      keywords: const ['과제'],
      satisfaction: 2,
      summary: '과제를 끝내고 쉬고 싶었던 하루',
    );
    await legacy.saveAll([entry]);
    await legacy.saveKeywords(['발표']);

    final migrating = MigratingDiaryRepository(
      primary: repository,
      legacy: legacy,
    );

    expect((await migrating.loadAll())!.single.toJson(), entry.toJson());
    expect(await migrating.loadKeywords(), ['발표']);

    await legacy.saveAll([]);
    expect((await migrating.loadAll())!.single.id, 'legacy-entry');
  });

  test('백업 상태 교체는 기록과 키워드를 한 번에 반영한다', () async {
    final entry = DiaryEntry(
      id: 'replacement',
      date: DateTime(2026, 6, 14),
      mood: DiaryMood.normal,
      keywords: const ['발표'],
      satisfaction: 4,
      summary: '발표 준비를 차분히 이어간 하루',
    );

    await repository.replaceAll([entry], ['발표']);

    expect((await repository.loadAll())!.single.id, 'replacement');
    expect(await repository.loadKeywords(), ['발표']);

    await repository.replaceAll([], []);
    expect(await repository.loadAll(), isEmpty);
    expect(await repository.loadKeywords(), isEmpty);
  });
}
