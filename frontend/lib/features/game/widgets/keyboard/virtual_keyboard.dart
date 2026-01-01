import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:croiz/services/providers.dart';
import 'keyboard_row.dart';

/// A simple in-app virtual keyboard with uppercase A–Z letters and Backspace.
///
/// ## Layout Architecture (Flutter Best Practice)
///
/// This widget follows Flutter's constraint model: "Constraints go down.
/// Sizes go up. Parent sets position."
///
/// The keyboard has an **intrinsic height** determined by:
/// - [keyHeight] × number of rows
/// - [rowSpacing] × (rows - 1)
/// - [padding] vertical
///
/// The parent should NOT try to resize the keyboard. Instead:
/// 1. Place keyboard in a Column with `mainAxisSize: MainAxisSize.min`
/// 2. Let the keyboard report its intrinsic size upward
/// 3. Use `Expanded` on sibling widgets that should take remaining space
///
/// Width adapts to parent constraints (fills available width).
class VirtualKeyboard extends ConsumerWidget {
  const VirtualKeyboard({
    super.key,
    this.onKey,
    this.onBackspace,
    this.enabledLetters,
    this.layout,
    this.includeBackspace = true,
    this.keyHeight = 64,
    this.letterFontSize = 16,
    this.keySpacing = 4,
    this.rowSpacing = 4,
    this.padding = const EdgeInsets.all(2),
    this.enableFeedback = true,
    this.keyRadius = 4,
    this.keyColor,
    this.disabledKeyColor,
  });

  final ValueChanged<String>? onKey;
  final VoidCallback? onBackspace;
  final Set<String>? enabledLetters;
  final List<List<String>>? layout;
  final bool includeBackspace;

  /// Height of each key row. This is the PRIMARY sizing parameter.
  /// The keyboard's total height = (keyHeight × rows) + spacing + padding.
  final double keyHeight;

  final double letterFontSize;
  final double keySpacing;
  final double rowSpacing;
  final EdgeInsets padding;
  final bool enableFeedback;
  final double keyRadius;
  final Color? keyColor;
  final Color? disabledKeyColor;

  /// Token used to represent the backspace key in layouts.
  static const String backspaceToken = 'BACKSPACE';

  /// Default AZERTY layout without backspace (added dynamically if needed).
  static const List<List<String>> _defaultAzertyLayout = [
    ['A', 'Z', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['Q', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['W', 'X', 'C', 'V', 'B', 'N', 'M'],
  ];

  /// AZERTY layout with backspace included.
  static const List<List<String>> azertyLayout = [
    ['A', 'Z', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['Q', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['W', 'X', 'C', 'V', 'B', 'N', 'M', backspaceToken],
  ];

  /// QWERTY layout with backspace included.
  static const List<List<String>> qwertyLayout = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M', backspaceToken],
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = _buildRows();
    final rowCount = rows.length;
    final totalSpacing = rowCount > 1 ? rowSpacing * (rowCount - 1) : 0.0;

    // Calculate intrinsic height - this is what we report to the parent
    final intrinsicHeight =
        (keyHeight * rowCount) + totalSpacing + padding.vertical;

    if (kDebugMode) {
      debugPrint(
        'VirtualKeyboard: keyHeight=$keyHeight rows=$rowCount '
        'intrinsicHeight=$intrinsicHeight',
      );
    }

    // Use SizedBox to declare our intrinsic height to the parent.
    // Width is unconstrained (will fill parent's width).
    return SizedBox(
      height: intrinsicHeight,
      child: Padding(
        padding: padding,
        child: Column(
          // min ensures we don't try to expand beyond our declared height
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              SizedBox(
                height: keyHeight,
                child: KeyboardRow(
                  keys: rows[i],
                  keyHeight: keyHeight,
                  letterFontSize: letterFontSize,
                  keySpacing: keySpacing,
                  // No rowMaxWidth - let KeyboardRow handle its own width
                  onKey: (k) => onKey?.call(k.toUpperCase()),
                  onBackspace: onBackspace,
                  onPlayClick: () => _maybePlayType(ref),
                  onPlayDelete: () => _maybePlayDelete(ref),
                  enabledLetters: enabledLetters,
                  enableFeedback: enableFeedback,
                  keyRadius: keyRadius,
                  keyColor: keyColor,
                  disabledKeyColor: disabledKeyColor,
                ),
              ),
              if (i != rows.length - 1) SizedBox(height: rowSpacing),
            ],
          ],
        ),
      ),
    );
  }

  /// Build the keyboard rows, adding backspace if needed.
  List<List<String>> _buildRows() {
    final baseLayout = layout ?? _defaultAzertyLayout;
    final hasBack = baseLayout.any((r) => r.contains(backspaceToken));

    if (includeBackspace && !hasBack && baseLayout.isNotEmpty) {
      // Only copy when we need to add backspace
      final rows = List<List<String>>.from(baseLayout.map(List<String>.from));
      rows.last.add(backspaceToken);
      return rows;
    }

    // Use layout directly - no copy needed
    return baseLayout;
  }

  // Simplified audio playback - throttling is handled by GameAudioService.
  static void _maybePlayType(WidgetRef ref) {
    if (ref.read(gameAudioMutedProvider)) {
      return;
    }
    try {
      ref.read(gameAudioServiceProvider).playType();
    } on Object catch (e, st) {
      developer.log(
        'GameAudioService.playType failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  static void _maybePlayDelete(WidgetRef ref) {
    if (ref.read(gameAudioMutedProvider)) {
      return;
    }
    try {
      ref.read(gameAudioServiceProvider).playDelete();
    } on Object catch (e, st) {
      developer.log(
        'GameAudioService.playDelete failed',
        error: e,
        stackTrace: st,
      );
    }
  }
}
