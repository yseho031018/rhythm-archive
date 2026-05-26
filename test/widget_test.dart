import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm_archive/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('emotion keywords map to distinct wave behaviors', () {
    expect(resolveEmotionType('평온'), EmotionType.calm);
    expect(resolveEmotionType('불안'), EmotionType.anxious);
    expect(resolveEmotionType('성취감'), EmotionType.achievement);
    expect(resolveEmotionType('집중'), EmotionType.focused);

    expect(WaveBehavior.configFor('불안').chaos, greaterThan(0.6));
    expect(WaveBehavior.configFor('성취감').rise, greaterThan(40));
    expect(WaveBehavior.configFor('집중').smoothness, greaterThan(0.8));
    expect(WaveBehavior.configFor('평온').speed, lessThan(0.8));
  });

  testWidgets('Rhythm demo renders main tabs', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const RhythmApp());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Rhythm'), findsOneWidget);
    expect(find.text('오늘'), findsOneWidget);
    expect(find.text('히스토리'), findsOneWidget);
    expect(find.text('패턴'), findsOneWidget);
  });
}
