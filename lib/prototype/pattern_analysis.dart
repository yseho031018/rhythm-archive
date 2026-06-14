import 'diary_entry.dart';

/// 한 키워드에 대해 누적 기록에서 뽑아낸 통계.
class KeywordInsight {
  const KeywordInsight({
    required this.keyword,
    required this.count,
    required this.averageSatisfaction,
    required this.deltaFromOverall,
    required this.topMood,
    required this.topMoodCount,
  });

  final String keyword;

  /// 이 키워드가 등장한 기록 수.
  final int count;

  /// 이 키워드가 있던 날의 평균 만족도.
  final double averageSatisfaction;

  /// 전체 평균 만족도와의 차이(양수면 더 만족, 음수면 덜 만족).
  final double deltaFromOverall;

  /// 이 키워드와 가장 자주 함께 나타난 기분.
  final DiaryMood topMood;
  final int topMoodCount;

  /// 대표 기분이 표본의 과반을 차지하는지(감정 연결 문장의 신뢰 기준).
  bool get topMoodIsDominant => topMoodCount >= 2 && topMoodCount / count >= 0.5;
}

/// 누적 기록 전체를 분석한 결과.
class PatternReport {
  const PatternReport({
    required this.totalEntries,
    required this.overallAverage,
    required this.keywords,
    required this.sentences,
  });

  final int totalEntries;
  final double overallAverage;

  /// 표본이 충분한 키워드 통계(기록 수 내림차순).
  final List<KeywordInsight> keywords;

  /// 사용자에게 보여줄 패턴 문장. 신뢰할 만한 패턴이 없으면 비어 있다.
  final List<String> sentences;

  /// 보여줄 패턴 문장이 하나라도 있는지.
  bool get hasEnoughData => sentences.isNotEmpty;

  static const empty = PatternReport(
    totalEntries: 0,
    overallAverage: 0,
    keywords: [],
    sentences: [],
  );
}

/// 누적 기록에서 키워드-만족도-기분의 관계를 찾아낸다.
///
/// 표본이 적은 키워드는 노이즈를 만들기 쉬우므로 [minKeywordSamples]번 미만
/// 등장한 키워드는 제외하고, 만족도 차이가 [satisfactionDeltaThreshold] 미만이면
/// 문장으로 만들지 않는다(불안정한 패턴을 단정하지 않기 위한 보수적 기준).
PatternReport analyzePatterns(
  List<DiaryEntry> entries, {
  int minKeywordSamples = 2,
  double satisfactionDeltaThreshold = 0.3,
}) {
  if (entries.isEmpty) return PatternReport.empty;

  final overall =
      entries.map((entry) => entry.satisfaction).reduce((a, b) => a + b) /
      entries.length;

  final byKeyword = <String, List<DiaryEntry>>{};
  for (final entry in entries) {
    for (final keyword in entry.keywords) {
      byKeyword.putIfAbsent(keyword, () => []).add(entry);
    }
  }

  final insights = <KeywordInsight>[];
  byKeyword.forEach((keyword, group) {
    if (group.length < minKeywordSamples) return;
    final average =
        group.map((entry) => entry.satisfaction).reduce((a, b) => a + b) /
        group.length;

    final moodCounts = <DiaryMood, int>{};
    for (final entry in group) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }
    // enum 순서로 순회해 동점일 때 결과가 항상 같도록(결정적) 한다.
    var topMood = group.first.mood;
    var topMoodCount = 0;
    for (final mood in DiaryMood.values) {
      final count = moodCounts[mood] ?? 0;
      if (count > topMoodCount) {
        topMoodCount = count;
        topMood = mood;
      }
    }

    insights.add(
      KeywordInsight(
        keyword: keyword,
        count: group.length,
        averageSatisfaction: average,
        deltaFromOverall: average - overall,
        topMood: topMood,
        topMoodCount: topMoodCount,
      ),
    );
  });

  insights.sort((a, b) {
    final byCount = b.count.compareTo(a.count);
    if (byCount != 0) return byCount;
    return a.keyword.compareTo(b.keyword);
  });

  return PatternReport(
    totalEntries: entries.length,
    overallAverage: overall,
    keywords: insights,
    sentences: _buildSentences(insights, satisfactionDeltaThreshold),
  );
}

List<String> _buildSentences(List<KeywordInsight> insights, double threshold) {
  if (insights.isEmpty) return const [];
  final sentences = <String>[];

  final byDelta = [...insights]
    ..sort((a, b) => b.deltaFromOverall.compareTo(a.deltaFromOverall));

  // 만족도가 가장 높았던 키워드.
  final best = byDelta.first;
  if (best.deltaFromOverall >= threshold) {
    sentences.add(
      '${best.keyword}${_waGwa(best.keyword)} 함께한 날은 '
      '평균 만족도가 ${best.deltaFromOverall.toStringAsFixed(1)}점 더 높았어요.',
    );
  }

  // 만족도가 가장 낮았던 키워드(가장 높은 키워드와 다를 때만).
  final worst = byDelta.last;
  if (worst.deltaFromOverall <= -threshold && worst.keyword != best.keyword) {
    sentences.add(
      '${worst.keyword}${_waGwa(worst.keyword)} 함께한 날은 '
      '평균 만족도가 ${(-worst.deltaFromOverall).toStringAsFixed(1)}점 더 낮았어요.',
    );
  }

  // 가장 자주 기록한 키워드의 대표 기분.
  final frequent = insights.first;
  if (frequent.topMoodIsDominant) {
    sentences.add(
      '${frequent.keyword} 키워드가 있던 날은 '
      '주로 ${frequent.topMood.emoji} ${frequent.topMood.label} 기분이었어요.',
    );
  }

  return sentences;
}

/// 받침 유무에 따라 조사 '와/과'를 고른다.
String _waGwa(String word) => _hasFinalConsonant(word) ? '과' : '와';

bool _hasFinalConsonant(String word) {
  if (word.isEmpty) return false;
  final code = word.codeUnitAt(word.length - 1);
  // 한글 음절이 아니면 받침이 없는 것으로 처리한다.
  if (code < 0xAC00 || code > 0xD7A3) return false;
  return (code - 0xAC00) % 28 != 0;
}
