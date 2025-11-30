import 'package:flutter/material.dart';

import 'virtual_keyboard.dart';

/// In-game text input that uses the in-app [VirtualKeyboard]
/// and prevents the system keyboard from appearing.
class InGameTextInput extends StatefulWidget {
  const InGameTextInput({
    required this.controller, super.key,
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
  State<InGameTextInput> createState() => _InGameTextInputState();
}

class _InGameTextInputState extends State<InGameTextInput> {
  late final FocusNode _focusNode;
  late bool _keyboardVisible;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(canRequestFocus: false);
    _keyboardVisible = widget.keyboardInitiallyVisible;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildField(context),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: VirtualKeyboard(
            onKey: _handleKey,
            onBackspace: _handleBackspace,
            enabledLetters: widget.enabledLetters,
            layout: widget.keyboardLayout,
          ),
          crossFadeState: _keyboardVisible
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
        suffixIcon: IconButton(
          tooltip: _keyboardVisible ? 'Masquer le clavier' : 'Afficher le clavier',
          onPressed: () => setState(() => _keyboardVisible = !_keyboardVisible),
          icon: Icon(_keyboardVisible ? Icons.keyboard_hide : Icons.keyboard),
        ),
      ),
      onTap: () => setState(() => _keyboardVisible = true),
    );

  void _handleKey(String letter) {
    if (!_isAZ(letter)) {
      return;
    }

    final upper = letter.toUpperCase();
    final text = widget.controller.text;
    final sel = widget.controller.selection;
    final max = widget.maxLength;

    final selectionIndex = sel.isValid ? sel.baseOffset : text.length;

    if (max != null && text.length >= max) {
      return; // Ignore when at max length
    }

    final newText = StringBuffer()
      ..write(text.substring(0, selectionIndex))
      ..write(upper)
      ..write(text.substring(selectionIndex));

    final caret = selectionIndex + 1;
    widget.controller.value = TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: caret),
    );
  }

  void _handleBackspace() {
    final text = widget.controller.text;
    final sel = widget.controller.selection;
    final idx = sel.isValid ? sel.baseOffset : text.length;
    if (idx <= 0 || text.isEmpty) {
      return;
    }

    final newText = text.substring(0, idx - 1) + text.substring(idx);
    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: idx - 1),
    );
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
