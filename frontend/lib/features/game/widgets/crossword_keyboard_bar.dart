import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/widgets/virtual_keyboard.dart';
import 'package:croiz/features/game/widgets/crossword_clues_banner.dart';

class CrosswordKeyboardBar extends ConsumerStatefulWidget {

  const CrosswordKeyboardBar({
    required this.onKey,
    required this.onBackspace,
    Key? key,
  }) : super(key: key);
  final void Function(String) onKey;
  final VoidCallback onBackspace;

  @override
  ConsumerState<CrosswordKeyboardBar> createState() => _CrosswordKeyboardBarState();
}

class _CrosswordKeyboardBarState extends ConsumerState<CrosswordKeyboardBar> {
  bool _isAzerty = true; // Default AZERTY

  @override
  Widget build(BuildContext context) {
    final layout = _isAzerty
      ? VirtualKeyboard.azertyLayout
      : VirtualKeyboard.qwertyLayout;

    // Constrain the whole keyboard bar to a reasonable max height and make
    // its internal content scrollable when necessary. This prevents the
    // Column from overflowing in headless test environments while keeping
    // normal runtime behavior intact.
    return SafeArea(
      top: false,
      child: SizedBox(
        // Keep this reasonably small for tests; the inner scroll view will
        // allow the banner+controls+keyboard to be scrolled instead of
        // overflowing the available space.
        height: 240,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CrosswordClueBanner(),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      key: const Key('clear_button'),
                      tooltip: 'Clear incorrect letters',
                      icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white70),
                      onPressed: () {
                        try {
                          ref.read(gameBoardProvider.notifier).clearIncorrectLetters();
                        } on Object catch (e, st) {
                          debugPrint('clearIncorrectLetters failed: $e\n$st');
                        }
                      },
                    ),
                    IconButton(
                      tooltip: 'Basculer AZERTY/QWERTY',
                      icon: const Icon(Icons.keyboard_alt, color: Colors.white70),
                      onPressed: () => setState(() => _isAzerty = !_isAzerty),
                    ),
                  ],
                ),
              ),
              // Constrain the visual keyboard to a fixed height so it cannot
              // force the bar to grow. The outer SingleChildScrollView will
              // allow scrolling when the combined banner+controls+keyboard
              // would otherwise exceed `height: 240`.
              SizedBox(
                height: 120,
                child: VirtualKeyboard(
                  layout: layout,
                  onKey: widget.onKey,
                  onBackspace: widget.onBackspace,
                  enableFeedback: true,
                  keyHeight: 38,
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
