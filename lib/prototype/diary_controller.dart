import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'database/harutalk_database.dart';
import 'diary_entry.dart';
import 'diary_repository.dart';
import 'drift_diary_repository.dart';
import 'migrating_diary_repository.dart';
import 'shared_preferences_diary_repository.dart';

class DiaryController extends ChangeNotifier {
  DiaryController({
    DiaryRepository? repository,
    bool? seedSampleHistory,
    this.generationDelay = const Duration(milliseconds: 1900),
  }) : _repository = repository ?? _defaultRepository(),
       _seedSampleHistory = seedSampleHistory ?? repository == null;

  final DiaryRepository _repository;
  final bool _seedSampleHistory;
  final Duration generationDelay;
  final List<DiaryEntry> _entries = [];
  int _summaryVariant = 0;

  DiaryMood? selectedMood;
  final Set<String> selectedKeywords = {};
  int satisfaction = 3;

  /// 작성 중인 기록이 저장될 날짜(기본값은 오늘, 과거 날짜 선택 가능).
  DateTime recordDate = _dateOnly(DateTime.now());

  bool generating = false;
  bool loaded = false;
  String? storageError;

  static const keywordOptions = ['공부', '친구', '게임', '카페', '과제', '운동'];

  /// 사용자가 직접 추가한 키워드(기본 키워드 다음에 노출, 로컬 저장됨).
  final List<String> customKeywords = [];

  /// 기본 키워드 + 사용자 키워드(중복 제거, 노출 순서).
  List<String> get allKeywords => [
    ...keywordOptions,
    ...customKeywords.where((keyword) => !keywordOptions.contains(keyword)),
  ];

  UnmodifiableListView<DiaryEntry> get entries {
    final sorted = [..._entries]..sort((a, b) => b.date.compareTo(a.date));
    return UnmodifiableListView(sorted);
  }

  bool get canGenerate => selectedMood != null && selectedKeywords.isNotEmpty;

  String createBackupJson({DateTime? exportedAt}) {
    return const JsonEncoder.withIndent('  ').convert({
      'app': 'harutalk',
      'version': 1,
      'exportedAt': (exportedAt ?? DateTime.now()).toIso8601String(),
      'entries': _entries.map((entry) => entry.toJson()).toList(),
      'customKeywords': [...customKeywords],
    });
  }

  BackupPreview inspectBackupJson(String raw) {
    try {
      final backup = _decodeBackup(raw);
      final dates = backup.entries.map((entry) => entry.date).toList()..sort();
      return BackupPreview(
        exportedAt: backup.exportedAt,
        entryCount: backup.entries.length,
        keywordCount: backup.keywords.length,
        earliestEntry: dates.isEmpty ? null : dates.first,
        latestEntry: dates.isEmpty ? null : dates.last,
      );
    } catch (_) {
      throw const FormatException('올바른 하루톡 백업 파일이 아니에요.');
    }
  }

  Future<BackupRestoreResult> restoreBackupJson(String raw) async {
    late final _DecodedBackup backup;
    try {
      backup = _decodeBackup(raw);
    } catch (_) {
      return const BackupRestoreResult.invalid();
    }

    try {
      await _repository.replaceAll(backup.entries, backup.keywords);
      _entries
        ..clear()
        ..addAll(backup.entries);
      customKeywords
        ..clear()
        ..addAll(backup.keywords);
      storageError = null;
      _resetSelection();
      notifyListeners();
      return BackupRestoreResult.success(backup.entries.length);
    } catch (_) {
      storageError = '백업을 기기에 복원하지 못했어요.';
      notifyListeners();
      return const BackupRestoreResult.storageFailure();
    }
  }

  Future<bool> clearAllData() async {
    try {
      await _repository.replaceAll(const [], const []);
      _entries.clear();
      customKeywords.clear();
      storageError = null;
      _resetSelection();
      notifyListeners();
      return true;
    } catch (_) {
      storageError = '기록을 삭제하지 못했어요.';
      notifyListeners();
      return false;
    }
  }

