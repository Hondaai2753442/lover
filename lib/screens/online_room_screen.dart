import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/couples_card.dart';
import '../services/game_data_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';

class OnlineRoomScreen extends StatefulWidget {
  const OnlineRoomScreen({super.key});

  @override
  State<OnlineRoomScreen> createState() => _OnlineRoomScreenState();
}

class _OnlineRoomScreenState extends State<OnlineRoomScreen> {
  bool _isLoading = false;
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _checkAuthAndAct(VoidCallback onAuthorized) {
    if (!SupabaseService.isLoggedIn) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('تسجيل الدخول مطلوب'),
          content: const Text(
            'يتطلب اللعب عن بعد تسجيل الدخول لحفظ أمان الغرفة والتواصل المباشر بين الشريكين.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final res = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                );
                if (res == true && mounted) {
                  onAuthorized();
                }
              },
              child: const Text('تسجيل الدخول'),
            ),
          ],
        ),
      );
    } else {
      onAuthorized();
    }
  }

  Future<void> _createRoom() async {
    setState(() => _isLoading = true);
    try {
      final room = await SupabaseService.createRoom();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ActiveOnlineRoomScreen(
              roomId: room['id'],
              roomCode: room['room_code'],
              isHost: true,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('تعذر إنشاء الغرفة: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _joinRoom() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رمز الغرفة يتكون من 6 أحرف')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final room = await SupabaseService.joinRoom(code);
      if (room == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text('الغرفة غير موجودة أو بدأت بالفعل.'),
            ),
          );
        }
        return;
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ActiveOnlineRoomScreen(
              roomId: room['id'],
              roomCode: code,
              isHost: false,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('تعذر الانضمام: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اللعب عن بعد (غرف Supabase)')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Text('🌐', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 10),
                    const Text(
                      'غرفة اللعب المباشر',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'العبوا معًا حتى لو كنتم في مدينتين مختلفتين عبر المزامنة المباشرة.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Create Room Option
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppDecorations.outlinedCard(),
                child: Column(
                  children: [
                    const Text(
                      'إنشاء غرفة جديدة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'أنشئ رمزًا وشاركه مع شريكك للبدء فورًا',
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () => _checkAuthAndAct(_createRoom),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('إنشاء غرفة الآن'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Join Room Option
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppDecorations.outlinedCard(),
                child: Column(
                  children: [
                    const Text(
                      'الانضمام إلى غرفة موجودة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _codeController,
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: const TextStyle(
                        letterSpacing: 6,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: AppColors.deepPurple,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'ABCD12',
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () => _checkAuthAndAct(_joinRoom),
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('انضمام إلى الغرفة'),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Center(
                  child: Text(
                    SupabaseService.isLoggedIn
                        ? 'مسجل الدخول كـ: ${SupabaseService.currentUser?.email}'
                        : 'لم تسجل الدخول بعد',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Active Online Room Screen ───────────────────────────
class ActiveOnlineRoomScreen extends StatefulWidget {
  final String roomId;
  final String roomCode;
  final bool isHost;

  const ActiveOnlineRoomScreen({
    super.key,
    required this.roomId,
    required this.roomCode,
    required this.isHost,
  });

  @override
  State<ActiveOnlineRoomScreen> createState() =>
      _ActiveOnlineRoomScreenState();
}

class _ActiveOnlineRoomScreenState extends State<ActiveOnlineRoomScreen> {
  RealtimeChannel? _channel;
  List<CouplesCard> _cards = [];
  CouplesCard? _currentCard;
  bool _partnerJoined = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initRoom();
  }

  Future<void> _initRoom() async {
    _cards = await GameDataService.loadTypedCards();
    if (_cards.isNotEmpty) {
      _currentCard = _cards.first;
    }

    // Subscribe to realtime room updates
    _channel = SupabaseService.subscribeToRoom(widget.roomId, (payload) {
      final eventType = payload['event_type'];
      if (eventType == 'joined' && mounted) {
        setState(() => _partnerJoined = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('انضم الشريك إلى الغرفة! 🎉')),
        );
      } else if (eventType == 'card_revealed' && mounted) {
        final cardId = payload['card_id'];
        final found = _cards.firstWhere(
          (c) => c.id == cardId,
          orElse: () => _cards.first,
        );
        setState(() {
          _currentCard = found;
          _partnerJoined = true;
        });
      }
    });

    if (!widget.isHost) {
      // Notify host that guest joined
      await SupabaseService.sendRoomEvent(
        roomId: widget.roomId,
        eventType: 'joined',
        actorRole: 'guest',
      );
      setState(() => _partnerJoined = true);
    }
  }

  @override
  void dispose() {
    if (_channel != null) {
      SupabaseService.unsubscribeFromRoom(_channel!);
    }
    super.dispose();
  }

  void _nextCard() async {
    if (_cards.isEmpty) return;
    final next = _cards[_random.nextInt(_cards.length)];
    setState(() => _currentCard = next);

    await SupabaseService.sendRoomEvent(
      roomId: widget.roomId,
      eventType: 'card_revealed',
      actorRole: widget.isHost ? 'host' : 'guest',
      cardId: next.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('غرفة: ${widget.roomCode}'),
        actions: [
          IconButton(
            tooltip: 'مغادرة الغرفة',
            icon: const Icon(Icons.exit_to_app_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Room Status Header
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _partnerJoined
                      ? const Color(0xFFE8F5E9)
                      : AppColors.palePurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      _partnerJoined
                          ? Icons.check_circle_rounded
                          : Icons.hourglass_top_rounded,
                      color: _partnerJoined ? Colors.green : AppColors.purple,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _partnerJoined
                            ? 'الشريكان متصلان في الغرفة 💜'
                            : 'بانتظار انضمام الشريك... الرمز: ${widget.roomCode}',
                        style: TextStyle(
                          color: _partnerJoined
                              ? Colors.green.shade800
                              : AppColors.deepPurple,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Synchronized Card View
              Expanded(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: AppShadows.floatingShadow,
                    ),
                    child: _currentCard == null
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_currentCard!.category} • متزامن',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                _currentCard!.text,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  height: 1.6,
                                ),
                              ),
                              if (_currentCard!.purpose.isNotEmpty) ...[
                                const SizedBox(height: 18),
                                Text(
                                  _currentCard!.purpose,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Next card sync button
              FilledButton.icon(
                onPressed: _nextCard,
                icon: const Icon(Icons.sync_rounded),
                label: const Text('سحب بطاقة جديدة متزامنة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
