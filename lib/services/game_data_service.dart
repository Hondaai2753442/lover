import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/character.dart';
import '../models/couples_card.dart';
import '../models/know_me_question.dart';

/// Loads local JSON assets (characters, couples cards, and know-me questions).
class GameDataService {
  GameDataService._();

  static Future<List<Character>> loadCharacters() async {
    final raw = await rootBundle.loadString('assets/characters.json');
    return (jsonDecode(raw) as List)
        .map((e) => Character.fromJson(e))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> loadCards() async {
    final raw = await rootBundle.loadString('assets/couples_cards.json');
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  static Future<List<CouplesCard>> loadTypedCards() async {
    final list = await loadCards();
    return list.map((m) => CouplesCard.fromJson(m)).toList();
  }

  static Future<List<KnowMeQuestion>> loadKnowMeQuestions() async {
    try {
      final raw = await rootBundle.loadString('assets/know_me_questions.json');
      return (jsonDecode(raw) as List)
          .map((e) => KnowMeQuestion.fromJson(e))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
