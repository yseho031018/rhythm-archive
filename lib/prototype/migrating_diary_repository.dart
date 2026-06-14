import 'diary_entry.dart';
import 'diary_repository.dart';

class MigratingDiaryRepository implements DiaryRepository {
  MigratingDiaryRepository({required this.primary, required this.legacy});

  final DiaryRepository primary;
  final DiaryRepository legacy;
  Future<void>? _migration;

  @override
  Future<List<DiaryEntry>?> loadAll() async {
    await _ensureMigrated();
    return primary.loadAll();
  }

  @override
  Future<void> saveAll(List<DiaryEntry> entries) => primary.saveAll(entries);

  @override
  Future<List<String>?> loadKeywords() async {
    await _ensureMigrated();
    return primary.loadKeywords();
  }

  @override
  Future<void> saveKeywords(List<String> keywords) {
    return primary.saveKeywords(keywords);
  }

  @override
  Future<void> replaceAll(List<DiaryEntry> entries, List<String> keywords) {
    return primary.replaceAll(entries, keywords);
  }

  Future<void> _ensureMigrated() {
    return _migration ??= _migrateLegacyData();
  }

  Future<void> _migrateLegacyData() async {
    if (await primary.loadAll() == null) {
      final legacyEntries = await legacy.loadAll();
      if (legacyEntries != null) await primary.saveAll(legacyEntries);
    }

    if (await primary.loadKeywords() == null) {
      final legacyKeywords = await legacy.loadKeywords();
      if (legacyKeywords != null) await primary.saveKeywords(legacyKeywords);
    }
  }
}
