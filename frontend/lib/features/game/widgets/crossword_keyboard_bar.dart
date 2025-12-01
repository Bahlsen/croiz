import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const CrosswordClueBanner(),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: 'Basculer AZERTY/QWERTY',
              icon: const Icon(Icons.keyboard_alt, color: Colors.white70),
              onPressed: () => setState(() => _isAzerty = !_isAzerty),
            ),
          ),
          VirtualKeyboard(
            layout: layout,
            onKey: widget.onKey,
            onBackspace: widget.onBackspace,
            enableFeedback: true,
            keyHeight: 44,
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          ),
        ],
      ),
    );
  }
}
