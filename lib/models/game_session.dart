import 'couples_card.dart';

enum SessionStep {
  intro,
  question,
  actionOrGratitude,
  reflection,
  completed,
}

class SessionStepInfo {
  final SessionStep step;
  final String title;
  final String description;
  final String emoji;
  final CouplesCard? card;

  const SessionStepInfo({
    required this.step,
    required this.title,
    required this.description,
    required this.emoji,
    this.card,
  });
}

class StructuredSession {
  final List<CouplesCard> allCards;
  late final List<SessionStepInfo> steps;
  int currentStepIndex = 0;

  StructuredSession({required this.allCards}) {
    steps = _generateSteps();
  }

  List<SessionStepInfo> _generateSteps() {
    // 1. Warm-up / Intro prompt
    final intros = allCards
        .where((c) => c.level == 'خفيف' || c.type == 'سؤال')
        .toList()
      ..shuffle();
    final introCard = intros.isNotEmpty ? intros.first : null;

    // 2. Deep conversation question
    final questions = allCards
        .where((c) =>
            c.type == 'سؤال' && (c.level == 'متوسط' || c.level == 'عميق'))
        .toList()
      ..shuffle();
    final deepCard = questions.isNotEmpty
        ? questions.first
        : (intros.length > 1 ? intros[1] : null);

    // 3. Gratitude or Light Challenge
    final actions = allCards
        .where((c) => c.type == 'امتنان' || c.type == 'تحدّي' || c.type == 'تقدير')
        .toList()
      ..shuffle();
    final actionCard = actions.isNotEmpty ? actions.first : null;

    // 4. Closing reflection
    final reflections = allCards
        .where((c) => c.type == 'تأمل' || c.category == 'تأمل ومراجعة')
        .toList()
      ..shuffle();
    final reflectionCard = reflections.isNotEmpty ? reflections.first : null;

    return [
      SessionStepInfo(
        step: SessionStep.intro,
        title: 'المقدمة الخفيفة',
        description: 'بداية ممتعة ولطيفة لكسر الروتين',
        emoji: '🌱',
        card: introCard,
      ),
      SessionStepInfo(
        step: SessionStep.question,
        title: 'سؤال التقارب',
        description: 'حوار هادئ وصادق يقرّب المسافات',
        emoji: '💜',
        card: deepCard,
      ),
      SessionStepInfo(
        step: SessionStep.actionOrGratitude,
        title: 'الامتنان والتقدير',
        description: 'كلمة شكر وتعبير عن الامتنان للطرف الآخر',
        emoji: '✨',
        card: actionCard,
      ),
      SessionStepInfo(
        step: SessionStep.reflection,
        title: 'التأمل الختامي',
        description: 'لحظة هدوء واستشعار للدفء بينكما',
        emoji: '🌙',
        card: reflectionCard,
      ),
    ];
  }

  bool get isCompleted => currentStepIndex >= steps.length;
  SessionStepInfo? get currentStep =>
      isCompleted ? null : steps[currentStepIndex];
  double get progress => steps.isEmpty ? 0 : currentStepIndex / steps.length;

  void next() {
    if (currentStepIndex < steps.length) {
      currentStepIndex++;
    }
  }

  void previous() {
    if (currentStepIndex > 0) {
      currentStepIndex--;
    }
  }
}
