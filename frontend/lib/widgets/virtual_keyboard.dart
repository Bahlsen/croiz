import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/services/providers.dart';

/// A simple in-app virtual keyboard with uppercase A–Z letters and Backspace.
/// This file is a cleaned, single implementation (no duplicates).
class VirtualKeyboard extends ConsumerWidget {
  const VirtualKeyboard({
    super.key,
    this.onKey,
    this.onBackspace,
    this.enabledLetters,
    this.layout,
    this.includeBackspace = true,
    this.keyHeight = 64,
    this.keySpacing = 8,
    this.rowSpacing = 10,
    this.padding = const EdgeInsets.all(8),
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

  static const String _backspaceToken = 'BACKSPACE';

  List<List<String>> get _defaultAzertyLayout => const [
    ['A', 'Z', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['Q', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['W', 'X', 'C', 'V', 'B', 'N', 'M'],
  ];

  static const List<List<String>> azertyLayout = [
    ['A', 'Z', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['Q', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['W', 'X', 'C', 'V', 'B', 'N', 'M', _backspaceToken],
  ];

  static const List<List<String>> qwertyLayout = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M', _backspaceToken],
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Performance: avoid deep copying if layout already has backspace.
    // Layouts from static const already include backspace token.
    final baseLayout = layout ?? _defaultAzertyLayout;
    final hasBack = baseLayout.any((r) => r.contains(_backspaceToken));
    final List<List<String>> rows;
    if (includeBackspace && !hasBack && baseLayout.isNotEmpty) {
      // Only copy when we need to add backspace
      rows = List<List<String>>.from(baseLayout.map(List<String>.from));
      rows.last.add(_backspaceToken);
    } else {
      // Use layout directly - no copy needed
      rows = baseLayout;
    }

    // Wrap the rendered keyboard in a LayoutBuilder so we obtain the
    // real constraints supplied by the parent during layout. When the
    // parent passes `availableHeight`, prefer that (used by callers who
    // already compute the remaining space). Otherwise use the
    // LayoutBuilder's `constraints.maxHeight` (if finite) before
    // falling back to MediaQuery. This makes sizing deterministic and
    // avoids the keyboard assuming the full screen height while placed
    // inside a Column.
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final rowCount = rows.length;
        final totalSpacing = rowCount > 0 ? rowSpacing * (rowCount - 1) : 0.0;

        // Determine vertical space available for the keyboard (including
        // its padding). Priority: explicit `availableHeight` ->
        // constraints.maxHeight -> MediaQuery height.
        // Prefer the parent-provided `availableHeight` when present, but
        // ensure we never assume more vertical space than the incoming
        // layout constraints provide. Use the smaller of the two to avoid
        // computing child sizes that won't fit and cause RenderFlex
        // overflows.
        final rawAvailable = (availableHeight != null)
            ? math.min<double>(
                availableHeight!,
                constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : MediaQuery.of(context).size.height,
              )
            : (constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : MediaQuery.of(context).size.height);

        final parentAvailable = (rawAvailable - padding.vertical).clamp(
          0.0,
          double.infinity,
        );

        double effectiveKeyHeight;
        if (rowCount > 0 && parentAvailable.isFinite) {
          final maxRow = ((parentAvailable - totalSpacing) / rowCount).clamp(
            0.0,
            double.infinity,
          );
          effectiveKeyHeight = keyHeight > 0
              ? (keyHeight > maxRow ? maxRow : keyHeight)
              : maxRow;
          if (availableHeight != null) {
            final requiredTotal =
                (effectiveKeyHeight * rowCount) +
                totalSpacing +
                padding.vertical;
            if (requiredTotal > availableHeight!) {
              effectiveKeyHeight =
                  ((availableHeight! - padding.vertical - totalSpacing) /
                          rowCount)
                      .clamp(0.0, double.infinity);
            }
          }
        } else {
          effectiveKeyHeight = keyHeight.clamp(24.0, double.infinity);
        }

        if (kDebugMode) {
          debugPrint(
            'VirtualKeyboard.layout: rawAvailable=$rawAvailable parentAvailable=$parentAvailable rowCount=$rowCount totalSpacing=$totalSpacing effectiveKeyHeight=$effectiveKeyHeight',
          );
        }

        final rawMaxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final availableRowWidth = rawMaxWidth.isFinite
            ? (rawMaxWidth - padding.horizontal).clamp(0.0, double.infinity)
            : double.infinity;

        return Semantics(
          container: true,
          child: Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  SizedBox(
                    height: effectiveKeyHeight,
                    child: _ResponsiveKeyboardRow(
                      keys: rows[i],
                      keyHeight: effectiveKeyHeight,
                      keySpacing: keySpacing,
                      rowMaxWidth: availableRowWidth,
                      onKey: (k) => onKey?.call(k.toUpperCase()),
                      onBackspace: onBackspace,
                      onPlayClick: () => VirtualKeyboard._maybePlayType(ref),
                      onPlayDelete: () => VirtualKeyboard._maybePlayDelete(ref),
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

  static String get backspaceToken => _backspaceToken;

  // UI-level coalescing to avoid issuing audio requests too frequently.
  static DateTime? _lastUiTypeAt;
  static DateTime? _lastUiDeleteAt;
  static const _uiMinTypeInterval = Duration(milliseconds: 40);
  static const _uiMinDeleteInterval = Duration(milliseconds: 40);

  static void _maybePlayType(WidgetRef ref) {
    final now = DateTime.now();
    if (_lastUiTypeAt != null &&
        now.difference(_lastUiTypeAt!) < _uiMinTypeInterval) {
      return;
    }
    _lastUiTypeAt = now;
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
    final now = DateTime.now();
    if (_lastUiDeleteAt != null &&
        now.difference(_lastUiDeleteAt!) < _uiMinDeleteInterval) {
      return;
    }
    _lastUiDeleteAt = now;
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

class _ResponsiveKeyboardRow extends StatelessWidget {
  _ResponsiveKeyboardRow({
    required this.keys,
    required this.keyHeight,
    required this.keySpacing,
    required this.rowMaxWidth,
    required this.onKey,
    required this.onBackspace,
    required this.onPlayClick,
    required this.onPlayDelete,
    required this.enabledLetters,
    required this.enableFeedback,
    required double keyRadius,
    required this.keyColor,
    required this.disabledKeyColor,
  }) : borderRadius = BorderRadius.circular(keyRadius);

  final List<String> keys;
  final double keyHeight;
  final double keySpacing;
  final double rowMaxWidth;
  final ValueChanged<String> onKey;
  final VoidCallback? onBackspace;
  final VoidCallback? onPlayClick;
  final VoidCallback? onPlayDelete;
  final Set<String>? enabledLetters;
  final bool enableFeedback;
  // Performance: pre-computed BorderRadius to avoid recreation in children
  final BorderRadius borderRadius;
  final Color? keyColor;
  final Color? disabledKeyColor;

  @override
  Widget build(BuildContext context) {
    // Performance: skip uppercase mapping if enabledLetters is null (common case)
    final enabledSet = enabledLetters?.map((e) => e.toUpperCase()).toSet();

    // Use Expanded with flex weights so keys fit the available row width
    // reliably (letters weight=1, backspace weight=2). This avoids manual
    // width math depending on MediaQuery and prevents overflow.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < keys.length; i++) ...[
          Expanded(
            flex: keys[i] == VirtualKeyboard.backspaceToken ? 2 : 1,
            child: SizedBox(
              height: keyHeight,
              child: _buildKey(context, keys[i], keyHeight.toDouble(), enabledSet),
            ),
          ),
          if (i != keys.length - 1) SizedBox(width: keySpacing),
        ],
      ],
    );
  }

  Widget _buildKey(
    BuildContext context,
    String k,
    double height,
    Set<String>? enabledSet,
  ) {
    if (k == VirtualKeyboard.backspaceToken) {
      return _BackspaceKey(
        height: height,
        onBackspace: onBackspace,
        onPlayDelete: onPlayDelete,
        enableFeedback: enableFeedback,
        borderRadius: borderRadius,
        keyColor: keyColor,
      );
    }

    final label = k.toUpperCase();
    final enabled = enabledSet == null || enabledSet.contains(label);
    return Semantics(
      label: 'Lettre $label',
      button: true,
      child: _LetterKey(
        label: label,
        height: height,
        enabled: enabled,
        onPressed: enabled
            ? () {
                if (enableFeedback) {
                  HapticFeedback.selectionClick();
                }
                try {
                  onPlayClick?.call();
                } on Object catch (e, st) {
                  developer.log(
                    'GameAudioService.playType failed',
                    error: e,
                    stackTrace: st,
                  );
                }
                onKey(label);
              }
            : null,
        borderRadius: borderRadius,
        keyColor: keyColor,
        disabledKeyColor: disabledKeyColor,
      ),
    );
  }
}

class _LetterKey extends StatelessWidget {
  const _LetterKey({
    required this.label,
    required this.height,
    required this.enabled,
    required this.onPressed,
    required this.borderRadius,
    required this.keyColor,
    required this.disabledKeyColor,
  });

  final String label;
  final double height;
  final bool enabled;
  final VoidCallback? onPressed;
  final BorderRadius borderRadius;
  final Color? keyColor;
  final Color? disabledKeyColor;

  // Performance: cache style lookup
  static const _letterTextStyle = TextStyle(
    letterSpacing: 1.2,
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );
  static const _zeroPadding = EdgeInsets.zero;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Performance: avoid recreating ButtonStyle on every build.
    // Use resolve methods for theme-dependent colors.
    final style = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return disabledKeyColor ?? scheme.onSurface.withAlpha(20);
        }
        return keyColor ?? scheme.surfaceContainerHighest.withAlpha(82);
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withAlpha(97);
        }
        return scheme.onSurface;
      }),
      padding: const WidgetStatePropertyAll(_zeroPadding),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: borderRadius)),
    );
    
    return SizedBox(
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: style,
        child: Text(label, style: _letterTextStyle),
      ),
    );
  }
}