  Future<void> load() async {
    try {
      final saved = await _repository.loadAll();
      _entries
        ..clear()
        ..addAll(saved ?? _sampleEntries());
      // 프로토타입 데이터가 한 건이라도 있으면 연간 흐름을 볼 수 있게 보강한다.
      // 사용자가 전체 삭제한 빈 저장소는 그대로 유지한다.
      final refreshedSamples =
          _seedSampleHistory &&
          saved != null &&
          saved.isNotEmpty &&
          _addMissingSampleEntries();
      if (saved == null || refreshedSamples) await _persist();
    } catch (_) {
      storageError = '저장된 기록을 불러오지 못했어요.';
      _entries
        ..clear()
        ..addAll(_sampleEntries());
    }
    try {
      final savedKeywords = await _repository.loadKeywords();
      if (savedKeywords != null) {
        customKeywords
          ..clear()
          ..addAll(savedKeywords);
      }
    } catch (_) {
      // 키워드 로드 실패는 핵심 흐름을 막지 않는다.
    }
    loaded = true;
    notifyListeners();
  }

  /// 새 기록 작성을 시작한다. 선택값을 비우고 대상 날짜를 정한다.
  /// 감정잔디의 빈 날짜에서 호출하면 그 날짜로 기록을 시작할 수 있다.
  void startRecord({DateTime? date}) {
    selectedMood = null;
    selectedKeywords.clear();
    satisfaction = 3;
    recordDate = _dateOnly(date ?? DateTime.now());
    notifyListeners();
  }

  /// 작성 중인 기록의 날짜만 바꾼다(선택값은 유지).
  void setRecordDate(DateTime date) {
    recordDate = _dateOnly(date);
    notifyListeners();
  }

  void selectMood(DiaryMood mood) {
    selectedMood = mood;
    notifyListeners();
  }

  void toggleKeyword(String keyword) {
    if (!selectedKeywords.add(keyword)) {
      selectedKeywords.remove(keyword);
    }
    notifyListeners();
  }

  /// 직접 입력한 키워드를 추가(처음이면 저장)하고 선택 상태로 만든다.
  /// 이미 있는 키워드면 중복 추가 없이 선택만 한다.
  Future<bool> addCustomKeyword(String raw) async {
    final keyword = raw.trim();
    if (keyword.isEmpty) return true;
    final isNew =
        !keywordOptions.contains(keyword) && !customKeywords.contains(keyword);
    if (isNew) customKeywords.add(keyword);
    selectedKeywords.add(keyword);
    notifyListeners();
    return isNew ? _persistKeywords() : true;
  }

  /// 사용자 키워드를 목록과 저장소, 현재 선택에서 모두 제거한다.
  Future<bool> removeCustomKeyword(String keyword) async {
    if (!customKeywords.remove(keyword)) return true;
    selectedKeywords.remove(keyword);
    notifyListeners();
    return _persistKeywords();
  }

  Future<bool> _persistKeywords() async {
    try {
      await _repository.saveKeywords(customKeywords);
      return true;
    } catch (_) {
      storageError = '키워드를 저장하지 못했어요.';
      return false;
    }
  }

  void setSatisfaction(int value) {
    satisfaction = value;
    notifyListeners();
  }

  DiaryEntry? entryForDay(DateTime day) {
    for (final entry in _entries) {
      if (isSameDiaryDay(entry.date, day)) return entry;
    }
    return null;
  }

