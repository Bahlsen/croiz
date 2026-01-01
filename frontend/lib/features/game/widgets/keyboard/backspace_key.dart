import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:croiz/l10n/app_localizations.dart';

/// A backspace key with long-press repeat acceleration.
class BackspaceKey extends StatefulWidget {
  const BackspaceKey({
    required this.height,
    required this.onBackspace,
    required this.onPlayDelete,
    required this.enableFeedback,
    required this.borderRadius,
    required this.keyColor,
    super.key,
  });

  final double height;
  final VoidCallback? onBackspace;
  final VoidCallback? onPlayDelete;
  final bool enableFeedback;
  final BorderRadius borderRadius;
  final Color? keyColor;

  @override
  State<BackspaceKey> createState() => _BackspaceKeyState();
}

class _BackspaceKeyState extends State<BackspaceKey> {
  Timer? _repeatTimer;
  int _phase = 0;
  int? _repeatIntervalMs;

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
    _repeatIntervalMs = 260;
    _repeatTimer = Timer.periodic(const Duration(milliseconds: 260), (t) {
      _trigger();
      _phase++;
      final newIntervalMs = _phase > 8
          ? 55
          : _phase > 3
          ? 110
          : 260;
      if (newIntervalMs != _repeatIntervalMs) {
        t.cancel();
        _repeatTimer = Timer.periodic(
          Duration(milliseconds: newIntervalMs),
          (_) => _trigger(),
        );
        _repeatIntervalMs = newIntervalMs;
      }
    });
  }

  void _stopRepeat() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
    _repeatIntervalMs = null;
  }

  @override
  void dispose() {
    _stopRepeat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppLocalizations.of(context)?.delete ?? 'Delete',
    button: true,
    child: GestureDetector(
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
                Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(borderRadius: widget.borderRadius),
          ),
          child: Icon(
            Icons.backspace_outlined,
            size: 28,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    ),
  );
}
