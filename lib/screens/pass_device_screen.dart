import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// P0 Feature: Screen ensuring privacy and preventing peeking when passing the device.
class PassDeviceScreen extends StatefulWidget {
  final String targetPlayer;
  final String instruction;
  final VoidCallback onReady;

  const PassDeviceScreen({
    super.key,
    required this.targetPlayer,
    this.instruction = 'تأكد أن الشريك لا يرى الشاشة قبل الاستمرار.',
    required this.onReady,
  });

  static Future<void> show(
    BuildContext context, {
    required String targetPlayer,
    String instruction = 'تأكد أن الشريك لا يرى الشاشة قبل الاستمرار.',
    required VoidCallback onReady,
  }) {
    return Navigator.push(
      context,
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, _, __) => PassDeviceScreen(
          targetPlayer: targetPlayer,
          instruction: instruction,
          onReady: onReady,
        ),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<PassDeviceScreen> createState() => _PassDeviceScreenState();
}

class _PassDeviceScreenState extends State<PassDeviceScreen> {
  int _countdown = 3;
  bool _canProceed = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() async {
    for (int i = 3; i > 0; i--) {
      if (!mounted) return;
      setState(() => _countdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }
    if (mounted) {
      setState(() {
        _countdown = 0;
        _canProceed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepPurple,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                alignment: Alignment.center,
                child: const Text('📱', style: TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 32),
              const Text(
                'سلّم الجهاز للشريك',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'الدور الآن على: ${widget.targetPlayer}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.accentGold,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.instruction,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),
              const Spacer(),
              if (!_canProceed)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  alignment: Alignment.center,
                  child: Text(
                    'جاهز بعد $_countdown ثوانٍ...',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onReady();
                  },
                  icon: const Icon(Icons.lock_open_rounded),
                  label: const Text(
                    'أنا جاهز، ابدأ دوري',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
