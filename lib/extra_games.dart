import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _purple = Color(0xFF7047D7);
const _deep = Color(0xFF45218D);
const _pale = Color(0xFFF2EDFF);
const _ink = Color(0xFF25213A);
const _muted = Color(0xFF77728C);

class MoreModesScreen extends StatefulWidget {
  const MoreModesScreen({super.key});
  @override State<MoreModesScreen> createState() => _MoreModesScreenState();
}

class _MoreModesScreenState extends State<MoreModesScreen> {
  List<Map<String, dynamic>> cards = [];
  List<Map<String, dynamic>> customCards = [];
  Set<String> favorites = {};
  bool loading = true;
  final random = Random();
  String selectedCategory = 'الكل';
  Map<String, dynamic>? current;
  final customController = TextEditingController();
  final categories = ['الكل','التقارب','الامتنان','تحديات لطيفة','التخمين','اختاروا سوا','تأمل ومراجعة'];
  final pairs = const [
    ['قهوة ☕','شاي 🍵'], ['البحر 🌊','الجبل ⛰️'], ['سهرة في البيت 🏠','طلعة عفوية 🚗'],
    ['تخطيط مسبق 📅','مفاجأة 🎁'], ['فيلم كوميدي 😂','فيلم مغامرات 🧭'], ['رسالة 💌','مكالمة 📞'],
    ['فطور متأخر 🥞','عشاء هادئ 🍽️'], ['سفر ✈️','استكشاف مكان قريب 🚶']
  ];
  int pairIndex = 0;
  final answer1 = TextEditingController();
  final guess2 = TextEditingController();
  final answer2 = TextEditingController();
  final guess1 = TextEditingController();
  int guessStep = 0;
  String? dailyQuestion;

