import 'package:croiz/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/widgets/virtual_keyboard.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_clue_header.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_menu.dart';

class CrosswordControlsBar extends ConsumerStatefulWidget {
  const CrosswordControlsBar({
    required this.onKey,
    required this.onBackspace,
    Key? key,
  }) : super(key: key);

  final void Function(String) onKey;
  final VoidCallback onBackspace;

  @override
  ConsumerState<CrosswordControlsBar> createState() =>
      _CrosswordControlsBarState();
}

class _CrosswordControlsBarState extends ConsumerState<CrosswordControlsBar> {
  bool _dialogOpen = false;

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
              ref.read(gameKeyboardLayoutProvider.notifier).isAzerty = v;
            },
            onToggleMute: (v) {
              ref.read(gameAudioMutedProvider.notifier).muted = v;
            },
            onToggleTheme: (v) {
              ref.read(appIsDarkProvider.notifier).isDark = v;
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
