import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm_archive/prototype/diary_entry.dart';
import 'package:rhythm_archive/prototype/pattern_analysis.dart';

DiaryEntry entry(
  int day,
  DiaryMood mood,
  List<String> keywords,
  int satisfaction,
) {
  return DiaryEntry(
    id: 'e$day',
    date: DateTime(2026, 6, day),
    mood: mood,
    keywords: keywords,
    satisfaction: satisfaction,
    summary: 's$day',
  );
}

void main() {
  group('analyzePatterns', () {
    test('기록이 없으면 빈 리포트를 돌려준다', () {
      final report = analyzePatterns(const []);
      expect(report.hasEnoughData, isFalse);
      expect(report.keywords, isEmpty);
      expect(report.totalEntries, 0);
    });

    test('표본이 부족한 키워드는 통계에서 제외한다', () {
      final report = analyzePatterns([
        entry(1, DiaryMood.happy, ['친구'], 5),
        entry(2, DiaryMood.happy, ['친구'], 4),
        entry(3, DiaryMood.tired, ['게임'], 2), // 1회 → 제외
      ]);

      expect(report.keywords.map((k) => k.keyword), ['친구']);
    });

    test('키워드 평균 만족도와 전체 평균 차이를 계산한다', () {
      final report = analyzePatterns([
        entry(1, DiaryMood.happy, ['친구'], 5),
        entry(2, DiaryMood.happy, ['친구'], 5),
        entry(3, DiaryMood.sad, ['공부'], 1),
        entry(4, DiaryMood.sad, ['공부'], 1),
      ]);

      expect(report.overallAverage, closeTo(3.0, 1e-9));
      final friend = report.keywords.firstWhere((k) => k.keyword == '친구');
      expect(friend.count, 2);
      expect(friend.averageSatisfaction, closeTo(5.0, 1e-9));
      expect(friend.deltaFromOverall, closeTo(2.0, 1e-9));
    });

    test('기록 수가 많은 키워드가 먼저 온다', () {
      final report = analyzePatterns([
        entry(1, DiaryMood.happy, ['친구'], 4),
        entry(2, DiaryMood.happy, ['친구'], 4),
        entry(3, DiaryMood.normal, ['친구'], 3),
        entry(4, DiaryMood.tired, ['과제'], 2),
        entry(5, DiaryMood.tired, ['과제'], 2),
      ]);

      expect(report.keywords.first.keyword, '친구');
      expect(report.keywords.first.count, 3);
    });

    test('만족도가 높은/낮은 키워드 문장을 만든다', () {
      final report = analyzePatterns([
        entry(1, DiaryMood.happy, ['친구'], 5),
        entry(2, DiaryMood.happy, ['친구'], 5),
        entry(3, DiaryMood.happy, ['친구'], 4),
        entry(4, DiaryMood.tired, ['과제'], 2),
        entry(5, DiaryMood.angry, ['과제'], 1),
        entry(6, DiaryMood.tired, ['과제'], 2),
      ]);

      expect(
        report.sentences.any(
          (s) => s.contains('친구와 함께한') && s.contains('더 높았어요'),
        ),
        isTrue,
      );
      expect(
        report.sentences.any(
          (s) => s.contains('과제와 함께한') && s.contains('더 낮았어요'),
        ),
        isTrue,
      );
    });

    test('받침이 있는 키워드는 조사 과를 사용한다', () {
      final report = analyzePatterns([
        entry(1, DiaryMood.happy, ['운동'], 5),
        entry(2, DiaryMood.happy, ['운동'], 5),
        entry(3, DiaryMood.sad, ['공부'], 1),
        entry(4, DiaryMood.sad, ['공부'], 1),
      ]);

      expect(report.sentences.any((s) => s.contains('운동과 함께한')), isTrue);
      expect(report.sentences.any((s) => s.contains('공부와 함께한')), isTrue);
    });

    test('대표 기분이 과반이면 감정 연결 문장을 만든다', () {
      final report = analyzePatterns([
        entry(1, DiaryMood.tired, ['과제'], 3),
        entry(2, DiaryMood.tired, ['과제'], 3),
        entry(3, DiaryMood.happy, ['과제'], 3),
      ]);

      final overdue = report.keywords.single;
      expect(overdue.topMood, DiaryMood.tired);
      expect(overdue.topMoodIsDominant, isTrue);
      expect(
        report.sentences.any(
          (s) => s.contains('과제 키워드가 있던 날은') && s.contains('피곤'),
        ),
        isTrue,
      );
    });

    test('만족도 차이가 작으면 단정하는 문장을 만들지 않는다', () {
      final report = analyzePatterns([
        entry(1, DiaryMood.happy, ['친구'], 3),
        entry(2, DiaryMood.normal, ['친구'], 3),
        entry(3, DiaryMood.happy, ['공부'], 3),
        entry(4, DiaryMood.normal, ['공부'], 3),
      ]);

      // 모두 같은 만족도라 차이가 0 → 만족도 문장 없음.
      expect(report.sentences.any((s) => s.contains('만족도')), isFalse);
    });
  });
}
