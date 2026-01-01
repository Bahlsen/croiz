import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/l10n/app_localizations.dart';

import '../keyboard/virtual_keyboard.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';

/// In-game text input that uses the in-app [VirtualKeyboard]
/// and prevents the system keyboard from appearing.
class InGameTextInput extends ConsumerStatefulWidget {
  const InGameTextInput({
    required this.controller,
    super.key,
    this.hintText,
    this.maxLength,
    this.onSubmitted,
    this.enabledLetters,
    this.keyboardLayout,
    this.autofocus = false,
    this.keyboardInitiallyVisible = true,
  });

  final TextEditingController controller;
  final String? hintText;
  final int? maxLength;
  final ValueChanged<String>? onSubmitted;
  final Set<String>? enabledLetters;
  final List<List<String>>? keyboardLayout;
  final bool autofocus;
  final bool keyboardInitiallyVisible;

  @override
  ConsumerState<InGameTextInput> createState() => _InGameTextInputState();
}

class _InGameTextInputState extends ConsumerState<InGameTextInput> {
  late final FocusNode _focusNode;
  late bool _keyboardVisible;
  late List<List<String>>? _currentLayout;
  late final CrosswordInputController _gameController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(canRequestFocus: false);
    _keyboardVisible = widget.keyboardInitiallyVisible;
    _currentLayout = widget.keyboardLayout ?? VirtualKeyboard.azertyLayout;
    // Create a single game controller instance to reuse across key events.
    _gameController = CrosswordInputController.fromRef(ref);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    try {
      _gameController.dispose();
    } on Object {
      // ignore
    }
    super.dispose();
  }

  void _clearIncorrectLetters() {
    try {
      ref.read(gameBoardProvider.notifier).clearIncorrectLetters();
    } on Object catch (e, st) {
      if (kDebugMode) {
        debugPrint('clearIncorrectLetters failed: $e\n$st');
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildField(context),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton.icon(
              onPressed: _clearIncorrectLetters,
              icon: Icon(
                Icons.delete_sweep_outlined,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              label: Text(AppLocalizations.of(context)?.clear ?? 'Clear'),
            ),
          ],
        ),
      ),
      AnimatedCrossFade(
        firstChild: const SizedBox.shrink(),
        secondChild: VirtualKeyboard(
          onKey: _handleKey,
          onBackspace: _handleBackspace,
          enabledLetters: widget.enabledLetters,
          layout: _currentLayout,
        ),
        crossFadeState:
            _keyboardVisible
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 180),
      ),
    ],
  );

  Widget _buildField(BuildContext context) => TextField(
    controller: widget.controller,
    readOnly: true, // Prevent system keyboard
    showCursor: true,
    focusNode: _focusNode,
    autofocus: widget.autofocus,
    textCapitalization: TextCapitalization.characters,
    maxLength: widget.maxLength,
    decoration: InputDecoration(
      hintText: widget.hintText,
      counterText: '',
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip:
                AppLocalizations.of(context)?.clearIncorrectLetters ??
                'Clear incorrect letters',
            onPressed: _clearIncorrectLetters,
            icon: Icon(
              Icons.delete_sweep_outlined,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          IconButton(
            tooltip:
                AppLocalizations.of(context)?.switchKeyboardLayout ??
                'Switch keyboard layout',
            onPressed: () {
              setState(() {
                // Toggle between AZERTY and QWERTY layouts
                if (_currentLayout == VirtualKeyboard.azertyLayout) {
                  _currentLayout = VirtualKeyboard.qwertyLayout;
                } else {
                  _currentLayout = VirtualKeyboard.azertyLayout;
                }
                // Ensure keyboard visible when switching layout
                _keyboardVisible = true;
              });
            },
            icon: Icon(_keyboardVisible ? Icons.keyboard : Icons.keyboard),
          ),
        ],
      ),
    ),
    onTap: () => setState(() => _keyboardVisible = true),
  );

  void _handleKey(String letter) {
    if (!_isAZ(letter)) {
      return;
    }
    final upper = letter.toUpperCase();
    // Delegate to the game's input controller so insertion, auto-advance
    // and locking behavior are handled consistently.
    _gameController.setLetterAndAdvance(upper);
  }

  void _handleBackspace() {
    // Delegate deletions to the game's input controller so locked cells are
    // respected.
    _gameController.clearCurrent();
  }

  // Enter key removed from keyboard; submission now triggered externally if needed.

  bool _isAZ(String c) {
    if (c.isEmpty) {
      return false;
    }
    final code = c.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }
}
