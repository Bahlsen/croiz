// ignore_for_file: sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/providers/game_timer_provider.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/features/game/widgets/loader/crossword_loader.dart';
import 'package:croiz/features/game/widgets/content/crossword_content.dart';

class CrosswordBody extends ConsumerStatefulWidget {
  final CrosswordInputController controller;

  const CrosswordBody({required this.controller, Key? key}) : super(key: key);

  @override
  ConsumerState<CrosswordBody> createState() => _CrosswordBodyState();
}

class _CrosswordBodyState extends ConsumerState<CrosswordBody> {
  bool _boardListenerAttached = false;

  @override
  Widget build(BuildContext context) {
    final puzzleAsync = ref.watch(puzzleLoaderProvider);

    if (puzzleAsync is AsyncLoading) {
      return const CrosswordLoadingScaffold();
    }

    if (puzzleAsync is AsyncError) {
      final selected = ref.read(selectedPuzzleIdProvider) ?? '<null>';
      return CrosswordErrorScaffold(selectedId: selected);
    }
    if (!_boardListenerAttached) {
      _boardListenerAttached = true;
      ref.listen<GameBoard>(gameBoardProvider, (
        GameBoard? previous,
        GameBoard next,
      ) {
        try {
          widget.controller.tryAutoSelectFirstAcross(next);
        } on Object catch (e, st) {
          if (kDebugMode) {
            debugPrint('Error auto-selecting first across: $e\n$st');
          }
        }

        try {
          ref.read(gameTimerProvider(next.id)).start();
        } on Object catch (e, st) {
          if (kDebugMode) {
            debugPrint('Error starting game timer: $e\n$st');
          }
        }
      });

      Future.microtask(() {
        try {
          final current = ref.read(gameBoardProvider);
          widget.controller.tryAutoSelectFirstAcross(current);
        } on Object catch (e, st) {
          if (kDebugMode) {
            debugPrint('Error auto-selecting first across (initial): $e\n$st');
          }
        }
        try {
          final current = ref.read(gameBoardProvider);
          ref.read(gameTimerProvider(current.id)).start();
        } on Object catch (e, st) {
          if (kDebugMode) {
            debugPrint('Error starting game timer (initial): $e\n$st');
          }
        }
      });
    }

    final gridSize = ref
        .watch(gameBoardProvider.select((b) => b.gridSize))
        .clamp(3, 12);
    if (kDebugMode) {
      debugPrint('CrosswordBody gridSize=$gridSize');
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: CrosswordContent(controller: widget.controller),
    );
  }
}
