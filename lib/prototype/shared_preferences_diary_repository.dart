import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'diary_entry.dart';
import 'diary_repository.dart';

class SharedPreferencesDiaryRepository implements DiaryRepository {
  SharedPreferencesDiaryRepository({
    this.storageKey = 'harutalk_entries_v1',
    this.keywordKey = 'harutalk_keywords_v1',
  });

  final String storageKey;
  final String keywordKey;

  @override
  Future<List<DiaryEntry>?> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(storageKey);
    if (raw == null) return null;

    return raw
        .map(
          (item) =>
              DiaryEntry.fromJson(jsonDecode(item) as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> saveAll(List<DiaryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      storageKey,
      entries.map((entry) => jsonEncode(entry.toJson())).toList(),
    );
  }

  @override
  Future<List<String>?> loadKeywords() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(keywordKey);
  }

  @override
  Future<void> saveKeywords(List<String> keywords) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(keywordKey, keywords);
  }
}
