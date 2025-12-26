import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:croiz/services/providers.dart';
import 'keyboard/keyboard_row.dart';

/// A simple in-app virtual keyboard with uppercase A–Z letters and Backspace.
class VirtualKeyboard extends ConsumerWidget {
  const VirtualKeyboard({
    super.key,
    this.onKey,
    this.onBackspace,
    this.enabledLetters,
    this.layout,
    this.includeBackspace = true,
    this.keyHeight = 64,
    this.keySpacing = 4,
    this.rowSpacing = 4,
    this.padding = const EdgeInsets.all(2),
    this.enableFeedback = true,
    this.keyRadius = 4,
    this.keyColor,
    this.disabledKeyColor,
    this.availableHeight,
  });

  final ValueChanged<String>? onKey;
  final VoidCallback? onBackspace;
  final Set<String>? enabledLetters;
  final List<List<String>>? layout;
  final bool includeBackspace;
  final double keyHeight;
  final double keySpacing;
  final double rowSpacing;
  final EdgeInsets padding;
  final bool enableFeedback;
  final double keyRadius;
  final Color? keyColor;
  final Color? disabledKeyColor;

  /// When provided, the parent precomputes the vertical space available
  /// for the keyboard and passes it here. This avoids LayoutBuilder usage
  /// inside the keyboard and makes tests deterministic.
  final double? availableHeight;

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

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final metrics = _computeLayoutMetrics(context, constraints, rows);

        if (kDebugMode) {
          debugPrint(
            'VirtualKeyboard.layout: rawAvailable=${metrics.rawAvailable} '
            'parentAvailable=${metrics.parentAvailable} rowCount=${rows.length} '
            'totalSpacing=${metrics.totalSpacing} effectiveKeyHeight=${metrics.effectiveKeyHeight}',
          );
        }

        return Semantics(
          container: true,
          child: Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  SizedBox(
                    height: metrics.effectiveKeyHeight,
                    child: KeyboardRow(
                      keys: rows[i],
                      keyHeight: metrics.effectiveKeyHeight,
                      keySpacing: keySpacing,
                      rowMaxWidth: metrics.availableRowWidth,
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
      },
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

  /// Compute layout metrics for the keyboard.
  _LayoutMetrics _computeLayoutMetrics(
    BuildContext context,
    BoxConstraints constraints,
    List<List<String>> rows,
  ) {
    final rowCount = rows.length;
    final totalSpacing = rowCount > 0 ? rowSpacing * (rowCount - 1) : 0.0;

    final rawAvailable = _computeRawAvailableHeight(context, constraints);
    final parentAvailable = (rawAvailable - padding.vertical).clamp(
      0.0,
      double.infinity,
    );

    final effectiveKeyHeight = _computeEffectiveKeyHeight(
      rowCount,
      totalSpacing,
      parentAvailable,
    );

    final rawMaxWidth = constraints.maxWidth.isFinite
        ? constraints.maxWidth
        : MediaQuery.of(context).size.width;
    final availableRowWidth = rawMaxWidth.isFinite
        ? (rawMaxWidth - padding.horizontal).clamp(0.0, double.infinity)
        : double.infinity;

    return _LayoutMetrics(
      rawAvailable: rawAvailable,
      parentAvailable: parentAvailable,
      totalSpacing: totalSpacing,
      effectiveKeyHeight: effectiveKeyHeight,
      availableRowWidth: availableRowWidth,
    );
  }

  double _computeRawAvailableHeight(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    if (availableHeight != null) {
      return math.min<double>(
        availableHeight!,
        constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height,
      );
    }
    if (constraints.maxHeight.isFinite) {
      return constraints.maxHeight;
    }

    // When the keyboard is placed in a parent that gives it unbounded
    // vertical constraints (for example, a Column with mainAxisSize.min),
    // avoid sizing to the full screen height. Use a conservative fraction
    // of the viewport so the keyboard remains reasonable and does not
    // cause downstream overflow when the outer layout is constrained.
    const fallbackFraction = 0.25; // 25% of screen height
    return (MediaQuery.of(context).size.height * fallbackFraction).clamp(
      0.0,
      double.infinity,
    );
  }

  double _computeEffectiveKeyHeight(
    int rowCount,
    double totalSpacing,
    double parentAvailable,
  ) {
    if (rowCount <= 0 || !parentAvailable.isFinite) {
      return keyHeight.clamp(24.0, double.infinity);
    }

    final maxRow = ((parentAvailable - totalSpacing) / rowCount).clamp(
      0.0,
      double.infinity,
    );
    var effectiveHeight = keyHeight > 0
        ? (keyHeight > maxRow ? maxRow : keyHeight)
        : maxRow;

    if (availableHeight != null) {
      final requiredTotal =
          (effectiveHeight * rowCount) + totalSpacing + padding.vertical;
      if (requiredTotal > availableHeight!) {
        effectiveHeight =
            ((availableHeight! - padding.vertical - totalSpacing) / rowCount)
                .clamp(0.0, double.infinity);
      }
    }

    return effectiveHeight;
  }

  // Simplified audio playback - throttling is handled by GameAudioService.
  // Removed UI-level coalescing to reduce overhead on each key press.
  static void _maybePlayType(WidgetRef ref) {
    // Respect global mute flag
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
    // Respect global mute flag
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

/// Internal class to hold computed layout metrics.
class _LayoutMetrics {
  const _LayoutMetrics({
    required this.rawAvailable,
    required this.parentAvailable,
    required this.totalSpacing,
    required this.effectiveKeyHeight,
    required this.availableRowWidth,
  });

  final double rawAvailable;
  final double parentAvailable;
  final double totalSpacing;
  final double effectiveKeyHeight;
  final double availableRowWidth;
}
