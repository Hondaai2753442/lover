import 'package:flutter_test/flutter_test.dart';
import 'package:arabic_couples_game/main.dart';

void main() {
  testWidgets('home screen shows both game modes', (WidgetTester tester) async {
    await tester.pumpWidget(const ArabicCouplesGame());
    expect(find.text('من أنا؟'), findsOneWidget);
    expect(find.text('خمن الشخصية'), findsOneWidget);
    expect(find.text('أسئلة وتحديات للأزواج'), findsOneWidget);
  });
}
