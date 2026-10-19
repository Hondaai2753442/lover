import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arabic_couples_game/main.dart';
import 'package:arabic_couples_game/models/character.dart';
import 'package:arabic_couples_game/models/couples_card.dart';
import 'package:arabic_couples_game/models/game_session.dart';
import 'package:arabic_couples_game/services/preferences_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'streak_days': 3,
      'dark_mode': false,
      'font_scale': 1.0,
      'reduced_motion': false,
    });
    await PreferencesService.init();
  });

  testWidgets('Home screen displays title, streak, and primary game modes',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ArabicCouplesGame());
    await tester.pumpAndSettle();

    expect(find.text('من أنا؟ 💜'), findsOneWidget);
    expect(find.text('خمن الشخصية'), findsOneWidget);
    expect(find.text('جلسة الأزواج المنظمة'), findsOneWidget);
    expect(find.text('أسئلة وتحديات للأزواج'), findsOneWidget);
  });

  test('Character trait matching works properly', () {
    const c = Character(
      id: 'char_test',
      name: 'طارق',
      emoji: '🧔🏻‍♂️',
      gender: 'رجل',
      older: false,
      glasses: true,
      beard: true,
      headwear: false,
      hijab: false,
      thobe: true,
      hair: 'داكن',
      skin: 'فاتحة',
    );

    expect(c.trait('gender_male'), isTrue);
    expect(c.trait('gender_female'), isFalse);
    expect(c.trait('glasses'), isTrue);
    expect(c.trait('beard'), isTrue);
    expect(c.trait('hijab'), isFalse);
    expect(c.trait('thobe'), isTrue);
    expect(c.trait('light_skin'), isTrue);
    expect(c.trait('dark_hair'), isTrue);
  });

  test('StructuredSession step progression and completion', () {
    final sampleCards = [
      const CouplesCard(
        id: '1',
        category: 'التقارب',
        type: 'سؤال',
        level: 'خفيف',
        text: 'سؤال تمهيدي',
        purpose: 'بداية',
      ),
      const CouplesCard(
        id: '2',
        category: 'التقارب',
        type: 'سؤال',
        level: 'عميق',
        text: 'سؤال عميق',
        purpose: 'حوار',
      ),
      const CouplesCard(
        id: '3',
        category: 'الامتنان',
        type: 'امتنان',
        level: 'متوسط',
        text: 'شكراً لك',
        purpose: 'تقدير',
      ),
      const CouplesCard(
        id: '4',
        category: 'تأمل ومراجعة',
        type: 'تأمل',
        level: 'عميق',
        text: 'تأمل ختامي',
        purpose: 'هدوء',
      ),
    ];

    final session = StructuredSession(allCards: sampleCards);
    expect(session.steps.length, equals(4));
    expect(session.isCompleted, isFalse);

    session.next();
    expect(session.currentStepIndex, equals(1));

    session.next();
    session.next();
    session.next();
    expect(session.isCompleted, isTrue);
  });
}