  @override void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString('assets/couples_cards.json');
      final loaded = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      final prefs = await SharedPreferences.getInstance();
      final savedCustom = prefs.getString('custom_couples_cards_v1');
      final today = DateTime.now();
      final dayKey = '${today.year}-${today.month}-${today.day}';
      final fav = prefs.getStringList('favorite_couples_cards_v1') ?? [];
      if (!mounted) return;
      setState(() {
        cards = loaded;
        customCards = savedCustom == null ? [] : (jsonDecode(savedCustom) as List).cast<Map<String, dynamic>>();
        favorites = fav.toSet();
        final pool = loaded.where((c) => c['type'] == 'سؤال' || c['type'] == 'تأمل' || c['type'] == 'تقدير').toList();
        final seed = dayKey.codeUnits.fold<int>(0, (a,b) => a + b);
        dailyQuestion = pool.isEmpty ? 'وش شيء بسيط يسعدك اليوم؟' : '${pool[seed % pool.length]['text']}';
        loading = false;
      });
    } catch (_) {
      if (mounted) setState(() { loading = false; dailyQuestion = 'وش شيء بسيط يسعدك اليوم؟'; });
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_couples_cards_v1', favorites.toList());
  }
  Future<void> _saveCustom() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_couples_cards_v1', jsonEncode(customCards));
  }
  List<Map<String,dynamic>> get filtered {
    final all = [...cards, ...customCards];
    return all.where((c) => selectedCategory == 'الكل' || c['category'] == selectedCategory).toList();
  }
  void _nextCard() {
    final pool = filtered;
    if (pool.isEmpty) return;
    setState(() {
      if (pool.length == 1) { current = pool.first; }
      else {
        Map<String,dynamic>? next;
        for (var i=0;i<8;i++) {
          final candidate = pool[random.nextInt(pool.length)];
          if (candidate['id'] != current?['id']) { next = candidate; break; }
        }
        current = next ?? pool.first;
      }
    });
  }
  void _addCustom() {
    final text = customController.text.trim();
    if (text.isEmpty) return;
    final id = 'custom_${DateTime.now().microsecondsSinceEpoch}';
    setState(() {
      customCards.add({'id':id,'category':'أسئلتنا الخاصة','type':'سؤال','level':'خاص','text':text,'purpose':'سؤال أضفتموه بأنفسكم.'});
      customController.clear();
    });
    _saveCustom();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('انضاف سؤالك إلى مجموعتكم الخاصة.')));
  }
  Widget _tile(IconData icon, String title, String subtitle, VoidCallback tap) => Card(
    elevation: 0, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFE8E1FA))),
    child: ListTile(contentPadding: const EdgeInsets.all(12), leading: Container(width:48,height:48,decoration:BoxDecoration(color:_pale,borderRadius:BorderRadius.circular(15)),child:Icon(icon,color:_purple)), title:Text(title,style:const TextStyle(color:_ink,fontWeight:FontWeight.w800)), subtitle:Text(subtitle,style:const TextStyle(color:_muted,height:1.4)), trailing:const Icon(Icons.chevron_left,color:_purple), onTap:tap));
  @override void dispose() { customController.dispose(); answer1.dispose(); guess2.dispose(); answer2.dispose(); guess1.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return Scaffold(appBar:AppBar(title:const Text('ألعاب إضافية')), body:loading ? const Center(child:CircularProgressIndicator()) : ListView(padding:const EdgeInsets.all(18),children:[
      Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(gradient:const LinearGradient(colors:[_deep,_purple]),borderRadius:BorderRadius.circular(24)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('خلّوا كل جولة مختلفة 💜',style:TextStyle(color:Colors.white,fontSize:23,fontWeight:FontWeight.w900)),SizedBox(height:7),Text('ألعاب خفيفة، أسئلة خاصة، وتحديات تناسب مزاجكم.',style:TextStyle(color:Colors.white,height:1.5))])),
      const SizedBox(height:14),
      _tile(Icons.wb_sunny_rounded,'سؤال اليوم','سؤال واحد تتناقشون فيه سوا',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>_DailyQuestionScreen(question:dailyQuestion ?? 'وش شيء بسيط يسعدك اليوم؟')))),
      _tile(Icons.compare_arrows_rounded,'هذا أو ذاك','اختيارات سريعة تكشف تفضيلاتكم',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>_ThisOrThatScreen(pairs:pairs)))),
      _tile(Icons.psychology_alt_rounded,'خمن إجابتي','اكتبوا إجاباتكم سرًا ثم اكشفوها معًا',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>_GuessAnswerScreen()))),
      _tile(Icons.style_rounded,'تصفح البطاقات','فلترة حسب النوع والمستوى، وتخطي أي بطاقة',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>_BrowseCardsScreen(cards:[...cards,...customCards],favorites:favorites,onToggleFavorite:(id) async {setState((){if(favorites.contains(id)){favorites.remove(id);}else{favorites.add(id);}});await _saveFavorites();},onAddCustom:_addCustom,controller:customController)))),
      _tile(Icons.bookmark_rounded,'المفضلة','ارجعوا للبطاقات اللي عجبتكم',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>_BrowseCardsScreen(cards:[...cards,...customCards].where((c)=>favorites.contains(c['id'])).toList(),favorites:favorites,onToggleFavorite:(id) async {setState((){if(favorites.contains(id)){favorites.remove(id);}else{favorites.add(id);}});await _saveFavorites();},onAddCustom:_addCustom,controller:customController)))),
      _tile(Icons.edit_note_rounded,'أضيفوا سؤالكم','أنشئوا بطاقات خاصة فيكم وتبقى على الجهاز',()=>_showAddQuestion()),
      const SizedBox(height:10),
      const Text('الأسئلة والمفضلة تُحفظ محليًا على هذا الجهاز. المزامنة بين هاتفين تحتاج إعداد الخدمة الخلفية في مرحلة لاحقة.',textAlign:TextAlign.center,style:TextStyle(color:_muted,fontSize:12,height:1.5))
    ]));
  }
  void _showAddQuestion() {
    showDialog<void>(context:context,builder:(ctx)=>AlertDialog(title:const Text('سؤال من عندكم'),content:TextField(controller:customController,autofocus:true,maxLines:3,decoration:const InputDecoration(hintText:'اكتبوا السؤال هنا',border:OutlineInputBorder())),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('إلغاء')),FilledButton(onPressed:(){Navigator.pop(ctx);_addCustom();},child:const Text('حفظ السؤال'))]));
  }
}

