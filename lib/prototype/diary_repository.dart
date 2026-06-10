import 'diary_entry.dart';

abstract class DiaryRepository {
  Future<List<DiaryEntry>?> loadAll();

  Future<void> saveAll(List<DiaryEntry> entries);
}
