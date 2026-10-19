class CouplesCard {
  final String id;
  final String category;
  final String type;
  final String level;
  final String text;
  final String purpose;

  const CouplesCard({
    required this.id,
    required this.category,
    required this.type,
    required this.level,
    required this.text,
    required this.purpose,
  });

  factory CouplesCard.fromJson(Map<String, dynamic> json) => CouplesCard(
        id: json['id']?.toString() ?? '',
        category: json['category']?.toString() ?? 'عام',
        type: json['type']?.toString() ?? 'سؤال',
        level: json['level']?.toString() ?? 'خفيف',
        text: json['text']?.toString() ?? '',
        purpose: json['purpose']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'type': type,
        'level': level,
        'text': text,
        'purpose': purpose,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CouplesCard &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
