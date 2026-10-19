import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local storage service wrapping SharedPreferences.
class PreferencesService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _p => _prefs!;

  // ─── Favorites ──────────────────────────────────────
  static const _favKey = 'favorite_couples_cards_v1';

  static Set<String> getFavorites() =>
      (_p.getStringList(_favKey) ?? []).toSet();

  static Future<void> saveFavorites(Set<String> ids) =>
      _p.setStringList(_favKey, ids.toList());

  static Future<void> toggleFavorite(String id, Set<String> current) async {
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    await saveFavorites(current);
  }

  // ─── Custom Cards ──────────────────────────────────
  static const _customKey = 'custom_couples_cards_v1';

  static List<Map<String, dynamic>> getCustomCards() {
    final raw = _p.getString(_customKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  static Future<void> saveCustomCards(List<Map<String, dynamic>> cards) =>
      _p.setString(_customKey, jsonEncode(cards));

  // ─── Streak & Habits ────────────────────────────────
  static int get streakDays => _p.getInt('streak_days') ?? 1;
  static String? get lastPlayedDate => _p.getString('last_played_date');

  static Future<void> recordGamePlay() async {
    final now = DateTime.now();
    final today = '${now.year}-${now.month}-${now.day}';
    final last = lastPlayedDate;

    if (last == null) {
      await _p.setInt('streak_days', 1);
      await _p.setString('last_played_date', today);
    } else if (last != today) {
      final parts = last.split('-').map(int.parse).toList();
      final lastDate = DateTime(parts[0], parts[1], parts[2]);
      final difference = now.difference(lastDate).inDays;

      if (difference == 1) {
        await _p.setInt('streak_days', streakDays + 1);
      } else if (difference > 1) {
        await _p.setInt('streak_days', 1);
      }
      await _p.setString('last_played_date', today);
    }
  }

  // ─── Settings ──────────────────────────────────────
  static bool get isDarkMode => _p.getBool('dark_mode') ?? false;
  static Future<void> setDarkMode(bool v) => _p.setBool('dark_mode', v);

  static bool get reducedMotion => _p.getBool('reduced_motion') ?? false;
  static Future<void> setReducedMotion(bool v) =>
      _p.setBool('reduced_motion', v);

  static double get fontScale => _p.getDouble('font_scale') ?? 1.0;
  static Future<void> setFontScale(double v) => _p.setDouble('font_scale', v);

  static bool get soundEnabled => _p.getBool('sound_enabled') ?? true;
  static Future<void> setSoundEnabled(bool v) =>
      _p.setBool('sound_enabled', v);

  // ─── Auth Cache ────────────────────────────────────
  static String? get cachedEmail => _p.getString('cached_email');
  static Future<void> setCachedEmail(String? v) =>
      v == null ? _p.remove('cached_email') : _p.setString('cached_email', v);
}