class _DailyQuestionScreen extends StatelessWidget {
  final String question; const _DailyQuestionScreen({required this.question});
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('سؤال اليوم')),body:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[const Icon(Icons.wb_sunny_rounded,color:_purple,size:68),const SizedBox(height:20),const Text('سؤال اليوم 💜',style:TextStyle(color:_deep,fontSize:25,fontWeight:FontWeight.w900)),const SizedBox(height:18),Container(width:double.infinity,padding:const EdgeInsets.all(24),decoration:BoxDecoration(color:_pale,borderRadius:BorderRadius.circular(24)),child:Text(question,textAlign:TextAlign.center,style:const TextStyle(color:_deep,fontSize:22,height:1.6,fontWeight:FontWeight.w800))),const SizedBox(height:18),const Text('كل واحد يجاوب براحة، وبعدها شاركوا الإجابات إذا كنتوا مستعدين. تقدرون تتخطون السؤال بأي وقت.',textAlign:TextAlign.center,style:TextStyle(color:_muted,height:1.6)),const SizedBox(height:24),FilledButton(onPressed:()=>Navigator.pop(context),child:const Text('خلصنا'))])));
}

class _ThisOrThatScreen extends StatefulWidget {
  final List<List<String>> pairs; const _ThisOrThatScreen({required this.pairs});
  @override State<_ThisOrThatScreen> createState()=>_ThisOrThatScreenState();
}
class _ThisOrThatScreenState extends State<_ThisOrThatScreen>{
  int index=0; final answers=<int,int>{};
  @override Widget build(BuildContext context){final p=widget.pairs[index%widget.pairs.length];return Scaffold(appBar:AppBar(title:const Text('هذا أو ذاك')),body:Padding(padding:const EdgeInsets.all(22),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text('اختيار ${index+1} من ${widget.pairs.length}',style:const TextStyle(color:_muted)),const SizedBox(height:24),const Text('كل واحد يختار بدون ما يتأثر بالثاني',textAlign:TextAlign.center,style:TextStyle(color:_ink,fontWeight:FontWeight.w800,fontSize:20)),const SizedBox(height:25),_choice(p[0],0),const SizedBox(height:12),_choice(p[1],1),const Spacer(),FilledButton.icon(onPressed:(){setState(()=>index=(index+1)%widget.pairs.length);},icon:const Icon(Icons.arrow_back),label:const Text('الاختيار التالي'))])));}
  Widget _choice(String text,int n)=>SizedBox(width:double.infinity,child:OutlinedButton(onPressed:(){setState(()=>answers[index]=n);ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('اخترت: $text')));},style:OutlinedButton.styleFrom(padding:const EdgeInsets.all(20),side:const BorderSide(color:_purple),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18))),child:Text(text,style:const TextStyle(color:_deep,fontSize:20,fontWeight:FontWeight.w800))));
}

class _GuessAnswerScreen extends StatefulWidget { @override State<_GuessAnswerScreen> createState()=>_GuessAnswerScreenState(); }
class _GuessAnswerScreenState extends State<_GuessAnswerScreen>{
  final own=TextEditingController(), guess=TextEditingController(); int step=0; String? lockedAnswer; bool revealed=false;
  final prompts=const ['وش أكثر شيء يرفع معنوياتك؟','وش المكان اللي تتمنى تزوره؟','وش الوجبة اللي تختارها في يوم مميز؟','وش نشاط تتمنى نجربه سوا؟'];
  int prompt=0;
  @override void dispose(){own.dispose();guess.dispose();super.dispose();}
  @override Widget build(BuildContext context){return Scaffold(appBar:AppBar(title:const Text('خمن إجابتي')),body:Padding(padding:const EdgeInsets.all(22),child:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.stretch,children:[const Icon(Icons.lock_outline,color:_purple,size:60),const SizedBox(height:18),Text(prompts[prompt],textAlign:TextAlign.center,style:const TextStyle(color:_deep,fontSize:23,fontWeight:FontWeight.w900,height:1.5)),const SizedBox(height:24),if(step==0)...[const Text('اللاعب الأول يكتب إجابته السرية. سلّموا الجهاز بدون ما يشوفها الطرف الثاني.',textAlign:TextAlign.center,style:TextStyle(color:_muted,height:1.5)),TextField(controller:own,onChanged:(_)=>setState((){}),decoration:const InputDecoration(labelText:'إجابتي السرية',border:OutlineInputBorder())),const SizedBox(height:14),FilledButton(onPressed:own.text.trim().isEmpty?null:(){setState(()=>step=1);},child:const Text('قفل الإجابة وتسليم الجهاز'))] else if(step==1)...[const Text('اللاعب الثاني يخمّن الإجابة قبل كشفها.',textAlign:TextAlign.center,style:TextStyle(color:_muted,height:1.5)),TextField(controller:guess,onChanged:(_)=>setState((){}),decoration:const InputDecoration(labelText:'تخميني',border:OutlineInputBorder())),const SizedBox(height:14),FilledButton(onPressed:guess.text.trim().isEmpty?null:(){setState(()=>step=2);},child:const Text('عرض الإجابة'))] else ...[Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:_pale,borderRadius:BorderRadius.circular(18)),child:Column(children:[const Text('الإجابة الأصلية',style:TextStyle(color:_muted)),const SizedBox(height:8),Text(own.text,style:const TextStyle(color:_deep,fontSize:21,fontWeight:FontWeight.w900)),const SizedBox(height:18),const Text('التخمين',style:TextStyle(color:_muted)),const SizedBox(height:8),Text(guess.text,style:const TextStyle(color:_ink,fontSize:19)),const SizedBox(height:12),Text(own.text.trim().toLowerCase()==guess.text.trim().toLowerCase()?'🎉 تخمين مطابق!':'💜 ناقشوا الإجابتين بدون درجات أو أحكام.',textAlign:TextAlign.center,style:const TextStyle(fontWeight:FontWeight.w800))])),const SizedBox(height:18),FilledButton(onPressed:(){setState((){step=0;own.clear();guess.clear();prompt=(prompt+1)%prompts.length;});},child:const Text('سؤال جديد'))]])));}
}

