import 'dart:convert';

import 'package:drift/drift.dart';

import 'database/harutalk_database.dart';
import 'diary_entry.dart';
import 'diary_repository.dart';

class DriftDiaryRepository implements DiaryRepository {
  DriftDiaryRepository(this.database);

  static const _entriesInitializedKey = 'entries_initialized';
  static const _keywordsInitializedKey = 'keywords_initialized';

  final HarutalkDatabase database;

  @override
  Future<List<DiaryEntry>?> loadAll() async {
    if (!await _isInitialized(_entriesInitializedKey)) return null;

    final rows = await (database.select(
      database.storedDiaryEntries,
    )..orderBy([(entry) => OrderingTerm.asc(entry.entryDate)])).get();
    return rows
        .map(
          (row) => DiaryEntry(
            id: row.id,
            date: row.entryDate,
            mood: DiaryMood.values.byName(row.moodName),
            keywords: List<String>.from(
              jsonDecode(row.keywordsJson) as List<dynamic>,
            ),
            satisfaction: row.satisfaction,
            summary: row.summary,
            isSample: row.isSample,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveAll(List<DiaryEntry> entries) async {
    await database.transaction(() async {
      await _replaceEntries(entries);
      await _markInitialized(_entriesInitializedKey);
    });
  }

  @override
  Future<List<String>?> loadKeywords() async {
    if (!await _isInitialized(_keywordsInitializedKey)) return null;

    final rows = await (database.select(
      database.storedCustomKeywords,
    )..orderBy([(keyword) => OrderingTerm.asc(keyword.sortOrder)])).get();
    return rows.map((row) => row.keyword).toList();
  }

  @override
  Future<void> saveKeywords(List<String> keywords) async {
    await database.transaction(() async {
      await _replaceKeywords(keywords);
      await _markInitialized(_keywordsInitializedKey);
    });
  }

  @override
  Future<void> replaceAll(
    List<DiaryEntry> entries,
    List<String> keywords,
  ) async {
    await database.transaction(() async {
      await _replaceEntries(entries);
      await _replaceKeywords(keywords);
      await _markInitialized(_entriesInitializedKey);
      await _markInitialized(_keywordsInitializedKey);
    });
  }

  Future<void> _replaceEntries(List<DiaryEntry> entries) async {
    await database.delete(database.storedDiaryEntries).go();
    if (entries.isEmpty) return;

    await database.batch((batch) {
      batch.insertAll(
        database.storedDiaryEntries,
        entries
            .map(
              (entry) => StoredDiaryEntriesCompanion.insert(
                id: entry.id,
                entryDate: entry.date,
                moodName: entry.mood.name,
                keywordsJson: jsonEncode(entry.keywords),
                satisfaction: entry.satisfaction,
                summary: entry.summary,
                isSample: Value(entry.isSample),
              ),
            )
            .toList(),
      );
    });
  }

  Future<void> _replaceKeywords(List<String> keywords) async {
    await database.delete(database.storedCustomKeywords).go();
    if (keywords.isEmpty) return;

    await database.batch((batch) {
      batch.insertAll(database.storedCustomKeywords, [
        for (final (index, keyword) in keywords.indexed)
          StoredCustomKeywordsCompanion.insert(
            keyword: keyword,
            sortOrder: index,
          ),
      ]);
    });
  }

  Future<bool> _isInitialized(String key) async {
    final row = await (database.select(
      database.storageMetadata,
    )..where((metadata) => metadata.key.equals(key))).getSingleOrNull();
    return row?.value == 'true';
  }

  Future<void> _markInitialized(String key) {
    return database
        .into(database.storageMetadata)
        .insertOnConflictUpdate(
          StorageMetadataCompanion.insert(key: key, value: 'true'),
        );
  }
}
