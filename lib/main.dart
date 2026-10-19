import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'extra_games.dart';

void main() => runApp(const ArabicCouplesGame());

const purple = Color(0xFF7047D7);
const deepPurple = Color(0xFF45218D);
const palePurple = Color(0xFFF2EDFF);
const ink = Color(0xFF25213A);
const muted = Color(0xFF77728C);

class ArabicCouplesGame extends StatelessWidget {
  const ArabicCouplesGame({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'من أنا؟',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: purple),
          scaffoldBackgroundColor: const Color(0xFFFBFAFF),
          fontFamily: 'Arial',
          appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFFBFAFF), foregroundColor: ink, centerTitle: true, elevation: 0),
        ),
        home: const HomeScreen(),
      );
}

class Character {
  final String id, name, emoji, gender, hair, skin;
  final bool older, glasses, beard, headwear, hijab, thobe;
  const Character({required this.id, required this.name, required this.emoji, required this.gender, required this.older, required this.glasses, required this.beard, required this.headwear, required this.hijab, required this.thobe, required this.hair, required this.skin});
  factory Character.fromJson(Map<String, dynamic> j) => Character(
    id: j['id'], name: j['name'], emoji: j['emoji'], gender: j['gender'], older: j['older'], glasses: j['glasses'], beard: j['beard'], headwear: j['headwear'], hijab: j['hijab'], thobe: j['thobe'], hair: j['hair'], skin: j['skin']);
  bool trait(String key) => switch (key) {
    'gender_male' => gender == 'رجل', 'gender_female' => gender == 'امرأة', 'older' => older,
    'glasses' => glasses, 'beard' => beard, 'headwear' => headwear, 'hijab' => hijab,
    'thobe' => thobe, 'light_skin' => skin == 'فاتحة', 'dark_hair' => hair == 'داكن', _ => false,
  };
}

class GameData {
  static Future<List<Character>> characters() async {
    final raw = await rootBundle.loadString('assets/characters.json');
    return (jsonDecode(raw) as List).map((e) => Character.fromJson(e)).toList();
  }
  static Future<List<Map<String, dynamic>>> cards() async {
    final raw = await rootBundle.loadString('assets/couples_cards.json');
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 18),
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [deepPurple, purple]), borderRadius: BorderRadius.circular(30)), child: Column(children: [
        const Text('💜', style: TextStyle(fontSize: 34)), const SizedBox(height: 8),
        const Text('من أنا؟', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8), const Text('لعبة تخمين الشخصيات والتقارب', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 16), const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('👳🏻‍♂️', style: TextStyle(fontSize: 44)), SizedBox(width: 12), Text('❔', style: TextStyle(fontSize: 34)), SizedBox(width: 12), Text('🧕🏻', style: TextStyle(fontSize: 44))]),
      ])),
      const SizedBox(height: 24),
      const Text('اختر طريقة اللعب', textAlign: TextAlign.right, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink)),
      const SizedBox(height: 12),
      _HomeTile(icon: Icons.people_alt_rounded, title: 'خمن الشخصية', subtitle: '24 شخصية بملامح عربية وأسئلة نعم أو لا', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CharacterIntroScreen()))),
      const SizedBox(height: 12),
      _HomeTile(icon: Icons.favorite_rounded, title: 'أسئلة وتحديات للأزواج', subtitle: 'بطاقات حوار وتقارب باللهجة العربية', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CouplesCardsScreen()))),
      const SizedBox(height: 12),
      _HomeTile(icon: Icons.auto_awesome_rounded, title: 'ألعاب إضافية', subtitle: 'سؤال اليوم، هذا أو ذاك، خمن إجابتي والمفضلة', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoreModesScreen()))),
      const SizedBox(height: 20),
      const Text('اللعب على جهاز واحد متاح في هذه النسخة. اللعب عن بُعد يحتاج ربط قاعدة بيانات قبل النشر.', textAlign: TextAlign.center, style: TextStyle(color: muted, height: 1.6, fontSize: 12)),
    ]))),
  );
}

class _HomeTile extends StatelessWidget {
  final IconData icon; final String title, subtitle; final VoidCallback onTap;
  const _HomeTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(color: Colors.white, borderRadius: BorderRadius.circular(22), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE6DFFF))), child: Row(children: [Container(width: 54, height: 54, decoration: BoxDecoration(color: palePurple, borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: purple, size: 28)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: ink)), const SizedBox(height: 5), Text(subtitle, textAlign: TextAlign.right, style: const TextStyle(color: muted, height: 1.4, fontSize: 13))])), const Icon(Icons.chevron_left_rounded, color: purple)]))));
}

