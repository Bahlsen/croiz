// ignore_for_file: prefer_const_constructors
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:go_router/go_router.dart';

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
    if (kDebugMode && completed) {
      debugPrint(
        'EndGameOverlay: completed=true, entries=${entries.length}, found=${found.length}',
      );
    }
    if (!completed) {
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
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)?.congratulations ??
                      'Congratulations!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // No timer displayed — kept intentionally blank/simple
                const SizedBox(height: 42),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)?.view ?? 'View'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    ref.read(gameBoardProvider.notifier).resetPuzzle();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    AppLocalizations.of(context)?.restart ?? 'Restart',
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // Navigate to puzzles list
                    context.go('/puzzles');
                  },
                  child: Text(
                    AppLocalizations.of(context)?.puzzles ?? 'Puzzles',
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
