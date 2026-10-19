class KnowMeQuestion {
  final String id;
  final String category;
  final String question;
  final String hint;

  const KnowMeQuestion({
    required this.id,
    required this.category,
    required this.question,
    this.hint = '',
  });

  factory KnowMeQuestion.fromJson(Map<String, dynamic> j) => KnowMeQuestion(
        id: j['id']?.toString() ?? '',
        category: j['category']?.toString() ?? 'عام',
        question: j['question']?.toString() ?? '',
        hint: j['hint']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'question': question,
        'hint': hint,
      };
}
