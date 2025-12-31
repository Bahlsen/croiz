import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:croiz/services/providers.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/core/responsive/responsive.dart';

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
  const SplashScreen({required this.onInitialized, super.key});

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
        // Ensure the splash remains visible at least until the
        // intro animation completes. Use the animation controller's
        // progress (`value`) to compute elapsed time so tests that
        // advance time via `tester.pump` remain deterministic.
        final animationDuration = _controller.duration ?? Duration.zero;
        final elapsedMs = (animationDuration.inMilliseconds * _controller.value)
            .round();
        final elapsed = Duration(milliseconds: elapsedMs);
        const buffer = Duration(milliseconds: 300);
        final remaining = animationDuration - elapsed;
        final wait = remaining > Duration.zero ? remaining + buffer : buffer;

        Future.delayed(wait, () {
          if (mounted) {
            widget.onInitialized();
          }
        });
      }
    });

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(scale: _scaleAnimation, child: child),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo / App name (localized and using theme)
              Text(
                AppLocalizations.of(context)!.appTitle,
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(
                  letterSpacing: 8,
                  fontSize: ResponsiveFontSize.headlineLarge,
                ),
              ),
              SizedBox(height: ResponsiveSpacing.xs),
              Text(
                AppLocalizations.of(context)!.subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withAlpha((0.7 * 255).round()),
                  letterSpacing: 2,
                  fontSize: ResponsiveFontSize.bodyMedium,
                ),
              ),
              SizedBox(height: ResponsiveSpacing.xxl),

              // Loading indicator
              initState.when(
                data: (_) => Icon(
                  Icons.check_circle,
                  color: scheme.primary,
                  size: ResponsiveIconSize.lg,
                ),
                loading: () => SizedBox(
                  width: ResponsiveIconSize.lg,
                  height: ResponsiveIconSize.lg,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      scheme.onSurface.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                ),
                error: (_, _) => Icon(
                  Icons.warning_amber_rounded,
                  color: scheme.error,
                  size: ResponsiveIconSize.lg,
                ),
              ),
              SizedBox(height: ResponsiveSpacing.md),

              // Status text (localized)
              Text(
                initState.when(
                  data: (_) => AppLocalizations.of(context)!.ready,
                  loading: () => AppLocalizations.of(context)!.loadingSounds,
                  error: (_, _) => AppLocalizations.of(context)!.starting,
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withAlpha((0.5 * 255).round()),
                  fontSize: ResponsiveFontSize.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