class CharacterIntroScreen extends StatelessWidget {
  const CharacterIntroScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('خمن الشخصية')), body: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const SizedBox(height: 14), const Text('🎭', textAlign: TextAlign.center, style: TextStyle(fontSize: 70)),
    const Text('مين الشخصية اللي في بالك؟', textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: ink)),
    const SizedBox(height: 12), const Text('كل لاعب يختار شخصية سرية، وبعدها يسأل أسئلة إجابتها نعم أو لا ويحذف الشخصيات اللي ما تنطبق عليها الصفات إلى أن يخمّن الشخصية الصحيحة.', textAlign: TextAlign.center, style: TextStyle(color: muted, height: 1.8, fontSize: 15)),
    const SizedBox(height: 22),
    const _RuleRow(text: '24 شخصية عربية متنوعة'), const _RuleRow(text: 'ملامح وصفات واضحة للتخمين'), const _RuleRow(text: 'لعب بالتناوب على نفس الجهاز'), const _RuleRow(text: 'اختيار الشخصية يبقى سرّيًا عن اللاعب الآخر'),
    const Spacer(), FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: purple, padding: const EdgeInsets.all(17)), icon: const Icon(Icons.play_arrow_rounded), label: const Text('ابدأ اللعب', style: TextStyle(fontWeight: FontWeight.bold)), onPressed: () async { final chars = await GameData.characters(); if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CharacterSelectionScreen(characters: chars))); }),
  ])));
}

class _RuleRow extends StatelessWidget { final String text; const _RuleRow({required this.text}); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [const Icon(Icons.check_circle_rounded, color: purple), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(color: ink, fontSize: 14)))])); }

class CharacterSelectionScreen extends StatefulWidget {
  final List<Character> characters;
  const CharacterSelectionScreen({super.key, required this.characters});
  @override State<CharacterSelectionScreen> createState() => _CharacterSelectionScreenState();
}
class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> {
  int selectingPlayer = 1;
  Character? selected;
  Character? secret1;
  Character? secret2;
  bool revealSelected = false;
  void continueSelection() {
    if (selected == null) return;
    if (selectingPlayer == 1) { secret1 = selected; selectingPlayer = 2; selected = null; revealSelected = false; }
    else { secret2 = selected; Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GuessGameScreen(characters: widget.characters, secret1: secret1!, secret2: secret2!))); return; }
    setState(() {});
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('اختيار الشخصية • اللاعب $selectingPlayer')), body: Column(children: [
    Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 12), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: palePurple, borderRadius: BorderRadius.circular(18)), child: Text(revealSelected ? 'تأكد أن اللاعب الآخر ما يشوف اختيارك، ثم اضغط متابعة.' : 'اللاعب $selectingPlayer: اختر شخصية سرية لك ولا تعلّم اللاعب الثاني من هي.', textAlign: TextAlign.center, style: const TextStyle(color: deepPurple, fontWeight: FontWeight.w700, height: 1.5)))),
    Expanded(child: GridView.builder(padding: const EdgeInsets.symmetric(horizontal: 14), itemCount: widget.characters.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: .78), itemBuilder: (context, i) { final c = widget.characters[i]; final isSelected = selected?.id == c.id; return InkWell(onTap: () => setState(() { selected = c; revealSelected = true; }), borderRadius: BorderRadius.circular(15), child: Container(decoration: BoxDecoration(color: isSelected ? palePurple : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: isSelected ? purple : const Color(0xFFEAE6F4), width: isSelected ? 2.5 : 1)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(c.emoji, style: const TextStyle(fontSize: 35)), const SizedBox(height: 5), Text(c.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: ink)), if (isSelected) const Icon(Icons.check_circle, size: 17, color: purple)]))); })),
    Padding(padding: const EdgeInsets.all(16), child: SizedBox(width: double.infinity, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: purple, padding: const EdgeInsets.all(16)), onPressed: selected == null ? null : continueSelection, child: Text(selectingPlayer == 1 ? 'تثبيت الاختيار وتسليم الجهاز' : 'ابدأ الجولة', style: const TextStyle(fontWeight: FontWeight.bold))))),
  ]));
}

