import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/puzzles/puzzles_list_page.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';

/// Integration-style widget test that reproduces the selection flow and
/// captures the asset path passed to the puzzle loader. This confirms the
/// bug where selection yields `assets/data/<id>.json` instead of the
/// full indexed path under subfolders.
void main() {
  testWidgets('Selecting a puzzle passes wrong asset path to loader', (
    tester,
  ) async {
    final descriptor = PuzzleDescriptor(
      id: 'mm1998-05-06',
      title: 'RIGHT ON THE MONEY (May/June 1998)',
      // path is relative to `assets/data/` as produced by the generator
      path: 'aarp/1998/mm1998-05-06.json',
      origin: 'aarp',
      year: '1998',
    );

    // Provide the index synchronously as AsyncData so PuzzlesListPage uses it.
    final puzzlesAsync = AsyncValue.data(<PuzzleDescriptor>[descriptor]);

    final captured = Completer<String>();

    Future<GameBoard> fakeLoader(String assetPath) async {
      if (!captured.isCompleted) {
        captured.complete(assetPath);
      }
      return GameBoard(
        id: descriptor.id,
        title: descriptor.title,
        gridSize: 5,
        createdAt: DateTime.now(),
        grid: List.generate(5, (_) => List<String?>.filled(5, null)),
        clues: {},
        blackCells: List.generate(5, (_) => List<bool>.filled(5, false)),
        difficulty: 1,
      );
    }

    // Simple router: list page at /, crossword at /crossword triggers loader.
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const PuzzlesListPage(),
        ),
        GoRoute(
          path: '/crossword',
          builder: (context, state) => const _CrosswordPlaceholder(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          puzzlesProvider.overrideWithValue(puzzlesAsync),
          puzzleAssetLoaderProvider.overrideWithValue(fakeLoader),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    // Expand origin and year to reveal the puzzle tile
    await tester.tap(find.text('aarp'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1998'));
    await tester.pumpAndSettle();

    // Tap the puzzle entry - this should set selected id and navigate.
    await tester.tap(find.text(descriptor.title));
    await tester.pumpAndSettle();

    // The fake loader should have been called with the asset path used by
    // the app. With the fix we expect the indexed path (no fallback).
    final observed = await captured.future;

    // The loader receives the full asset key used for rootBundle, which is
    // `assets/data/<relative_path>`.
    final expected = 'assets/data/${descriptor.path}';
    expect(observed, equals(expected));
  });
}

class _CrosswordPlaceholder extends ConsumerWidget {
  const _CrosswordPlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(puzzleLoaderProvider);
    return Scaffold(
      body: Center(
        child: async.when(
          data: (_) => const Text('loaded'),
          loading: CircularProgressIndicator.new,
          error: (e, _) => Text('err:$e'),
        ),
      ),
    );
  }
}
