import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A simple in-app virtual keyboard with uppercase A–Z letters,
/// Backspace, and Enter. Designed for puzzle/game input.
class VirtualKeyboard extends StatelessWidget {
  const VirtualKeyboard({
    super.key,
    this.onKey,
    this.onBackspace,
    this.enabledLetters,
    this.layout,
    this.includeBackspace = true,
    this.keyHeight = 44,
    this.keySpacing = 6,
    this.rowSpacing = 8,
    this.padding = const EdgeInsets.all(8),
    this.enableFeedback = true,
  });

  /// Called when a letter key is tapped. Always uppercase A–Z.
  final ValueChanged<String>? onKey;
  final VoidCallback? onBackspace;

  /// When provided, letters not in this set render disabled.
  final Set<String>? enabledLetters;

  /// Optional custom layout (rows of keys). Use 'BACKSPACE' and 'ENTER' tokens for special keys.
  final List<List<String>>? layout;
  /// Inclure automatiquement la touche Backspace si absente de la dernière rangée.
  final bool includeBackspace;

  final double keyHeight;
  final double keySpacing;
  final double rowSpacing;
  final EdgeInsets padding;
  final bool enableFeedback;

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
  Widget build(BuildContext context) {
    var rows = List<List<String>>.from((layout ?? _defaultAzertyLayout).map((r) => List<String>.from(r)));
    if (includeBackspace) {
      final hasBackspace = rows.any((r) => r.contains(_backspaceToken));
      if (!hasBackspace && rows.isNotEmpty) {
        rows[rows.length - 1].add(_backspaceToken);
      }
    }

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _ResponsiveKeyboardRow(
              keys: rows[i],
              keyHeight: keyHeight,
              keySpacing: keySpacing,
              onKey: (k) => onKey?.call(k.toUpperCase()),
              onBackspace: onBackspace,
              enabledLetters: enabledLetters,
              enableFeedback: enableFeedback,
            ),
            if (i != rows.length - 1) SizedBox(height: rowSpacing),
          ],
        ],
      ),
    );
  }

  static String get backspaceToken => _backspaceToken;
}

class _ResponsiveKeyboardRow extends StatelessWidget {
  const _ResponsiveKeyboardRow({
    required this.keys,
    required this.keyHeight,
    required this.keySpacing,
    required this.onKey,
    required this.onBackspace,
    required this.enabledLetters,
    required this.enableFeedback,
  });

  final List<String> keys;
  final double keyHeight;
  final double keySpacing;
  final ValueChanged<String> onKey;
  final VoidCallback? onBackspace;
  final Set<String>? enabledLetters;
  final bool enableFeedback;

  @override
  Widget build(BuildContext context) {
    // Precompute enabled letter set uppercase for fast lookup.
    final enabledSet = enabledLetters == null
      ? null
      : enabledLetters!.map((e) => e.toUpperCase()).toSet();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Weight: letter=1, backspace=2
        int totalWeight = 0;
        for (final k in keys) {
          totalWeight += k == VirtualKeyboard.backspaceToken ? 2 : 1;
        }
        final spacingTotal = keySpacing * (keys.length - 1);
        final availableWidth = constraints.maxWidth - spacingTotal;
        final unitWidth = availableWidth / totalWeight;
        final buttonHeight = keyHeight.clamp(32, unitWidth * 1.3);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < keys.length; i++) ...[
              _buildKey(context, keys[i], unitWidth.toDouble(), buttonHeight.toDouble(), enabledSet),
              if (i != keys.length - 1) SizedBox(width: keySpacing),
            ],
          ],
        );
      },
    );
  }

  Widget _buildKey(BuildContext context, String k, double unitWidth, double height, Set<String>? enabledSet) {
    if (k == VirtualKeyboard.backspaceToken) {
      return _BackspaceKey(
        height: height,
        width: unitWidth * 2,
        onBackspace: onBackspace,
        enableFeedback: enableFeedback,
      );
    }

    final label = k.toUpperCase();
    final enabled = enabledSet == null || enabledSet.contains(label);
    return _LetterKey(
      label: label,
      height: height,
      width: unitWidth,
      enabled: enabled,
      onPressed: enabled
          ? () {
              if (enableFeedback) {
                HapticFeedback.selectionClick();
                SystemSound.play(SystemSoundType.click);
              }
              onKey(label);
            }
          : null,
    );
  }
}

class _LetterKey extends StatelessWidget {
  const _LetterKey({
    required this.label,
    required this.height,
    required this.width,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final double height;
  final double width;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Lettre $label',
      button: true,
      enabled: enabled,
      child: SizedBox(
        height: height,
        width: width,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            disabledBackgroundColor: scheme.onSurface.withOpacity(0.08),
            disabledForegroundColor: scheme.onSurface.withOpacity(0.38),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  letterSpacing: 1.2,
                  fontFeatures: const [FontFeature.enable('case')],
                ),
          ),
        ),
      ),
    );
  }
}

// Removed generic _SpecialKey (Enter no longer used).

class _BackspaceKey extends StatefulWidget {
  const _BackspaceKey({
    required this.height,
    required this.width,
    required this.onBackspace,
    required this.enableFeedback,
  });

  final double height;
  final double width;
  final VoidCallback? onBackspace;
  final bool enableFeedback;

  @override
  State<_BackspaceKey> createState() => _BackspaceKeyState();
}

class _BackspaceKeyState extends State<_BackspaceKey> {
  Timer? _repeatTimer;
  int _phase = 0;

  void _trigger() {
    if (widget.enableFeedback) {
      HapticFeedback.selectionClick();
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
      if (newInterval != t.tick) { // t.tick differs each call; recreate timer on phase change.
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
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Effacer',
      button: true,
      child: GestureDetector(
        onTap: _trigger,
        // Support both start and generic long press to be robust in tests.
        onLongPressStart: (_) => _startRepeat(),
        onLongPress: _startRepeat,
        onLongPressEnd: (_) => _stopRepeat(),
        onLongPressCancel: _stopRepeat,
        child: SizedBox(
          height: widget.height,
          width: widget.width,
          child: FilledButton(
            onPressed: _trigger,
            child: const Icon(Icons.backspace_outlined),
          ),
        ),
      ),
    );
  }
}

// Marker class so we know we already uppercased/cached.