  DiaryEntry? entryById(String id) {
    for (final entry in _entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  Map<DiaryMood, int> get thisMonthMoodCounts {
    final now = DateTime.now();
    return {
      for (final mood in DiaryMood.values)
        mood: _entries
            .where(
              (entry) =>
                  entry.date.year == now.year &&
                  entry.date.month == now.month &&
                  entry.mood == mood,
            )
            .length,
    };
  }

  int get currentStreak {
    var streak = 0;
    var day = DateTime.now();
    while (entryForDay(day) != null) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Future<DiaryEntry?> generatePreview() async {
    if (!canGenerate || generating) return null;
    generating = true;
    notifyListeners();

    await Future<void>.delayed(generationDelay);
    final mood = selectedMood!;
    final keywords = selectedKeywords.toList();
    final entry = DiaryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: recordDate,
      mood: mood,
      keywords: keywords,
      satisfaction: satisfaction,
      summary: _buildSummary(mood, keywords, satisfaction, _summaryVariant++),
    );

    generating = false;
    notifyListeners();
    return entry;
  }

  Future<DiaryEntry> regeneratePreview(DiaryEntry entry) async {
    if (generating) return entry;
    generating = true;
    notifyListeners();
    await Future<void>.delayed(generationDelay);
    final regenerated = entry.copyWith(
      summary: _buildSummary(
        entry.mood,
        entry.keywords,
        entry.satisfaction,
        _summaryVariant++,
      ),
    );
    generating = false;
    notifyListeners();
    return regenerated;
  }

  Future<bool> saveEntry(DiaryEntry entry) async {
    _entries.removeWhere((item) => isSameDiaryDay(item.date, entry.date));
    _entries.add(entry.copyWith(isSample: false));
    final saved = await _persist();
    _resetSelection();
    notifyListeners();
    return saved;
  }

  Future<bool> updateSummary(String id, String summary) async {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index == -1) return false;
    _entries[index] = _entries[index].copyWith(
      summary: summary.trim(),
      isSample: false,
    );
    final saved = await _persist();
    notifyListeners();
    return saved;
  }

  Future<bool> deleteEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    final saved = await _persist();
    notifyListeners();
    return saved;
  }

  void _resetSelection() {
    selectedMood = null;
    selectedKeywords.clear();
    satisfaction = 3;
    recordDate = _dateOnly(DateTime.now());
  }

  Future<bool> _persist() async {
    try {
      await _repository.saveAll(_entries);
      storageError = null;
      return true;
    } catch (_) {
      storageError = '기록을 기기에 저장하지 못했어요.';
      return false;
    }
  }

  void _validateBackup(
    List<DiaryEntry> entries,
    List<String> restoredKeywords,
  ) {
    final days = <String>{};
    for (final entry in entries) {
      final day = '${entry.date.year}-${entry.date.month}-${entry.date.day}';
      if (!days.add(day) ||
          entry.keywords.isEmpty ||
          entry.satisfaction < 1 ||
          entry.satisfaction > 5 ||
          entry.summary.trim().isEmpty) {
        throw const FormatException('잘못된 기록 데이터');
      }
    }
    if (restoredKeywords.any((keyword) => keyword.trim().isEmpty) ||
        restoredKeywords.toSet().length != restoredKeywords.length) {
      throw const FormatException('잘못된 키워드 데이터');
    }
  }

  _DecodedBackup _decodeBackup(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic> ||
        decoded['app'] != 'harutalk' ||
        decoded['version'] != 1 ||
        decoded['entries'] is! List ||
        decoded['customKeywords'] is! List) {
      throw const FormatException('잘못된 백업 형식');
    }

    final entries = (decoded['entries'] as List)
        .map(
          (item) => DiaryEntry.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
    final keywords = List<String>.from(decoded['customKeywords'] as List);
    _validateBackup(entries, keywords);

    final exportedAtValue = decoded['exportedAt'];
    final exportedAt = exportedAtValue == null
        ? null
        : DateTime.tryParse(exportedAtValue as String);
    if (exportedAtValue != null && exportedAt == null) {
      throw const FormatException('잘못된 백업 생성 날짜');
    }
    return _DecodedBackup(
      entries: entries,
      keywords: keywords,
      exportedAt: exportedAt,
    );
  }

  String _buildSummary(
    DiaryMood mood,
    List<String> keywords,
    int score,
    int variant,
  ) {
    final keywordText = keywords.take(2).join('와 ');
    final moodTexts = switch (mood) {
      DiaryMood.happy => ['기분 좋은 순간을 발견한', '작은 즐거움을 오래 기억한'],
      DiaryMood.normal => ['차분하게 나만의 흐름을 지킨', '평범함 속에서 균형을 지킨'],
      DiaryMood.tired => ['조금 지쳤지만 오늘을 잘 버텨낸', '피곤함 속에서도 할 일을 이어간'],
      DiaryMood.sad => ['마음이 느린 날에도 하루를 이어간', '천천히 내 마음을 돌본'],
      DiaryMood.angry => ['마음이 복잡했지만 감정을 알아차린', '거친 마음을 지나 차분함을 찾은'],
    };
    final scoreTexts = score >= 4
        ? ['꽤 만족스러운 하루', '기억하고 싶은 하루']
        : score == 3
        ? ['무난하게 지나온 하루', '나름의 균형을 찾은 하루']
        : ['조금 아쉬움이 남은 하루', '내일을 위한 쉼표가 필요한 하루'];
    final index = variant % 2;
    return '$keywordText 속에서 ${moodTexts[index]}, ${scoreTexts[index]}.';
  }

