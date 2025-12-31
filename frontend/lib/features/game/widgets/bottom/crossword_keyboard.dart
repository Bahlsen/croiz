import 'package:flutter/material.dart';
import 'package:croiz/widgets/virtual_keyboard.dart';

/// Simple wrapper around `VirtualKeyboard` to give the game feature a
/// named, single-responsibility widget. This makes it easier to mock or
/// substitute the keyboard later without touching layout code.
class CrosswordKeyboard extends StatelessWidget {
  const CrosswordKeyboard({
    required this.layout,
    required this.onKey,
    required this.onBackspace,
    this.keyHeight = 64,
    this.letterFontSize = 16,
    super.key,
  });

  // Expose the same named layouts as the underlying VirtualKeyboard so
  // callers can switch between AZERTY/QWERTY without importing
  // `VirtualKeyboard` directly.
  static List<List<String>> get azertyLayout => VirtualKeyboard.azertyLayout;
  static List<List<String>> get qwertyLayout => VirtualKeyboard.qwertyLayout;

  final List<List<String>> layout;
  final void Function(String) onKey;
  final VoidCallback onBackspace;
  final double keyHeight;
  final double letterFontSize;

  @override
  Widget build(BuildContext context) => VirtualKeyboard(
    layout: layout,
    onKey: onKey,
    onBackspace: onBackspace,
    keyHeight: keyHeight,
    letterFontSize: letterFontSize,
  );
}
