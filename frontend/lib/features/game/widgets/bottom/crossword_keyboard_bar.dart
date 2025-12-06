import 'package:flutter/material.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_bar.dart';

// Backwards-compatible shim. The widget formerly named
// `CrosswordKeyboardBar` has been renamed to `CrosswordControlsBar` to
// better reflect its responsibilities. This small wrapper keeps older
// imports working while the codebase migrates.
class CrosswordKeyboardBar extends StatelessWidget {
  const CrosswordKeyboardBar({
    required this.onKey,
    required this.onBackspace,
    Key? key,
  }) : super(key: key);

  final void Function(String) onKey;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) => CrosswordControlsBar(onKey: onKey, onBackspace: onBackspace);
}
