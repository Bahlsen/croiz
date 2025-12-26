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
  bool _showMenu = false;

  @override
  Widget build(BuildContext context) {
    final isAzerty = ref.watch(gameKeyboardLayoutProvider);
    final isMuted = ref.watch(gameAudioMutedProvider);
    final isDark = ref.watch(appIsDarkProvider);
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
              onClear: () =>
                  ref.read(gameBoardProvider.notifier).clearIncorrectLetters(),
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
            isAzerty: isAzerty,
            isMuted: isMuted,
            isDark: isDark,
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
