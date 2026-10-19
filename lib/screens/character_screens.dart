import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/game_data_service.dart';
import '../services/preferences_service.dart';
import '../theme/app_theme.dart';
import 'pass_device_screen.dart';

// ─── 1. Character Intro Screen ───────────────────────────
class CharacterIntroScreen extends StatelessWidget {
  const CharacterIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('خمن الشخصية')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 14),
              const Text('🎭', textAlign: TextAlign.center, style: TextStyle(fontSize: 70)),
              const SizedBox(height: 8),
              const Text(
                'مين الشخصية اللي في بالك؟',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'كل لاعب يختار شخصية سرية، وبعدها يسأل أسئلة إجابتها «نعم» أو «لا» ويستبعد الشخصيات التي لا تنطبق عليها الصفات حتى يخمن الشخصية الصحيحة.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.muted,
                  height: 1.8,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              const _FeatureRow(icon: Icons.face_retouching_natural, text: '24 شخصية بملامح وأزياء عربية متنوعة'),
              const _FeatureRow(icon: Icons.help_outline_rounded, text: 'صفات واضحة: لحية، نظارة، حجاب، ثوب...'),
              const _FeatureRow(icon: Icons.shield_rounded, text: 'شاشة حماية عند تسليم الجهاز لمنع كشف السر'),
              const _FeatureRow(icon: Icons.swap_horiz_rounded, text: 'لعب بالتناوب على نفس الجهاز مع زر تخطي'),
              const Spacer(),
              FilledButton.icon(
                onPressed: () async {
                  final chars = await GameDataService.loadCharacters();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CharacterSelectionScreen(characters: chars),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('ابدأ اختيار الشخصيات'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.palePurple,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.purple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 2. Character Selection Screen ───────────────────────
class CharacterSelectionScreen extends StatefulWidget {
  final List<Character> characters;
  const CharacterSelectionScreen({super.key, required this.characters});

  @override
  State<CharacterSelectionScreen> createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> {
  int selectingPlayer = 1;
  Character? selected;
  Character? secret1;
  Character? secret2;

  void _onConfirm() {
    if (selected == null) return;

    if (selectingPlayer == 1) {
      secret1 = selected;
      selected = null;
      PassDeviceScreen.show(
        context,
        targetPlayer: 'اللاعب 2',
        instruction: 'سلّم الجهاز للاعب الثاني ليختار شخصيته السرية بهدوء.',
        onReady: () {
          setState(() {
            selectingPlayer = 2;
          });
        },
      );
    } else {
      secret2 = selected;
      PassDeviceScreen.show(
        context,
        targetPlayer: 'اللاعب 1',
        instruction: 'تم اختيار الشخصيتين السريتين بنجاح! يبدأ اللاعب الأول بطرح السؤال الأول.',
        onReady: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => GuessGameScreen(
                characters: widget.characters,
                secret1: secret1!,
                secret2: secret2!,
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختيار الشخصية • اللاعب $selectingPlayer'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.palePurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.visibility_off_rounded, color: AppColors.purple),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'اللاعب $selectingPlayer: اختر شخصيتك السرية دون أن يراها الطرف الآخر.',
                        style: const TextStyle(
                          color: AppColors.deepPurple,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: widget.characters.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, i) {
                  final c = widget.characters[i];
                  final isSelected = selected?.id == c.id;
                  return InkWell(
                    onTap: () => setState(() => selected = c),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.palePurple : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.purple : const Color(0xFFEAE6F4),
                          width: isSelected ? 2.5 : 1,
                        ),
                        boxShadow: isSelected ? AppShadows.cardShadow : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(c.emoji, style: const TextStyle(fontSize: 34)),
                          const SizedBox(height: 6),
                          Text(
                            c.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? AppColors.purple : AppColors.ink,
                            ),
                          ),
                          if (isSelected)
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(Icons.check_circle, size: 16, color: AppColors.purple),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: selected == null ? null : _onConfirm,
                  child: Text(
                    selectingPlayer == 1
                        ? 'تثبيت وتسليم الجهاز للاعب 2'
                        : 'تثبيت وبدء اللعبة',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 3. Guess Game Screen ────────────────────────────────
class GuessGameScreen extends StatefulWidget {
  final List<Character> characters;
  final Character secret1;
  final Character secret2;

  const GuessGameScreen({
    super.key,
    required this.characters,
    required this.secret1,
    required this.secret2,
  });

  @override
  State<GuessGameScreen> createState() => _GuessGameScreenState();
}

class _GuessGameScreenState extends State<GuessGameScreen> {
  int player = 1;
  String? pendingTrait;
  String? pendingQuestion;
  bool answering = false;
  String? winner;
  final Set<String> eliminated1 = {};
  final Set<String> eliminated2 = {};

  static const traits = <Map<String, String>>[
    {'key': 'gender_male', 'label': 'هل الشخصية رجل؟', 'short': 'رجل'},
    {'key': 'gender_female', 'label': 'هل الشخصية امرأة؟', 'short': 'امرأة'},
    {'key': 'older', 'label': 'هل الشخصية كبيرة في السن؟', 'short': 'كبيرة بالسن'},
    {'key': 'glasses', 'label': 'هل تلبس نظارة؟', 'short': 'نظارة'},
    {'key': 'beard', 'label': 'هل لديه لحية أو شارب؟', 'short': 'لحية/شارب'},
    {'key': 'headwear', 'label': 'هل يرتدي غطاء رأس أو شماغ؟', 'short': 'شماغ/طاقية'},
    {'key': 'hijab', 'label': 'هل ترتدي حجابًا؟', 'short': 'حجاب'},
    {'key': 'thobe', 'label': 'هل يرتدي ثوبًا؟', 'short': 'ثوب'},
    {'key': 'light_skin', 'label': 'هل بشرتها فاتحة؟', 'short': 'بشرة فاتحة'},
    {'key': 'dark_hair', 'label': 'هل شعرها داكن/أسود؟', 'short': 'شعر داكن'},
  ];

  Set<String> get currentEliminated => player == 1 ? eliminated1 : eliminated2;
  List<Character> get available =>
      widget.characters.where((c) => !currentEliminated.contains(c.id)).toList();

  void _ask(Map<String, String> t) {
    setState(() {
      pendingTrait = t['key'];
      pendingQuestion = t['label'];
      answering = true;
    });

    // P0: Pass device to the answering player so they answer privately!
    PassDeviceScreen.show(
      context,
      targetPlayer: 'اللاعب ${player == 1 ? 2 : 1}',
      instruction: 'أجب على السؤال بصدق بناءً على شخصيتك السرية دون كشفها.',
      onReady: () {
        // Now ready to answer on screen
      },
    );
  }

  void _answer(bool yes) {
    final key = pendingTrait!;
    // Automatically eliminate candidates that don't match the answer
    for (final c in widget.characters) {
      if (c.trait(key) != yes) {
        currentEliminated.add(c.id);
      }
    }

    final nextPlayer = player == 1 ? 2 : 1;

    PassDeviceScreen.show(
      context,
      targetPlayer: 'اللاعب $nextPlayer',
      instruction: 'تم تسجيل الإجابة وتحديث قائمة الشخصيات المتبقية. الدور الآن لك!',
      onReady: () {
        setState(() {
          answering = false;
          pendingTrait = null;
          pendingQuestion = null;
          player = nextPlayer;
        });
      },
    );
  }

  void _confirmGuess(Character c) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد التخمين'),
        content: Text('هل أنت متأكد أن شخصية الشريك السرية هي «${c.name}»؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('رجوع'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _makeGuess(c);
            },
            child: const Text('تخمين نهائي'),
          ),
        ],
      ),
    );
  }

  void _makeGuess(Character c) {
    final target = player == 1 ? widget.secret2 : widget.secret1;
    if (c.id == target.id) {
      PreferencesService.recordGamePlay();
      setState(() => winner = 'اللاعب $player');
    } else {
      currentEliminated.add(c.id);
      final nextPlayer = player == 1 ? 2 : 1;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ليست «${c.name}»! تم استبعادها، وانتقل الدور للاعب $nextPlayer.'),
        ),
      );
      PassDeviceScreen.show(
        context,
        targetPlayer: 'اللاعب $nextPlayer',
        instruction: 'التخمين لم يكن صحيحًا. انتقل الدور إليك الآن!',
        onReady: () {
          setState(() {
            player = nextPlayer;
          });
        },
      );
    }
  }

  void _skipTurn() {
    final nextPlayer = player == 1 ? 2 : 1;
    PassDeviceScreen.show(
      context,
      targetPlayer: 'اللاعب $nextPlayer',
      instruction: 'تم تخطي الدور. الدور لك الآن!',
      onReady: () {
        setState(() => player = nextPlayer);
      },
    );
  }

  void _restart() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CharacterSelectionScreen(characters: widget.characters),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خمن الشخصية'),
        actions: [
          IconButton(
            tooltip: 'إعادة اللعب',
            onPressed: _restart,
            icon: const Icon(Icons.replay_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: winner != null
            ? _buildWinnerView()
            : answering
                ? _buildAnswerView()
                : _buildGameView(),
      ),
    );
  }

  Widget _buildGameView() {
    return Column(
      children: [
        // Header
        Container(
          margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  player == 1 ? '1️⃣' : '2️⃣',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'دور اللاعب $player',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'اختر سؤالاً من الأسئلة أو اضغط شخصية لتخمينها',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Traits bar
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: traits.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final t = traits[i];
              return ActionChip(
                backgroundColor: AppColors.palePurple,
                side: BorderSide.none,
                label: Text(
                  t['short']!,
                  style: const TextStyle(
                    color: AppColors.deepPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onPressed: () => _ask(t),
              );
            },
          ),
        ),

        // Stats row
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
          child: Row(
            children: [
              Text(
                'الشخصيات المتبقية: ${available.length}',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              const Text(
                'اضغط شخصية للتخمين',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),

        // Characters Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: widget.characters.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, i) {
              final c = widget.characters[i];
              final out = currentEliminated.contains(c.id);
              return InkWell(
                onTap: out ? null : () => _confirmGuess(c),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: out ? AppColors.disabledBg : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: out ? Colors.transparent : AppColors.cardBorder,
                    ),
                  ),
                  child: Opacity(
                    opacity: out ? 0.25 : 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(c.emoji, style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 4),
                        Text(
                          c.name,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        if (out)
                          const Text(
                            'مستبعدة',
                            style: TextStyle(fontSize: 9, color: AppColors.muted),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Bottom skip bar (Always visible skip button - P0)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _skipTurn,
              icon: const Icon(Icons.skip_next_rounded),
              label: const Text('تخطي الدور للطرف الآخر'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerView() {
    final answeringPlayer = player == 1 ? 2 : 1;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          const Text('🤫', textAlign: TextAlign.center, style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'دور اللاعب $answeringPlayer بالإجابة',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'أجب بصدق عن شخصيتك السرية، ولا تظهرها للشريك.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.palePurple,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              pendingQuestion ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                color: AppColors.deepPurple,
                fontWeight: FontWeight.w900,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => _answer(true),
            child: const Text('نعم 👍'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _answer(false),
            child: const Text('لا 👎'),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildWinnerView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            const Text(
              'مبروووك!',
              style: TextStyle(
                fontSize: 32,
                color: AppColors.deepPurple,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$winner فاز بالتخمين الصحيح! 💜',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: AppColors.ink, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _restart,
              icon: const Icon(Icons.replay_rounded),
              label: const Text('جولة ثانية جديدة'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('الرجوع للرئيسية'),
            ),
          ],
        ),
      ),
    );
  }
}
