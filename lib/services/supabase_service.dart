import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Handles all Supabase operations: Auth, Rooms, Realtime.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;
  static User? get currentUser => client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  // ─── Initialization ────────────────────────────────
  static Future<void> init() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      // ignore: deprecated_member_use
      anonKey: SupabaseConfig.publishableKey,
    );
  }

  // ─── Auth ──────────────────────────────────────────
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final res = await client.auth.signUp(
      email: email,
      password: password,
      data: displayName != null ? {'display_name': displayName} : null,
    );
    return res;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() => client.auth.signOut();

  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  // ─── Profile ───────────────────────────────────────
  static Future<void> upsertProfile({
    required String displayName,
  }) async {
    final user = currentUser;
    if (user == null) return;
    await client.from('profiles').upsert({
      'id': user.id,
      'display_name': displayName,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;
    try {
      final data = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      return data;
    } catch (_) {
      return null;
    }
  }

  // ─── Rooms ─────────────────────────────────────────
  static String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  static Future<Map<String, dynamic>> createRoom({
    List<String>? categories,
    int roundSize = 10,
  }) async {
    final code = _generateRoomCode();
    final userId = currentUser?.id;

    final room = await client.from('game_rooms').insert({
      'room_code': code,
      'status': 'waiting',
      'host_id': userId,
      'selected_categories': categories ?? [],
      'round_size': roundSize,
    }).select().single();

    return room;
  }

  static Future<Map<String, dynamic>?> joinRoom(String code) async {
    try {
      final room = await client
          .from('game_rooms')
          .select()
          .eq('room_code', code.toUpperCase())
          .eq('status', 'waiting')
          .maybeSingle();

      if (room == null) return null;

      final userId = currentUser?.id;
      await client.from('game_rooms').update({
        'guest_id': userId,
        'status': 'playing',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', room['id']);

      return room;
    } catch (e) {
      debugPrint('Join room error: $e');
      return null;
    }
  }

  static Future<void> updateRoomStatus(String roomId, String status) async {
    await client.from('game_rooms').update({
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', roomId);
  }

  /// Subscribe to room changes via Realtime.
  static RealtimeChannel subscribeToRoom(
    String roomId,
    void Function(Map<String, dynamic> payload) onEvent,
  ) {
    final channel = client.channel('room:$roomId');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'room_events',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            onEvent(payload.newRecord);
          },
        )
        .subscribe();
    return channel;
  }

  static Future<void> sendRoomEvent({
    required String roomId,
    required String eventType,
    required String actorRole,
    String? cardId,
    Map<String, dynamic>? data,
  }) async {
    await client.from('room_events').insert({
      'room_id': roomId,
      'event_type': eventType,
      'actor_role': actorRole,
      if (cardId != null) 'card_id': cardId,
      if (data != null) 'event_data': data,
    });
  }

  static Future<void> unsubscribeFromRoom(RealtimeChannel channel) async {
    await client.removeChannel(channel);
  }

  // ─── Favorites Sync ────────────────────────────────
  static Future<void> syncFavorites(Set<String> localFavorites) async {
    if (!isLoggedIn) return;
    try {
      await client.from('user_favorites').upsert({
        'user_id': currentUser!.id,
        'card_ids': localFavorites.toList(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Silently fail — offline-first approach
    }
  }

  static Future<Set<String>> fetchFavorites() async {
    if (!isLoggedIn) return {};
    try {
      final data = await client
          .from('user_favorites')
          .select('card_ids')
          .eq('user_id', currentUser!.id)
          .maybeSingle();
      if (data == null) return {};
      return (data['card_ids'] as List).cast<String>().toSet();
    } catch (_) {
      return {};
    }
  }
}
