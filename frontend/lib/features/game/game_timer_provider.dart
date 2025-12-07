// ignore_for_file: sort_constructors_first
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/services/providers.dart';

/// Simple persistent game timer per puzzle/gameId.
///
/// KISS: not a Notifier — lightweight class wrapped by a Provider.family.
class GameTimer {
  final Ref ref;
  final String gameId;

  DateTime? _startedAt;
  int _accumulatedMs = 0;

  GameTimer(this.ref, this.gameId) {
    _restore();
  }

  Future<void> _restore() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final started = await storage.read(key: 'puzzle:$gameId:startedAt');
      final acc = await storage.read(key: 'puzzle:$gameId:accumulatedMs');
      if (acc != null) {
        _accumulatedMs = int.tryParse(acc) ?? 0;
      }
      if (started != null) {
        final ms = int.tryParse(started);
        if (ms != null) {
          _startedAt = DateTime.fromMillisecondsSinceEpoch(ms);
        }
      }
    } on Object catch (e, st) {
      developer.log('GameTimer._restore failed', error: e, stackTrace: st);
    }
  }

  int get elapsedMs {
    if (_startedAt != null) {
      final delta = DateTime.now().difference(_startedAt!).inMilliseconds;
      return _accumulatedMs + delta;
    }
    return _accumulatedMs;
  }

  int get elapsedSeconds => (elapsedMs / 1000).floor();

  String formattedElapsed() {
    final s = elapsedSeconds;
    final mm = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  Future<void> start() async {
    if (_startedAt != null) {
      return;
    }
    _startedAt = DateTime.now();
    try {
      await ref
          .read(secureStorageProvider)
          .write(
            key: 'puzzle:$gameId:startedAt',
            value: _startedAt!.millisecondsSinceEpoch.toString(),
          );
    } on Object catch (e, st) {
      developer.log(
        'GameTimer.start: failed to persist startedAt',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> pause() async {
    if (_startedAt == null) {
      return;
    }
    _accumulatedMs = elapsedMs;
    _startedAt = null;
    try {
      final storage = ref.read(secureStorageProvider);
      await storage.write(
        key: 'puzzle:$gameId:accumulatedMs',
        value: _accumulatedMs.toString(),
      );
      await storage.delete(key: 'puzzle:$gameId:startedAt');
    } on Object catch (e, st) {
      developer.log(
        'GameTimer.pause: failed to persist pause state',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Finalize the timer synchronously and persist asynchronously.
  /// Returns elapsed seconds (integer).
  int finalizeSync() {
    final totalMs = elapsedMs;
    _accumulatedMs = totalMs;
    _startedAt = null;

    try {
      final storage = ref.read(secureStorageProvider);
      // persist asynchronously, prefer handling errors to avoid unhandled async
      storage
          .write(
            key: 'puzzle:$gameId:accumulatedMs',
            value: _accumulatedMs.toString(),
          )
          .catchError((_) {});
      storage
          .write(
            key: 'puzzle:$gameId:completedAt',
            value: DateTime.now().millisecondsSinceEpoch.toString(),
          )
          .catchError((_) {});
      storage.delete(key: 'puzzle:$gameId:startedAt').catchError((_) {});
    } on Object catch (e, st) {
      developer.log(
        'GameTimer.finalizeSync: failed to persist state',
        error: e,
        stackTrace: st,
      );
    }

    return (totalMs / 1000).floor();
  }

  Future<void> clear() async {
    _startedAt = null;
    _accumulatedMs = 0;
    try {
      final storage = ref.read(secureStorageProvider);
      await storage.delete(key: 'puzzle:$gameId:startedAt');
      await storage.delete(key: 'puzzle:$gameId:accumulatedMs');
      await storage.delete(key: 'puzzle:$gameId:completedAt');
    } on Object catch (e, st) {
      developer.log(
        'GameTimer.clear: failed to clear storage keys',
        error: e,
        stackTrace: st,
      );
    }
  }
}

final gameTimerProvider = Provider.family<GameTimer, String>(GameTimer.new);
