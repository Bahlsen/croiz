import 'package:croiz/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/widgets/virtual_keyboard.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_clue_header.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/features/game/helpers/entry_lookup.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_menu.dart';

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

  @override
  Widget build(BuildContext context) {
    final isAzerty = ref.watch(gameKeyboardLayoutProvider);
    final layout = isAzerty
        ? VirtualKeyboard.azertyLayout
        : VirtualKeyboard.qwertyLayout;
    final kbSize = ref.watch(gameKeyboardSizeProvider);

    // Map keyboard size to key height and font size used by keys.
    double keyHeight;
    double letterFontSize;
    switch (kbSize) {
      case KeyboardSize.small:
        keyHeight = 48;
        letterFontSize = 14;
        break;
      case KeyboardSize.large:
        keyHeight = 88;
        letterFontSize = 20;
        break;
      case KeyboardSize.medium:
        keyHeight = 64;
        letterFontSize = 16;
    }

    return Stack(
      children: [
        Column(
          // Keep the column sized to its content so the controls render
          // normally in tight layouts. Do not force it to expand.
          mainAxisSize: MainAxisSize.min,
          children: [
            CrosswordClueHeader(
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
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
        // Menu is shown via a dialog so it can occupy more vertical space
        // than the controls bar area. The dialog contains the same
        // `CrosswordControlsMenu` widget wrapped in a Stack to satisfy
        // its Positioned.fill usage.
        // Reveal overlay (renders above the keyboard when toggled)
        if (_revealOpen) ...[
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() => _revealOpen = false);
              },
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            // Match the keyboard horizontal padding (4px each side)
            // so the reveal menu is the same width as the keyboard.
            left: 4,
            right: 4,
            bottom: 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: Material(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Theme.of(context).cardColor,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)?.reveal ??
                                      'Reveal',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              onPressed: () =>
                                  setState(() => _revealOpen = false),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.tag,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        title: Text(
                          AppLocalizations.of(context)?.revealLetterOption ??
                              'Letter',
                        ),
                        onTap: () {
                          setState(() => _revealOpen = false);
                          final sel = ref.read(selectedCellProvider);
                          if (sel == null) {
                            return;
                          }
                          ref
                              .read(gameBoardProvider.notifier)
                              .revealLetterAt(sel.row, sel.col);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.checklist,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        title: Text(
                          AppLocalizations.of(context)?.revealWordOption ??
                              'Word',
                        ),
                        onTap: () {
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
                          ref
                              .read(gameBoardProvider.notifier)
                              .revealEntry(ctx.entry);
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.grid_on,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        title: Text(
                          AppLocalizations.of(context)?.revealAllOption ??
                              'All',
                        ),
                        onTap: () {
                          setState(() => _revealOpen = false);
                          ref.read(gameBoardProvider.notifier).revealAll();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _openMenu(BuildContext ctx) async {
    if (_dialogOpen) {
      return;
    }
    _dialogOpen = true;

    // local provider reads not needed here (menu reads providers itself)

    await showDialog<void>(
      context: ctx,
      barrierDismissible: true,
      builder: (dialogCtx) => Stack(
        children: [
          CrosswordControlsMenu(
            onClose: () {
              Navigator.of(dialogCtx).pop();
            },
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
