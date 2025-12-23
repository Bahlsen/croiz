import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:croiz/services/providers.dart';

/// Provider that tracks app initialization state.
/// Returns true when all critical services are ready.
final appInitializedProvider = FutureProvider<bool>((ref) async {
  try {
    // Wait for audio service to be fully initialized
    final audioService = ref.read(gameAudioServiceProvider);
    await audioService.ready;

    developer.log(
      'App initialization complete - audio ready',
      name: 'SplashScreen',
    );
    return true;
  } on Object catch (e, st) {
    developer.log(
      'App initialization failed',
      error: e,
      stackTrace: st,
      name: 'SplashScreen',
    );
    // Return true anyway to not block the app - audio will be degraded
    return true;
  }
});

/// Splash screen shown during app initialization.
///
/// Displays an animated logo and loading indicator while waiting for
/// critical services (audio, etc.) to initialize.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({
    required this.onInitialized,
    super.key,
  });

  /// Callback when initialization is complete.
  final VoidCallback onInitialized;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initState = ref.watch(appInitializedProvider);

    // When initialized, trigger callback after a short delay for smooth transition
    ref.listen<AsyncValue<bool>>(appInitializedProvider, (previous, next) {
      final value = next.asData?.value;
      if (value == true) {
        // Small delay to show the completed animation
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            widget.onInitialized();
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: child,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo / App name
              const Text(
                'CROIZ',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Crossword Puzzles',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withAlpha(179),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 48),

              // Loading indicator
              initState.when(
                data: (_) => Icon(
                  Icons.check_circle,
                  color: Colors.green.shade400,
                  size: 32,
                ),
                loading: () => const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                ),
                error: (_, __) => Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade400,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),

              // Status text
              Text(
                initState.when(
                  data: (_) => 'Ready!',
                  loading: () => 'Loading sounds...',
                  error: (_, __) => 'Starting...',
                ),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withAlpha(128),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
