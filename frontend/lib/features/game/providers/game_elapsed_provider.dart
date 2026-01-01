import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'game_timer_provider.dart';

part 'game_elapsed_provider.g.dart';

/// Stream provider that emits the elapsed seconds for the given `gameId`
/// every second.
@riverpod
Stream<int> elapsedSeconds(Ref ref, String gameId) {
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
}

// Compatibility alias
// Note: Family providers cannot be simply aliased with `final x = y;` because
// the generated provider is a callable class, not the provider itself.
// However, migration is usually strict. We should check usages.
// The generated provider `elapsedSecondsProvider` is a family.
// `ref.watch(elapsedSecondsProvider(id))` works.
// The old ONE was `elapsedSecondsProvider(id)`.
// So the name matches! No alias needed if I name the function `elapsedSeconds`.
