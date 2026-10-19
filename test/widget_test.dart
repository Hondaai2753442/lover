import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arabic_couples_game/main.dart';
import 'package:arabic_couples_game/models/character.dart';
import 'package:arabic_couples_game/models/couples_card.dart';
import 'package:arabic_couples_game/models/game_session.dart';
import 'package:arabic_couples_game/models/know_me_question.dart';
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

  test('Character trait matching works properly across Arabic attributes', () {
    const c1 = Character(
      id: 'char_test_1',
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

    expect(c1.trait('gender_male'), isTrue);
    expect(c1.trait('gender_female'), isFalse);
    expect(c1.trait('glasses'), isTrue);
    expect(c1.trait('beard'), isTrue);
    expect(c1.trait('hijab'), isFalse);
    expect(c1.trait('thobe'), isTrue);
    expect(c1.trait('light_skin'), isTrue);
    expect(c1.trait('dark_hair'), isTrue);

    const c2 = Character(
      id: 'char_test_2',
      name: 'نورة',
      emoji: '🧕🏼',
      gender: 'امرأة',
      older: false,
      glasses: false,
      beard: false,
      headwear: true,
      hijab: true,
      thobe: false,
      hair: 'محجبة',
      skin: 'حنطية',
    );

    expect(c2.trait('gender_female'), isTrue);
    expect(c2.trait('gender_male'), isFalse);
    expect(c2.trait('hijab'), isTrue);
    expect(c2.trait('headwear'), isTrue);
    expect(c2.trait('olive_skin'), isTrue);
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

  test('PreferencesService custom cards full CRUD lifecycle', () async {
    expect(PreferencesService.getCustomCards(), isEmpty);

    // 1. Add custom card
    final card = {
      'id': 'test_card_1',
      'category': 'أسئلتنا الخاصة',
      'type': 'سؤال',
      'level': 'خاص',
      'text': 'ما هو أجمل يوم قضيناه سوياً؟',
      'purpose': 'استذكار الذكريات الجميلة',
    };
    await PreferencesService.addCustomCard(card);

    var cards = PreferencesService.getCustomCards();
    expect(cards.length, equals(1));
    expect(cards.first['text'], equals('ما هو أجمل يوم قضيناه سوياً؟'));

    // 2. Update custom card
    final updatedCard = Map<String, dynamic>.from(card);
    updatedCard['text'] = 'ما هي أفضل لحظة عشناها هذا العام؟';
    await PreferencesService.updateCustomCard('test_card_1', updatedCard);

    cards = PreferencesService.getCustomCards();
    expect(cards.length, equals(1));
    expect(cards.first['text'], equals('ما هي أفضل لحظة عشناها هذا العام؟'));

    // 3. Delete custom card
    await PreferencesService.deleteCustomCard('test_card_1');
    cards = PreferencesService.getCustomCards();
    expect(cards, isEmpty);
  });

  test('KnowMeQuestion model serialization and properties', () {
    const q = KnowMeQuestion(
      id: 'km_99',
      category: 'التفضيلات اليومية',
      question: 'وش مشروبي المفضل في الصباح؟',
      hint: 'شاي، قهوة سوداء، لاتيه، عصير',
    );

    final json = q.toJson();
    expect(json['id'], equals('km_99'));
    expect(json['hint'], equals('شاي، قهوة سوداء، لاتيه، عصير'));

    final parsed = KnowMeQuestion.fromJson(json);
    expect(parsed.id, equals('km_99'));
    expect(parsed.question, equals('وش مشروبي المفضل في الصباح؟'));
    expect(parsed.category, equals('التفضيلات اليومية'));
  });

  test('GameStats points, levels, and badge unlocking', () async {
    final initialStats = PreferencesService.getStats();
    expect(initialStats.totalPoints, equals(0));
    expect(initialStats.level, equals(1));

    // Record game finished with win
    await PreferencesService.recordGameFinished(
      isGuessWin: true,
      pointsEarned: 25,
    );

    final afterGameStats = PreferencesService.getStats();
    expect(afterGameStats.gamesPlayed, equals(1));
    expect(afterGameStats.correctGuesses, equals(1));
    expect(afterGameStats.totalPoints, greaterThanOrEqualTo(25));

    // Verify first_game achievement is unlocked
    final achievements = PreferencesService.getAchievements();
    final firstGameBadge =
        achievements.firstWhere((a) => a.id == 'first_game');
    expect(firstGameBadge.isUnlocked, isTrue);
  });
}
