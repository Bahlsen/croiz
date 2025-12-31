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

class EndGameOverlay extends ConsumerWidget {
  const EndGameOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        Center(
          child: Container(
            width: ResponsiveOverlay.dialogWidth,
            padding: EdgeInsets.all(ResponsiveOverlay.dialogPadding),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(ResponsiveBorderRadius.lg),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)?.congratulations ??
                      'Congratulations!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveFontSize.headlineSmall,
                  ),
                ),
                SizedBox(height: ResponsiveSpacing.sm),
                // Show elapsed time
                Builder(
                  builder: (context) {
                    final boardId = ref.watch(
                      gameBoardProvider.select((b) => b.id),
                    );
                    final formatted = ref
                        .read(gameTimerProvider(boardId))
                        .formattedElapsed();
                    return Text(
                      formatted,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                        ref.read(endGameOverlayVisibleProvider.notifier).hide();
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)?.view ?? 'View',
                      style: TextStyle(fontSize: ResponsiveFontSize.bodyLarge),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveSpacing.xs),
                SizedBox(
                  height: ResponsiveButton.heightMedium,
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(gameBoardProvider.notifier).resetPuzzle();
                      // Don't call Navigator.pop() - the overlay will disappear
                      // naturally when foundWords becomes empty after reset
                    },
                    child: Text(
                      AppLocalizations.of(context)?.restart ?? 'Restart',
                      style: TextStyle(fontSize: ResponsiveFontSize.bodyLarge),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveSpacing.xs),
                SizedBox(
                  height: ResponsiveButton.heightMedium,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to puzzles list
                      context.go('/puzzles');
                    },
                    child: Text(
                      AppLocalizations.of(context)?.puzzles ?? 'Puzzles',
                      style: TextStyle(fontSize: ResponsiveFontSize.bodyLarge),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
