import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm_archive/main.dart';
import 'package:rhythm_archive/models/app_styles.dart';
import 'package:rhythm_archive/models/emotion_type.dart';
import 'package:rhythm_archive/models/rhythm_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('EmotionMapping', () {
    test('resolves all emotion keywords correctly', () {
      expect(EmotionMapping.resolve('평온'), EmotionType.calm);
      expect(EmotionMapping.resolve('불안'), EmotionType.anxious);
      expect(EmotionMapping.resolve('성취감'), EmotionType.achievement);
      expect(EmotionMapping.resolve('집중'), EmotionType.focused);
      expect(EmotionMapping.resolve('피곤'), EmotionType.tired);
      expect(EmotionMapping.resolve('무기력'), EmotionType.tired);
      expect(EmotionMapping.resolve('기쁨'), EmotionType.joyful);
      expect(EmotionMapping.resolve('설렘'), EmotionType.joyful);
      expect(EmotionMapping.resolve('unknown'), EmotionType.calm);
    });

    test('returns distinct colors for different emotions', () {
      final calm = EmotionMapping.color(['평온']);
      final anxious = EmotionMapping.color(['불안']);
      final achievement = EmotionMapping.color(['성취감']);
      final joyful = EmotionMapping.color(['기쁨']);

      expect(calm, isNot(equals(anxious)));
      expect(anxious, isNot(equals(achievement)));
      expect(achievement, isNot(equals(joyful)));
    });
  });

  group('WaveBehavior', () {
    test('configFor produces distinct wave configs per emotion', () {
      final anxious = WaveBehavior.configFor('불안');
      final achievement = WaveBehavior.configFor('성취감');
      final focused = WaveBehavior.configFor('집중');
      final calm = WaveBehavior.configFor('평온');

      expect(anxious.chaos, greaterThan(0.6));
      expect(achievement.rise, greaterThan(40));
      expect(focused.smoothness, greaterThan(0.8));
      expect(calm.speed, lessThan(0.8));

      expect(anxious.type, EmotionType.anxious);
      expect(achievement.type, EmotionType.achievement);
      expect(focused.type, EmotionType.focused);
      expect(calm.type, EmotionType.calm);
    });

    test('configFor covers all known emotion keywords', () {
      const keywords = ['피곤', '성취감', '불안', '평온', '기쁨', '무기력', '집중', '설렘'];
      for (final keyword in keywords) {
        final config = WaveBehavior.configFor(keyword);
        expect(config.label, isNotEmpty);
        expect(config.amplitude, greaterThan(0));
        expect(config.colors, isNotEmpty);
      }
    });
  });

  group('RhythmEntry', () {
    test('serialization round-trip preserves all fields', () {
      final entry = RhythmEntry(
        id: 'test-1',
        createdAt: DateTime(2026, 5, 27, 10, 0),
        energy: 4,
        emotions: ['기쁨', '집중'],
        activities: ['공부', '운동'],
        note: '테스트 메모',
        isSample: true,
      );

      final json = entry.toJson();
      final restored = RhythmEntry.fromJson(json);

      expect(restored.id, entry.id);
      expect(restored.createdAt, entry.createdAt);
      expect(restored.energy, entry.energy);
      expect(restored.emotions, entry.emotions);
      expect(restored.activities, entry.activities);
      expect(restored.note, entry.note);
      expect(restored.isSample, entry.isSample);
    });

    test('copyWith creates a modified copy', () {
      final entry = RhythmEntry(
        id: 'test-1',
        createdAt: DateTime.now(),
        energy: 3,
        emotions: ['평온'],
        activities: ['휴식'],
        note: '',
      );

      final copy = entry.copyWith(energy: 5, note: '수정됨');
      expect(copy.energy, 5);
      expect(copy.note, '수정됨');
      expect(copy.id, entry.id); // unchanged
    });
  });

  group('AppStyles utilities', () {
    test('topKey returns the key with highest count', () {
      expect(topKey({'a': 3, 'b': 5, 'c': 2}), 'b');
      expect(topKey({'x': 1}), 'x');
      expect(topKey({}), null);
    });
  });

  group('Widget tests', () {
    testWidgets('Rhythm demo renders main tabs', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const RhythmApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Rhythm'), findsOneWidget);
      expect(find.text('오늘'), findsOneWidget);
      expect(find.text('히스토리'), findsOneWidget);
      expect(find.text('패턴'), findsOneWidget);
      expect(find.text('감정 키워드를 선택해주세요'), findsOneWidget);
    });
  });
}
