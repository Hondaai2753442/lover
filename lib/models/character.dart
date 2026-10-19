class Character {
  final String id, name, emoji, gender, hair, skin;
  final bool older, glasses, beard, headwear, hijab, thobe;
  final String? image;

  const Character({
    required this.id,
    required this.name,
    required this.emoji,
    required this.gender,
    required this.older,
    required this.glasses,
    required this.beard,
    required this.headwear,
    required this.hijab,
    required this.thobe,
    required this.hair,
    required this.skin,
    this.image,
  });

  factory Character.fromJson(Map<String, dynamic> j) => Character(
        id: j['id'] ?? '',
        name: j['name'] ?? '',
        emoji: j['emoji'] ?? '👤',
        gender: j['gender'] ?? 'رجل',
        older: j['older'] ?? false,
        glasses: j['glasses'] ?? false,
        beard: j['beard'] ?? false,
        headwear: j['headwear'] ?? false,
        hijab: j['hijab'] ?? false,
        thobe: j['thobe'] ?? false,
        hair: j['hair'] ?? 'داكن',
        skin: j['skin'] ?? 'فاتحة',
        image: j['image'],
      );

  /// Returns whether this character has the given trait.
  bool trait(String key) => switch (key) {
        'gender_male' => gender == 'رجل',
        'gender_female' => gender == 'امرأة',
        'older' => older,
        'glasses' => glasses,
        'beard' => beard,
        'headwear' => headwear,
        'hijab' => hijab,
        'thobe' => thobe,
        'light_skin' => skin == 'فاتحة',
        'olive_skin' => skin == 'حنطية',
        'dark_hair' => hair == 'داكن',
        _ => false,
      };
}
