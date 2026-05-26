import 'package:flutter_test/flutter_test.dart';
import 'package:rhythm_archive/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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
