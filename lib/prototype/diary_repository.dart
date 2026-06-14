import 'diary_entry.dart';

abstract class DiaryRepository {
  Future<List<DiaryEntry>?> loadAll();

  Future<void> saveAll(List<DiaryEntry> entries);

  /// 사용자가 직접 추가한 키워드 목록을 불러온다.
  /// 기본 구현은 저장하지 않음(메모리 기반 단순 구현 호환).
  Future<List<String>?> loadKeywords() async => null;

  /// 사용자 키워드 목록을 저장한다. 기본 구현은 아무것도 하지 않는다.
  Future<void> saveKeywords(List<String> keywords) async {}

  /// 기록과 사용자 키워드를 하나의 백업 상태로 교체한다.
  /// DB 구현체는 이 메서드를 트랜잭션으로 재정의할 수 있다.
  Future<void> replaceAll(
    List<DiaryEntry> entries,
    List<String> keywords,
  ) async {
    await saveAll(entries);
    await saveKeywords(keywords);
  }
}
