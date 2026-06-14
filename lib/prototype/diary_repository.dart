import 'diary_entry.dart';

abstract class DiaryRepository {
  Future<List<DiaryEntry>?> loadAll();

  Future<void> saveAll(List<DiaryEntry> entries);

  /// 사용자가 직접 추가한 키워드 목록을 불러온다.
  /// 기본 구현은 저장하지 않음(메모리 기반 단순 구현 호환).
  Future<List<String>?> loadKeywords() async => null;

  /// 사용자 키워드 목록을 저장한다. 기본 구현은 아무것도 하지 않는다.
  Future<void> saveKeywords(List<String> keywords) async {}
}
