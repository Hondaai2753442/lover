class Character {
  final String id, name, emoji, gender, hair, skin;
  final bool older, glasses, beard, headwear, hijab, thobe;

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
  });

  factory Character.fromJson(Map<String, dynamic> j) => Character(
        id: j['id'],
        name: j['name'],
        emoji: j['emoji'],
        gender: j['gender'],
        older: j['older'],
        glasses: j['glasses'],
        beard: j['beard'],
        headwear: j['headwear'],
        hijab: j['hijab'],
        thobe: j['thobe'],
        hair: j['hair'],
        skin: j['skin'],
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
