// ignore_for_file: provider_dependencies
import 'package:croiz/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/widgets/keyboard/virtual_keyboard.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_clue_header.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/features/game/helpers/entry_lookup.dart';
import 'package:croiz/features/game/controllers/entry_helpers.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/features/monetization/services/ad_service.dart';
import 'package:croiz/features/monetization/providers/subscription_provider.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_menu.dart';
import 'package:croiz/core/responsive/responsive.dart';

/// Controls bar containing the clue header and virtual keyboard.
///
/// Uses [mainAxisSize: MainAxisSize.min] to only take the space needed.
/// This allows the parent layout to measure it first and give remaining
/// space to the grid.
class CrosswordControlsBar extends ConsumerStatefulWidget {
  const CrosswordControlsBar({
    required this.onKey,
    required this.onBackspace,
    super.key,
  });

  final void Function(String) onKey;
  final VoidCallback onBackspace;

  @override
  ConsumerState<CrosswordControlsBar> createState() =>
      _CrosswordControlsBarState();
}

class _CrosswordControlsBarState extends ConsumerState<CrosswordControlsBar> {
  bool _dialogOpen = false;
  bool _revealOpen = false;
  bool _isProcessingReveal = false;

  @override
  Widget build(BuildContext context) {
    final isAzerty = ref.watch(gameKeyboardLayoutProvider);
    final board = ref.watch(gameBoardProvider.select((b) => b));
    final language = board.language.toLowerCase();
    // Ukrainian uses Cyrillic layout
    final isCyrillic = ['uk', 'ua'].contains(language);

    final isSpanish = language == 'es';
    final layout =
        isCyrillic
            ? VirtualKeyboard.ukrainianLayout
            : (isSpanish
                ? VirtualKeyboard.spanishLayout
                : (isAzerty
                    ? VirtualKeyboard.azertyLayout
                    : VirtualKeyboard.qwertyLayout));
    final kbSize = ref.watch(gameKeyboardSizeProvider);

    // Map keyboard size to responsive key height and font size.
    final keyHeight = switch (kbSize) {
      KeyboardSize.small => ResponsiveKeyboard.keyHeightSmall,
      KeyboardSize.large => ResponsiveKeyboard.keyHeightLarge,
      KeyboardSize.medium => ResponsiveKeyboard.keyHeightMedium,
    };

    final letterFontSize = switch (kbSize) {
      KeyboardSize.small => ResponsiveKeyboard.letterFontSmall,
      KeyboardSize.large => ResponsiveKeyboard.letterFontLarge,
      KeyboardSize.medium => ResponsiveKeyboard.letterFontMedium,
    };

    return Stack(
      children: [
        Column(
          // CRITICAL: MainAxisSize.min makes this widget use intrinsic height.
          // The parent Column measures this first, then Expanded grid gets rest.
          mainAxisSize: MainAxisSize.min,
          children: [
            // Clue header - intrinsic height
            _buildClueHeader(),
            // Keyboard with intrinsic height (SizedBox inside VirtualKeyboard)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: ResponsivePadding.sm),
              child: VirtualKeyboard(
                layout: layout,
                onKey: widget.onKey,
                onBackspace: widget.onBackspace,
                keyHeight: keyHeight,
                letterFontSize: letterFontSize,
              ),
            ),
          ],
        ),
        // Reveal overlay
        if (_revealOpen) ...[
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _revealOpen = false),
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: ResponsivePadding.sm,
            right: ResponsivePadding.sm,
            bottom: 0,
            child: _buildRevealMenu(context),
          ),
        ],
      ],
    );
  }

  Widget _buildClueHeader() => CrosswordClueHeader(
    key: const ValueKey('clue-banner'),
    onClear: () {
      ref.read(gameBoardProvider.notifier).clearIncorrectLetters();
    },
    onMenu: () {
      _openMenu(context);
    },
    onReveal: () {
      setState(() {
        _revealOpen = !_revealOpen;
      });
    },
  );

  Widget _buildRevealMenu(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(maxHeight: 45.h),
    child: Material(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveBorderRadius.md),
      ),
      color: Theme.of(context).cardColor,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsivePadding.md,
                vertical: 0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)?.reveal ?? 'Reveal',
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveFontSize.titleMedium,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: ResponsiveIconSize.md,
                    ),
                    onPressed: () => setState(() => _revealOpen = false),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _buildRevealOption(
              context,
              Icons.tag,
              AppLocalizations.of(context)?.revealLetterOption ?? 'Letter',
              _revealLetter,
            ),
            const Divider(height: 1),
            _buildRevealOption(
              context,
              Icons.checklist,
              AppLocalizations.of(context)?.revealWordOption ?? 'Word',
              _revealWord,
            ),
            const Divider(height: 1),
            _buildRevealOption(
              context,
              Icons.grid_on,
              AppLocalizations.of(context)?.revealAllOption ?? 'All',
              _revealAll,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildRevealOption(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) => ListTile(
    leading: Icon(
      icon,
      color: Theme.of(context).colorScheme.onSurface,
      size: ResponsiveIconSize.md,
    ),
    title: Text(
      title,
      style: TextStyle(fontSize: ResponsiveFontSize.bodyMedium),
    ),
    onTap: onTap,
  );

  Future<bool> _checkAdQuota(int quota, VoidCallback onReplenish) async {
    // Premium users bypass all quotas
    final isPremium = ref.read(subscriptionProvider).value ?? false;
    if (isPremium || quota > 0) {
      return true;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final loc = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(loc?.watchAdTitle ?? 'Watch Ad?'),
          content: Text(
            loc?.watchAdMessage ?? 'Watch a short ad to get more reveals?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(loc?.no ?? 'No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(loc?.yes ?? 'Yes'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return false;
    }

    // Show Ad
    final adService = ref.read(monetizationServiceProvider);
    final earned = await adService.showRewardedAd();
    if (earned) {
      onReplenish();
      return true;
    }
    return false;
  }

  Future<void> _revealLetter() async {
    if (_isProcessingReveal) {
      return;
    }
    _isProcessingReveal = true;
    try {
      setState(() => _revealOpen = false);
      final sel = ref.read(selectedCellProvider);
      if (sel == null) {
        return;
      }

      final board = ref.read(gameBoardProvider);
      final canReveal = await _checkAdQuota(
        board.lettersUntilAd,
        () => ref.read(gameBoardProvider.notifier).replenishLetterQuota(),
      );

      if (!canReveal) {
        return;
      }

      ref.read(gameBoardProvider.notifier).revealLetterAt(sel.row, sel.col);

      // After revealing, find and navigate to the next empty cell
      final updatedBoard = ref.read(gameBoardProvider);
      final dir = ref.read(wordDirectionProvider);
      final isAcross = dir == WordDirection.horizontal;

      // Find containing entry
      final containing = findContainingEntry(
        row: sel.row,
        col: sel.col,
        wantAcross: isAcross,
        entries: updatedBoard.entries,
        index: ref.read(cellEntriesIndexProvider),
      );

      if (containing != null) {
        // Search for next empty cell AFTER current position within same entry
        SelectedCell? nextInEntry;
        if (isAcross) {
          // Search columns after current
          for (
            var cc = sel.col + 1;
            cc < containing.x + containing.length;
            cc++
          ) {
            final val = updatedBoard.grid[containing.y][cc];
            if (val == null || val.isEmpty) {
              nextInEntry = SelectedCell(containing.y, cc);
              break;
            }
          }
        } else {
          // Search rows after current
          for (
            var rr = sel.row + 1;
            rr < containing.y + containing.length;
            rr++
          ) {
            final val = updatedBoard.grid[rr][containing.x];
            if (val == null || val.isEmpty) {
              nextInEntry = SelectedCell(rr, containing.x);
              break;
            }
          }
        }

        if (nextInEntry != null) {
          ref.read(selectedCellProvider.notifier).select(nextInEntry);
          return;
        }

        // If no empty after current position, find next empty from other entries
        final nextEmpty = findNextEmptyFromEntry(
          containing: containing,
          wantAcross: isAcross,
          board: updatedBoard,
          entries: updatedBoard.entries,
          skipLocked: false,
        );
        if (nextEmpty != null) {
          ref.read(selectedCellProvider.notifier).select(nextEmpty);
        }
      }
    } finally {
      _isProcessingReveal = false;
    }
  }

  Future<void> _revealWord() async {
    if (_isProcessingReveal) {
      return;
    }
    _isProcessingReveal = true;
    try {
      setState(() => _revealOpen = false);
      final sel = ref.read(selectedCellProvider);
      if (sel == null) {
        return;
      }
      final board = ref.read(gameBoardProvider);
      final dir = ref.read(wordDirectionProvider);
      final ctx = computeCurrentEntry(board, sel, dir);
      if (ctx == null) {
        return;
      }

      final canReveal = await _checkAdQuota(
        board.wordsUntilAd,
        () => ref.read(gameBoardProvider.notifier).replenishWordQuota(),
      );

      if (!canReveal) {
        return;
      }

      ref.read(gameBoardProvider.notifier).revealEntry(ctx.entry);

      // After revealing, find and navigate to the next empty cell
      final updatedBoard = ref.read(gameBoardProvider);
      final isAcross = dir == WordDirection.horizontal;
      final nextEmpty = findNextEmptyFromEntry(
        containing: ctx.entry,
        wantAcross: isAcross,
        board: updatedBoard,
        entries: updatedBoard.entries,
        skipLocked: false,
      );
      if (nextEmpty != null) {
        ref.read(selectedCellProvider.notifier).select(nextEmpty);
      }
    } finally {
      _isProcessingReveal = false;
    }
  }

  Future<void> _revealAll() async {
    if (_isProcessingReveal) {
      return;
    }
    _isProcessingReveal = true;
    try {
      setState(() => _revealOpen = false);

      // Premium users bypass ad requirement
      final isPremium = ref.read(subscriptionProvider).value ?? false;
      if (isPremium) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            final loc = AppLocalizations.of(context);
            return AlertDialog(
              title: Text(loc?.revealAllConfirmationTitle ?? 'Reveal All?'),
              content: Text(
                loc?.revealAllConfirmationMessage ??
                    'Are you sure you want to reveal the entire puzzle?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(loc?.no ?? 'No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(loc?.yes ?? 'Yes'),
                ),
              ],
            );
          },
        );
        if (confirmed == true) {
          ref.read(gameBoardProvider.notifier).revealAll();
        }
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          final loc = AppLocalizations.of(context);
          // Requirement: reveal complete puzzle -> watch ad.
          return AlertDialog(
            title: Text(loc?.revealAllConfirmationTitle ?? 'Reveal All?'),
            content: Text(
              loc?.revealAllAdMessage ??
                  'To reveal the entire puzzle, you must watch a short ad. Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(loc?.no ?? 'No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(loc?.yes ?? 'Yes'),
              ),
            ],
          );
        },
      );

      if (confirmed == true) {
        // Must watch ad
        final adService = ref.read(monetizationServiceProvider);
        final earned = await adService.showRewardedAd();
        if (earned) {
          ref.read(gameBoardProvider.notifier).revealAll();
        }
      }
    } finally {
      _isProcessingReveal = false;
    }
  }

  Future<void> _openMenu(BuildContext ctx) async {
    if (_dialogOpen) {
      return;
    }
    _dialogOpen = true;

    await showDialog<void>(
      context: ctx,
      barrierDismissible: true,
      builder:
          (dialogCtx) => Stack(
            children: [
              CrosswordControlsMenu(
                onClose: () => Navigator.of(dialogCtx).pop(),
                onToggleKeyboard: (v) {
                  ref
                      .read(gameKeyboardLayoutProvider.notifier)
                      .setIsAzerty(isAzerty: v);
                },
                onToggleMute: (v) {
                  ref.read(gameAudioMutedProvider.notifier).setMuted(muted: v);
                },
                onToggleTheme: (v) {
                  ref.read(appIsDarkProvider.notifier).setIsDark(isDark: v);
                },
              ),
            ],
          ),
    );

    _dialogOpen = false;
    if (mounted) {
      setState(() {});
    }
  }
}