class GuessGameScreen extends StatefulWidget {
  final List<Character> characters; final Character secret1, secret2;
  const GuessGameScreen({super.key, required this.characters, required this.secret1, required this.secret2});
  @override State<GuessGameScreen> createState() => _GuessGameScreenState();
}
class _GuessGameScreenState extends State<GuessGameScreen> {
  int player = 1;
  String? pendingTrait;
  String? pendingQuestion;
  bool answering = false;
  bool? lastAnswer;
  String? winner;
  final Set<String> eliminated1 = {};
  final Set<String> eliminated2 = {};
  static const traits = <Map<String, String>>[
    {'key':'gender_male','label':'هل الشخصية رجل؟','short':'رجل'},
    {'key':'gender_female','label':'هل الشخصية امرأة؟','short':'امرأة'},
    {'key':'older','label':'هل الشخصية كبيرة في السن؟','short':'كبيرة في السن'},
    {'key':'glasses','label':'هل تلبس نظارة؟','short':'تلبس نظارة'},
    {'key':'beard','label':'هل عندها لحية؟','short':'لديه لحية'},
    {'key':'headwear','label':'هل تلبس غطاء رأس؟','short':'غطاء رأس'},
    {'key':'hijab','label':'هل ترتدي حجابًا؟','short':'حجاب'},
    {'key':'thobe','label':'هل تلبس ثوبًا؟','short':'ثوب'},
    {'key':'light_skin','label':'هل بشرتها فاتحة؟','short':'بشرة فاتحة'},
    {'key':'dark_hair','label':'هل شعرها داكن؟','short':'شعر داكن'},
  ];
  Character get otherSecret => player == 1 ? widget.secret2 : widget.secret1;
  Set<String> get eliminated => player == 1 ? eliminated1 : eliminated2;
  List<Character> get available => widget.characters.where((c) => !eliminated.contains(c.id)).toList();
  void ask(Map<String,String> t) { setState(() { pendingTrait = t['key']; pendingQuestion = t['label']; answering = true; }); }
  void answer(bool yes) {
    final key = pendingTrait!;
    // The answering player answers truthfully about their secret character.
    // Remove every candidate whose trait does not match the answer.
    for (final c in widget.characters) { if (c.trait(key) != yes) eliminated.add(c.id); }
    setState(() { lastAnswer = yes; answering = false; pendingTrait = null; pendingQuestion = null; player = player == 1 ? 2 : 1; });
  }
  void guess(Character c) {
    if (c.id == (player == 1 ? widget.secret2.id : widget.secret1.id)) { setState(() => winner = 'اللاعب $player'); }
    else { setState(() { (player == 1 ? eliminated1 : eliminated2).add(c.id); player = player == 1 ? 2 : 1; }); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مو هي الشخصية! تم استبعادها، ودور اللاعب الثاني.'))); }
  }
  void reset() { Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CharacterSelectionScreen(characters: widget.characters))); }
  @override Widget build(BuildContext context) {
    final targetToReveal = player == 1 ? widget.secret2 : widget.secret1;
    return Scaffold(appBar: AppBar(title: const Text('خمن الشخصية'), actions: [IconButton(tooltip: 'إعادة اللعب', onPressed: reset, icon: const Icon(Icons.refresh_rounded))]), body: winner != null ? _winnerView() : answering ? _answerView() : _gameView(targetToReveal));
  }
  Widget _gameView(Character targetToReveal) => Column(children: [
    Container(width: double.infinity, margin: const EdgeInsets.fromLTRB(14, 4, 14, 10), padding: const EdgeInsets.all(13), decoration: BoxDecoration(gradient: const LinearGradient(colors: [deepPurple, purple]), borderRadius: BorderRadius.circular(18)), child: Column(children: [Text('دور اللاعب $player', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)), const SizedBox(height: 4), const Text('اسأل سؤالًا أو اضغط على شخصية لتخمينها', style: TextStyle(color: Colors.white, fontSize: 12))])),
    SizedBox(height: 46, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), children: traits.map((t) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: ActionChip(backgroundColor: palePurple, side: BorderSide.none, label: Text(t['short']!, style: const TextStyle(color: deepPurple, fontSize: 11, fontWeight: FontWeight.w700)), onPressed: () => ask(t)))).toList())),
    Padding(padding: const EdgeInsets.fromLTRB(16, 9, 16, 4), child: Row(children: [Expanded(child: Text('الشخصيات المتبقية: ${available.length}', style: const TextStyle(color: ink, fontWeight: FontWeight.w800))), const Text('اضغط على شخصية للتخمين', style: TextStyle(color: muted, fontSize: 11))])),
    Expanded(child: GridView.builder(padding: const EdgeInsets.all(12), itemCount: widget.characters.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: .78), itemBuilder: (context, i) { final c = widget.characters[i]; final out = eliminated.contains(c.id); return InkWell(onTap: out ? null : () => _confirmGuess(c), borderRadius: BorderRadius.circular(14), child: AnimatedContainer(duration: const Duration(milliseconds: 160), decoration: BoxDecoration(color: out ? const Color(0xFFE8E6ED) : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: out ? Colors.transparent : const Color(0xFFE6DFFF))), child: Opacity(opacity: out ? .25 : 1, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(c.emoji, style: const TextStyle(fontSize: 34)), const SizedBox(height: 4), Text(c.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: ink)), if (out) const Text('مستبعدة', style: TextStyle(fontSize: 9, color: muted))])))); })),
    Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 14), child: SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => setState(() { player = player == 1 ? 2 : 1; }), icon: const Icon(Icons.swap_horiz_rounded), label: const Text('تخطي الدور')))),
  ]);
  void _confirmGuess(Character c) { showDialog<void>(context: context, builder: (ctx) => AlertDialog(title: const Text('تأكيد التخمين'), content: Text('هل تتوقع أن الشخصية هي ${c.name}؟'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('رجوع')), FilledButton(onPressed: () { Navigator.pop(ctx); guess(c); }, child: const Text('تخمين'))])); }
  Widget _answerView() => SafeArea(child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Spacer(), const Text('🤫', textAlign: TextAlign.center, style: TextStyle(fontSize: 62)), const SizedBox(height: 18), Text('اللاعب ${player == 1 ? 2 : 1} يجاوب', textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: ink)), const SizedBox(height: 10), const Text('جاوب بناءً على شخصيتك السرية، ولا تكشف اسمها.', textAlign: TextAlign.center, style: TextStyle(color: muted, height: 1.5)), const SizedBox(height: 24), Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: palePurple, borderRadius: BorderRadius.circular(22)), child: Text(pendingQuestion ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, color: deepPurple, fontWeight: FontWeight.w900))), const SizedBox(height: 20), FilledButton(onPressed: () => answer(true), style: FilledButton.styleFrom(backgroundColor: purple, padding: const EdgeInsets.all(16)), child: const Text('نعم')), const SizedBox(height: 10), OutlinedButton(onPressed: () => answer(false), style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)), child: const Text('لا')), const Spacer()])));
  Widget _winnerView() => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('🎉', style: TextStyle(fontSize: 76)), const SizedBox(height: 12), const Text('مبروك!', style: TextStyle(fontSize: 30, color: deepPurple, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text('$winner فاز بالتخمين الصحيح', style: const TextStyle(fontSize: 18, color: ink)), const SizedBox(height: 22), FilledButton.icon(onPressed: reset, icon: const Icon(Icons.replay_rounded), label: const Text('العبوا مرة ثانية'))])));
}

