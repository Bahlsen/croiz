import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/services/providers.dart';

/// A simple in-app virtual keyboard with uppercase A–Z letters,
/// Backspace, and Enter. Designed for puzzle/game input.
class VirtualKeyboard extends ConsumerWidget {
  const VirtualKeyboard({
    super.key,
    this.onKey,
    this.onBackspace,
    this.enabledLetters,
    this.layout,
    this.includeBackspace = true,
    this.keyHeight = 52,
    this.keySpacing = 6,
    this.rowSpacing = 8,
    this.padding = const EdgeInsets.all(8),
    this.enableFeedback = true,
    this.keyRadius = 4,
    this.keyColor,
    this.disabledKeyColor,
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

  /// Rayon des coins pour rendre les touches plus rectangulaires.
  final double keyRadius;

  /// Couleur de fond des touches actives (override du thème).
  final Color? keyColor;

  /// Couleur de fond des touches désactivées.
  final Color? disabledKeyColor;

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
    final rows = List<List<String>>.from(
      (layout ?? _defaultAzertyLayout).map(List<String>.from),
    );
    if (includeBackspace) {
      final hasBackspace = rows.any((r) => r.contains(_backspaceToken));
      if (!hasBackspace && rows.isNotEmpty) {
        rows[rows.length - 1].add(_backspaceToken);
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Compute a key height that also respects vertical constraints
        // when the parent provides a finite height (e.g., tests).
        final availableHeight = constraints.maxHeight.isFinite
            ? (constraints.maxHeight - padding.vertical)
            : double.infinity;
        final rowCount = rows.length;
        final totalSpacing = rowCount > 0 ? rowSpacing * (rowCount - 1) : 0.0;
        final maxKeyHeightByHeight = (availableHeight.isFinite && rowCount > 0)
            ? ((availableHeight - totalSpacing) / rowCount).clamp(0.0, double.infinity)
            : double.infinity;

        // We'll cap keyHeight by both width-derived and height-derived constraints
        final effectiveKeyHeight = (keyHeight.isFinite
          ? keyHeight.clamp(24, maxKeyHeightByHeight)
          : maxKeyHeightByHeight.isFinite
            ? maxKeyHeightByHeight
            : keyHeight).toDouble();

        return Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                _ResponsiveKeyboardRow(
                  keys: rows[i],
                  keyHeight: effectiveKeyHeight,
                  keySpacing: keySpacing,
                  onKey: (k) => onKey?.call(k.toUpperCase()),
                  onBackspace: onBackspace,
                  onPlayClick: () {
                    try {
                      ref.read(gameAudioServiceProvider).playType();
                    } on Object catch (e, st) {
                      developer.log('GameAudioService.playType failed', error: e, stackTrace: st);
                    }
                  },
                  onPlayDelete: () {
                    try {
                      ref.read(gameAudioServiceProvider).playDelete();
                    } on Object catch (e, st) {
                      developer.log('GameAudioService.playDelete failed', error: e, stackTrace: st);
                    }
                  },
                  enabledLetters: enabledLetters,
                  enableFeedback: enableFeedback,
                  keyRadius: keyRadius,
                  keyColor: keyColor,
                  disabledKeyColor: disabledKeyColor,
                ),
                if (i != rows.length - 1) SizedBox(height: rowSpacing),
              ],
            ],
          ),
        );
      },
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
    required this.onPlayClick,
    required this.onPlayDelete,
    required this.enabledLetters,
    required this.enableFeedback,
    required this.keyRadius,
    required this.keyColor,
    required this.disabledKeyColor,
  });

  final List<String> keys;
  final double keyHeight;
  final double keySpacing;
  final ValueChanged<String> onKey;
  final VoidCallback? onBackspace;
  final VoidCallback? onPlayClick;
  final VoidCallback? onPlayDelete;
  final Set<String>? enabledLetters;
  final bool enableFeedback;
  final double keyRadius;
  final Color? keyColor;
  final Color? disabledKeyColor;

  @override
  Widget build(BuildContext context) {
    // Precompute enabled letter set uppercase for fast lookup.
    final enabledSet = enabledLetters?.map((e) => e.toUpperCase()).toSet();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Weight: letter=1, backspace=2
        var totalWeight = 0;
        for (final k in keys) {
          totalWeight += k == VirtualKeyboard.backspaceToken ? 2 : 1;
        }
        final spacingTotal = keySpacing * (keys.length - 1);
        // If constraints.maxWidth is unbounded (tests / odd layouts), fall
        // back to MediaQuery width to compute sensible button sizes.
        final rawMaxWidth = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : MediaQuery.of(context).size.width;
        final availableWidth = (rawMaxWidth - spacingTotal).clamp(0.0, double.infinity);
        final unitWidth = totalWeight > 0 ? (availableWidth / totalWeight) : keyHeight;
        // Enlarged keys: raise lower bound but cap the maximum height so
        // extremely wide layouts don't produce enormous key heights.
        final maxFromWidth = unitWidth.isFinite ? (unitWidth * 1.2).clamp(24, 96) : 96;
        final buttonHeight = keyHeight.clamp(24, maxFromWidth);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < keys.length; i++) ...[
              _buildKey(
                context,
                keys[i],
                unitWidth.toDouble(),
                buttonHeight.toDouble(),
                enabledSet,
              ),
              if (i != keys.length - 1) SizedBox(width: keySpacing),
            ],
          ],
        );
      },
    );
  }

  Widget _buildKey(
    BuildContext context,
    String k,
    double unitWidth,
    double height,
    Set<String>? enabledSet,
  ) {
    if (k == VirtualKeyboard.backspaceToken) {
      return _BackspaceKey(
        height: height,
        width: unitWidth * 2,
        onBackspace: onBackspace,
        onPlayDelete: onPlayDelete,
        enableFeedback: enableFeedback,
        radius: keyRadius,
        keyColor: keyColor,
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
                try {
                  onPlayClick?.call();
                } on Object catch (e, st) {
                  developer.log('GameAudioService.playType failed', error: e, stackTrace: st);
                }
              }
              onKey(label);
            }
          : null,
      radius: keyRadius,
      keyColor: keyColor,
      disabledKeyColor: disabledKeyColor,
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
    required this.radius,
    required this.keyColor,
    required this.disabledKeyColor,
  });

  final String label;
  final double height;
  final double width;
  final bool enabled;
  final VoidCallback? onPressed;
  final double radius;
  final Color? keyColor;
  final Color? disabledKeyColor;

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
            backgroundColor: keyColor ??
              scheme.surfaceContainerHighest.withValues(alpha: 0.32),
            foregroundColor: scheme.onSurface,
            disabledBackgroundColor:
              disabledKeyColor ?? scheme.onSurface.withValues(alpha: 0.08),
            disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
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
    required this.onPlayDelete,
    required this.enableFeedback,
    required this.radius,
    required this.keyColor,
  });

  final double height;
  final double width;
  final VoidCallback? onBackspace;
  final VoidCallback? onPlayDelete;
  final bool enableFeedback;
  final double radius;
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
        developer.log('GameAudioService.playDelete failed', error: e, stackTrace: st);
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
        // t.tick differs each call; recreate timer on phase change.
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
  Widget build(BuildContext context) => Semantics(
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
          style: FilledButton.styleFrom(
            backgroundColor: widget.keyColor ??
                Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.38),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.radius),
            ),
            padding: EdgeInsets.zero,
          ),
          child: const Icon(Icons.backspace_outlined),
        ),
      ),
    ),
  );
}

// Marker class so we know we already uppercased/cached.
