import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_timer_provider.dart';

/// Stream provider that emits the elapsed seconds for the given `gameId`
/// every second.
final elapsedSecondsProvider = StreamProvider.family<int, String>((ref, gameId) {
  // Use a StreamController + Timer so we can cancel the timer deterministically
  // when the provider is disposed. This avoids leaving pending fake timers in
  // widget tests that use FakeAsync.
  final controller = StreamController<int>();

  // Emit initial value
  try {
    controller.add(ref.read(gameTimerProvider(gameId)).elapsedSeconds);
  } on Object {
    // ignore
  }

  final timer = Timer.periodic(const Duration(seconds: 1), (_) {
    try {
      if (!ref.mounted) {
        return;
      }
      controller.add(ref.read(gameTimerProvider(gameId)).elapsedSeconds);
    } on Object {
      // ignore
    }
  });

  ref.onDispose(() {
    try {
      timer.cancel();
    } on Object {
      // ignore
    }
    try {
      controller.close();
    } on Object {
      // ignore
    }
  });

  return controller.stream;
});
