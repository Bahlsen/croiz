// ignore_for_file: provider_dependencies
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:go_router/go_router.dart';
import '../providers/end_game_overlay_provider.dart';
import '../providers/game_timer_provider.dart';
import 'package:croiz/core/responsive/responsive.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:croiz/features/monetization/services/ad_service.dart';

class EndGameOverlay extends ConsumerStatefulWidget {
  const EndGameOverlay({super.key});

  @override
  ConsumerState<EndGameOverlay> createState() => _EndGameOverlayState();
}

class _EndGameOverlayState extends ConsumerState<EndGameOverlay> {
  late ConfettiController _confettiController;
  bool _wasCompleted = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<PuzzleEntryData>? entries;
    Set<String>? found;
    try {
      // Performance: only watch entries (stable), not the entire board
      // which changes on every keystroke.
      entries = ref.watch(gameBoardProvider.select((b) => b.entries));
      found = ref.watch(foundWordsProvider);
    } on Object catch (e, st) {
      if (kDebugMode) {
        debugPrint('EndGameOverlay provider read failed: $e\n$st');
      }
      // If providers are temporarily unavailable (loading/initial build),
      // fall through with empty values so the widget can re-evaluate later
      // instead of permanently returning an empty box.
      entries = null;
      found = <String>{};
    }

    final completed =
        entries != null &&
        entries.isNotEmpty &&
        found!.length == entries.length;
    final overlayVisible = ref.watch(endGameOverlayVisibleProvider);

    if (kDebugMode && completed) {
      debugPrint(
        'EndGameOverlay: completed=true, entries=${entries.length}, found=${found.length}',
      );
    }

    // Trigger confetti and Ad when it becomes completed and visible
    if (completed && overlayVisible && !_wasCompleted) {
      _wasCompleted = true;
      _confettiController.play();
      // Show ad on completion
      if (kDebugMode) {
        debugPrint('EndGameOverlay: Attempting to show interstitial ad...');
      }
      ref.read(monetizationServiceProvider).showInterstitialAd();
    } else if (!completed || !overlayVisible) {
      _wasCompleted = false;
      _confettiController.stop();
    }

    if (!completed || !overlayVisible) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        ModalBarrier(
          dismissible: false,
          color: scheme.onSurface.withAlpha((0.54 * 255).round()),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: [
              scheme.primary,
              scheme.secondary,
              scheme.tertiary,
              Colors.orange,
              Colors.pink,
            ],
            numberOfParticles: 50,
            gravity: 0.1,
          ),
        ),
        Center(
          child: Container(
                width: ResponsiveOverlay.dialogWidth,
                padding: EdgeInsets.all(ResponsiveOverlay.dialogPadding),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(
                    ResponsiveBorderRadius.lg,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                          AppLocalizations.of(context)?.congratulations ??
                              'Congratulations!',
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveFontSize.headlineSmall,
                            color: scheme.primary,
                          ),
                        )
                        .animate()
                        .shimmer(
                          duration: 2000.ms,
                          color: scheme.primaryContainer.withValues(alpha: 0.5),
                        )
                        .shake(hz: 2, curve: Curves.easeInOut),
                    SizedBox(height: ResponsiveSpacing.sm),
                    // Show elapsed time
                    Builder(
                      builder: (context) {
                        final boardId = ref.watch(
                          gameBoardProvider.select((b) => b.id),
                        );
                        final formatted =
                            ref
                                .read(gameTimerProvider(boardId))
                                .formattedElapsed();
                        return Text(
                          formatted,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontSize: ResponsiveFontSize.titleLarge,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: ResponsiveSpacing.md),
                    SizedBox(
                          height: ResponsiveButton.heightMedium,
                          child: ElevatedButton(
                            onPressed: () {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              } else {
                                ref
                                    .read(
                                      endGameOverlayVisibleProvider.notifier,
                                    )
                                    .hide();
                              }
                            },
                            child: Text(
                              AppLocalizations.of(context)?.view ?? 'View',
                              style: TextStyle(
                                fontSize: ResponsiveFontSize.bodyLarge,
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .moveY(begin: 20, end: 0, curve: Curves.easeOutBack),
                    SizedBox(height: ResponsiveSpacing.xs),
                    SizedBox(
                          height: ResponsiveButton.heightMedium,
                          child: OutlinedButton(
                            onPressed: () {
                              ref
                                  .read(gameBoardProvider.notifier)
                                  .resetPuzzle();
                              // Don't call Navigator.pop() - the overlay will disappear
                              // naturally when foundWords becomes empty after reset
                            },
                            child: Text(
                              AppLocalizations.of(context)?.restart ??
                                  'Restart',
                              style: TextStyle(
                                fontSize: ResponsiveFontSize.bodyLarge,
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 600.ms)
                        .moveY(begin: 20, end: 0, curve: Curves.easeOutBack),
                    SizedBox(height: ResponsiveSpacing.xs),
                    SizedBox(
                          height: ResponsiveButton.heightMedium,
                          child: TextButton(
                            onPressed: () {
                              // Navigate to puzzles list
                              context.go('/puzzles');
                            },
                            child: Text(
                              AppLocalizations.of(context)?.puzzles ??
                                  'Puzzles',
                              style: TextStyle(
                                fontSize: ResponsiveFontSize.bodyLarge,
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 800.ms)
                        .moveY(begin: 20, end: 0, curve: Curves.easeOutBack),
                  ],
                ),
              )
              .animate()
              .scale(
                duration: 600.ms,
                curve: Curves.elasticOut,
                begin: const Offset(0.5, 0.5),
              )
              .fadeIn(duration: 400.ms),
        ),
      ],
    );
  }
}
