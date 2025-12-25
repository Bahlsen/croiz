import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:croiz/widgets/virtual_keyboard.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_clue_header.dart';
// Icons moved into the clue banner; no separate icon row import needed.
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_menu.dart';

// Simple, robust controls bar: banner, icon row, and keyboard.
//
// IMPORTANT: This widget expects its parent to provide the vertical
// space it should occupy. The layout contract is:
// - Parent (e.g. `CrosswordScreen`) must size this widget using
//   `Expanded` (or an explicit SizedBox) so that the controls take the
//   remaining height of the screen.
// - The controls bar will compute internal splits (banner / icons /
//   keyboard) from the given height and will NOT perform top-level
//   calculations that assume the full device height. Keeping sizing
//   responsibility in the parent avoids overlaps and keeps the layout
//   dynamic across screen sizes.
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
  bool _showMenu = false;

  @override
  Widget build(BuildContext context) {
    final isAzerty = ref.watch(gameKeyboardLayoutProvider);
    final layout = isAzerty
        ? VirtualKeyboard.azertyLayout
        : VirtualKeyboard.qwertyLayout;

    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CrosswordClueHeader(
              key: const ValueKey('clue-banner'),
              onClear: () {
                ref.read(gameBoardProvider.notifier).clearIncorrectLetters();
              },
              onMenu: () => setState(() => _showMenu = true),
            ),
            VirtualKeyboard(
              layout: layout,
              onKey: widget.onKey,
              onBackspace: widget.onBackspace,
            ),
          ],
        ),
        if (_showMenu)
          CrosswordControlsMenu(
            onClose: () => setState(() => _showMenu = false),
            onToggleKeyboard: (v) =>
                ref.read(gameKeyboardLayoutProvider.notifier).isAzerty = v,
            onToggleMute: (v) =>
                ref.read(gameAudioMutedProvider.notifier).muted = v,
            onToggleTheme: (v) =>
                ref.read(appIsDarkProvider.notifier).isDark = v,
          ),
      ],
    );
  }
}