class CouplesCardsScreen extends StatefulWidget {
  const CouplesCardsScreen({super.key});
  @override
  State<CouplesCardsScreen> createState() => _CouplesCardsScreenState();
}

class _CouplesCardsScreenState extends State<CouplesCardsScreen> {
  List<Map<String, dynamic>> cards = [];
  Map<String, dynamic>? current;
  bool loading = true;
  final random = Random();

  @override
  void initState() {
    super.initState();
    GameData.cards().then((value) {
      if (mounted) setState(() { cards = value; loading = false; });
    }).catchError((_) {
      if (mounted) setState(() => loading = false);
    });
  }

  void next() {
    if (cards.isEmpty) return;
    setState(() => current = cards[random.nextInt(cards.length)]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أسئلة وتحديات')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Text('افتحوا موضوع جديد 💜', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: ink)),
                  const SizedBox(height: 12),
                  const Text('اسحبوا بطاقة وتبادلوا الإجابات براحتكم.', textAlign: TextAlign.center, style: TextStyle(color: muted)),
                  const SizedBox(height: 28),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [deepPurple, purple]),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: const [BoxShadow(color: Color(0x227047D7), blurRadius: 24, offset: Offset(0, 10))],
                        ),
                        child: current == null
                            ? const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.style_rounded, color: Colors.white, size: 70),
                                  SizedBox(height: 15),
                                  Text('بطاقة جديدة بانتظاركم', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${current!['category']} • ${current!['type']}', style: const TextStyle(color: Color(0xFFE4D9FF), fontSize: 13)),
                                  const SizedBox(height: 20),
                                  Text('${current!['text']}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 23, height: 1.6, fontWeight: FontWeight.w800)),
                                  if ((current!['purpose'] ?? '').toString().isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    Text('${current!['purpose']}', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFEDE7FF), height: 1.5)),
                                  ],
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: purple, padding: const EdgeInsets.all(17)),
                      onPressed: cards.isEmpty ? null : next,
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(current == null ? 'اسحب بطاقة' : 'بطاقة ثانية', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('${cards.length} بطاقة متاحة', style: const TextStyle(color: muted, fontSize: 12)),
                ],
              ),
            ),
    );
  }
}
