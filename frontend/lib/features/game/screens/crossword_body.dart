import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/features/game/widgets/loader/crossword_loader.dart';
import 'package:croiz/features/game/widgets/content/crossword_content.dart';
import 'package:croiz/features/game/listeners/game_board_observer.dart';

class CrosswordBody extends ConsumerStatefulWidget {
  const CrosswordBody({required this.controller, super.key});
  final CrosswordInputController controller;

  @override
  ConsumerState<CrosswordBody> createState() => _CrosswordBodyState();
}

class _CrosswordBodyState extends ConsumerState<CrosswordBody> {
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

    final gridSize = ref
        .watch(gameBoardProvider.select((b) => b.gridSize))
        .clamp(3, 12);
    if (kDebugMode) {
      debugPrint('CrosswordBody gridSize=$gridSize');
    }

    // Use GameBoardObserver which properly resets the controller when the
    // active puzzle changes (ensures auto-select runs each load).
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: true,
        top: true,
        child: GameBoardObserver(
          controller: widget.controller,
          child: CrosswordContent(controller: widget.controller),
        ),
      ),
    );
  }
}