class _BrowseCardsScreen extends StatefulWidget {
  final List<Map<String,dynamic>> cards; final Set<String> favorites; final Future<void> Function(String) onToggleFavorite; final VoidCallback onAddCustom; final TextEditingController controller;
  const _BrowseCardsScreen({required this.cards,required this.favorites,required this.onToggleFavorite,required this.onAddCustom,required this.controller});
  @override State<_BrowseCardsScreen> createState()=>_BrowseCardsScreenState();
}
class _BrowseCardsScreenState extends State<_BrowseCardsScreen>{
  String category='الكل',level='الكل'; int index=0;
  @override Widget build(BuildContext context){
    final cats=['الكل',...widget.cards.map((e)=>'${e['category']}').toSet().toList()]; final levels=['الكل',...widget.cards.map((e)=>'${e['level']}').toSet().toList()];
    final pool=widget.cards.where((c)=>(category=='الكل'||c['category']==category)&&(level=='الكل'||c['level']==level)).toList();
    final card=pool.isEmpty?null:pool[index%pool.length];
    return Scaffold(appBar:AppBar(title:const Text('بطاقات الحوار')),body:Padding(padding:const EdgeInsets.all(16),child:Column(children:[SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:cats.map((c)=>Padding(padding:const EdgeInsets.only(left:6),child:ChoiceChip(label:Text(c),selected:category==c,onSelected:(_)=>setState(() { category=c; index=0; })))).toList())),const SizedBox(height:8),SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:levels.map((l)=>Padding(padding:const EdgeInsets.only(left:6),child:ChoiceChip(label:Text(l),selected:level==l,onSelected:(_)=>setState(() { level=l; index=0; })))).toList())),const SizedBox(height:12),Expanded(child:card==null?const Center(child:Text('ما فيه بطاقات بهذا الاختيار')):Container(width:double.infinity,padding:const EdgeInsets.all(22),decoration:BoxDecoration(gradient:const LinearGradient(colors:[_deep,_purple]),borderRadius:BorderRadius.circular(25)),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text('${card['category']} • ${card['level']}',style:const TextStyle(color:Colors.white70)),const SizedBox(height:20),Text('${card['text']}',textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:23,fontWeight:FontWeight.w800,height:1.6)),if('${card['purpose']}'.isNotEmpty)...[const SizedBox(height:16),Text('${card['purpose']}',textAlign:TextAlign.center,style:const TextStyle(color:Colors.white70,height:1.5))]]))),const SizedBox(height:12),Row(children:[Expanded(child:OutlinedButton.icon(onPressed:card==null?null:() async {await widget.onToggleFavorite('${card['id']}');setState((){});},icon:Icon(widget.favorites.contains(card?['id'])?Icons.bookmark:Icons.bookmark_border),label:Text(widget.favorites.contains(card?['id'])?'إزالة من المفضلة':'حفظ بالمفضلة'))),const SizedBox(width:8),Expanded(child:FilledButton.icon(onPressed:pool.isEmpty?null:()=>setState(()=>index=(index+1)%pool.length),icon:const Icon(Icons.skip_next),label:const Text('تخطي البطاقة')))])])));}
}