class _BackspaceKey extends StatefulWidget {
  const _BackspaceKey({
    required this.height,
    required this.onBackspace,
    required this.onPlayDelete,
    required this.enableFeedback,
    required this.borderRadius,
    required this.keyColor,
  });

  final double height;
  final VoidCallback? onBackspace;
  final VoidCallback? onPlayDelete;
  final bool enableFeedback;
  final BorderRadius borderRadius;
  final Color? keyColor;

  @override
  State<_BackspaceKey> createState() => _BackspaceKeyState();
}

class _BackspaceKeyState extends State<_BackspaceKey> {
  Timer? _repeatTimer;
  int _phase = 0;

  void _trigger() {
    if (widget.enableFeedback) {
      HapticFeedback.selectionClick();
      try {
        widget.onPlayDelete?.call();
      } on Object catch (e, st) {
        developer.log(
          'GameAudioService.playDelete failed',
          error: e,
          stackTrace: st,
        );
      }
    }
    widget.onBackspace?.call();
  }

  void _startRepeat() {
    _trigger();
    _phase = 0;
    _repeatTimer?.cancel();
    _repeatTimer = Timer.periodic(const Duration(milliseconds: 260), (t) {
      _trigger();
      _phase++;
      final newInterval = _phase > 8
          ? const Duration(milliseconds: 55)
          : _phase > 3
          ? const Duration(milliseconds: 110)
          : const Duration(milliseconds: 260);
      if (newInterval != t.tick) {
        t.cancel();
        _repeatTimer = Timer.periodic(newInterval, (_) => _trigger());
      }
    });
  }

  void _stopRepeat() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  @override
  void dispose() {
    _stopRepeat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: _trigger,
      onLongPressStart: (_) => _startRepeat(),
      onLongPress: _startRepeat,
      onLongPressEnd: (_) => _stopRepeat(),
      onLongPressCancel: _stopRepeat,
      child: SizedBox(
        height: widget.height,
        child: FilledButton(
          onPressed: _trigger,
          style: FilledButton.styleFrom(
            backgroundColor:
                widget.keyColor ??
                Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withAlpha(97), // 0.38 * 255
            shape: RoundedRectangleBorder(borderRadius: widget.borderRadius),
            padding: EdgeInsets.zero,
          ),
          child: const Icon(Icons.backspace_outlined),
        ),
      ),
    );

  // Marker class so we know we already uppercased/cached.
}