  List<DiaryEntry> _sampleEntries() {
    final today = _dateOnly(DateTime.now());
    final lastSampleDay = today.subtract(const Duration(days: 1));
    final moods = [
      DiaryMood.normal,
      DiaryMood.happy,
      DiaryMood.tired,
      DiaryMood.happy,
      DiaryMood.normal,
      DiaryMood.sad,
      DiaryMood.happy,
      DiaryMood.normal,
      DiaryMood.tired,
      DiaryMood.angry,
    ];
    final keywordSets = [
      ['공부'],
      ['친구', '카페'],
      ['과제'],
      ['운동'],
      ['게임'],
      ['공부', '카페'],
      ['친구'],
      ['운동', '친구'],
      ['과제', '공부'],
      ['게임', '카페'],
    ];
    final samples = <DiaryEntry>[];

    for (
      var day = DateTime(today.year, 1, 1);
      !day.isAfter(lastSampleDay);
      day = day.add(const Duration(days: 1))
    ) {
      final index = day.difference(DateTime(today.year)).inDays;
      // 대부분의 날을 채우되 가끔 쉰 날을 남겨 자연스러운 기록 흐름을 만든다.
      if (index % 12 == 0) {
        continue;
      }
      final mood = moods[index % moods.length];
      final keywords = keywordSets[index % keywordSets.length];
      final satisfaction = switch (mood) {
        DiaryMood.happy => index.isEven ? 5 : 4,
        DiaryMood.normal => index.isEven ? 4 : 3,
        DiaryMood.tired => 3,
        DiaryMood.sad || DiaryMood.angry => 2,
      };
      samples.add(
        DiaryEntry(
          id: 'sample-${day.year}-${day.month}-${day.day}',
          date: day,
          mood: mood,
          keywords: keywords,
          satisfaction: satisfaction,
          summary: _buildSummary(mood, keywords, satisfaction, index),
          isSample: true,
        ),
      );
    }
    return samples;
  }

  bool _addMissingSampleEntries() {
    final occupiedDays = _entries.map((entry) => _dayKey(entry.date)).toSet();
    final missing = _sampleEntries()
        .where((entry) => !occupiedDays.contains(_dayKey(entry.date)))
        .toList();
    _entries.addAll(missing);
    return missing.isNotEmpty;
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

String _dayKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

DiaryRepository _defaultRepository() {
  return MigratingDiaryRepository(
    primary: DriftDiaryRepository(HarutalkDatabase.defaults()),
    legacy: SharedPreferencesDiaryRepository(),
  );
}

class BackupRestoreResult {
  const BackupRestoreResult._({
    required this.success,
    required this.restoredCount,
    required this.message,
  });

  const BackupRestoreResult.invalid()
    : this._(success: false, restoredCount: 0, message: '올바른 하루톡 백업 파일이 아니에요.');

  const BackupRestoreResult.success(int restoredCount)
    : this._(
        success: true,
        restoredCount: restoredCount,
        message: '$restoredCount개의 기록을 복원했어요.',
      );

  const BackupRestoreResult.storageFailure()
    : this._(success: false, restoredCount: 0, message: '백업을 기기에 복원하지 못했어요.');

  final bool success;
  final int restoredCount;
  final String message;
}

class BackupPreview {
  const BackupPreview({
    required this.exportedAt,
    required this.entryCount,
    required this.keywordCount,
    required this.earliestEntry,
    required this.latestEntry,
  });

  final DateTime? exportedAt;
  final int entryCount;
  final int keywordCount;
  final DateTime? earliestEntry;
  final DateTime? latestEntry;
}

class _DecodedBackup {
  const _DecodedBackup({
    required this.entries,
    required this.keywords,
    required this.exportedAt,
  });

  final List<DiaryEntry> entries;
  final List<String> keywords;
  final DateTime? exportedAt;
}
