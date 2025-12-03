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

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Scrollable banner: if space is tight the banner can scroll rather than
          // forcing the whole bar to overflow or shrink the keyboard.
          Flexible(
            // Fixed banner (non-scrollable). We keep a minimum height so
            // it remains visible and doesn't collapse on tight layouts.
            flex: 20,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: const CrosswordClueBanner(),
            ),
          ),

          // Small separation and control row
          const SizedBox(height: 6),
          SizedBox(
            height: 48,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      key: const Key('clear_button'),
                      tooltip: 'Clear incorrect letters',
                      icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white70),
                      iconSize: 28,
                      visualDensity: VisualDensity.standard,
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
                      iconSize: 28,
                      visualDensity: VisualDensity.standard,
                      onPressed: () => setState(() => _isAzerty = !_isAzerty),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Keyboard takes the remaining space. Let VirtualKeyboard compute sizes
          // according to the available constraints (it already respects constraints).
          Expanded(
            flex: 50,
            child: VirtualKeyboard(
              layout: layout,
              onKey: widget.onKey,
              onBackspace: widget.onBackspace,
              enableFeedback: true,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
          ),
        ],
      ),
    );
  }
}
