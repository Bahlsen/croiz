import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/puzzles/widgets/puzzle_list_widgets.dart';
import 'package:croiz/core/responsive/responsive.dart';

/// Displays all packaged puzzles and navigates with a short `id` token.
class PuzzlesListPage extends ConsumerWidget {
  const PuzzlesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.puzzles ?? 'Puzzles',
          style: TextStyle(fontSize: ResponsiveFontSize.titleMedium),
        ),
      ),
      backgroundColor: isLight
          ? Colors.white
          : Theme.of(context).scaffoldBackgroundColor,
      body: _buildList(context, ref),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref) {
    final legacyAsync = ref.watch(puzzlesProvider);
    if (legacyAsync is AsyncData<List<PuzzleDescriptor>>) {
      // Tests may override the legacy provider; prefer it when already available.
      return _buildFromItems(ref, legacyAsync.value);
    }

    final originsAsync = ref.watch(puzzleOriginsProvider);
    return originsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(
        child: Text(
          AppLocalizations.of(context)?.errorLoading ?? 'Error loading puzzle',
        ),
      ),
      data: (origins) {
        final originKeys = List.of(origins)..sort();
        return ListView.separated(
          itemCount: originKeys.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, oi) =>
              LazyOriginExpansionTile(origin: originKeys[oi]),
        );
      },
    );
  }

  Widget _buildFromItems(WidgetRef ref, List<PuzzleDescriptor> items) {
    // Group by origin then by year
    final groups = <String, Map<String, List<PuzzleDescriptor>>>{};
    for (final p in items) {
      final byOrigin = groups.putIfAbsent(p.origin, () => {});
      final y = p.year.isNotEmpty ? p.year : 'unknown';
      byOrigin.putIfAbsent(y, () => <PuzzleDescriptor>[]).add(p);
    }

    final originKeys = List.of(groups.keys)..sort();
    if (originKeys.isEmpty) {
      // Defensive debug info to help tests diagnose missing groups.
      // This should not execute in normal operation when items are provided.
      // Keep as debug-only to avoid polluting release logs.
      // ignore: avoid_print
      debugPrint(
        'PuzzlesListPage: _buildFromItems groups empty for items count=${items.length}',
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: originKeys.length,
      itemBuilder: (context, oi) {
        final origin = originKeys[oi];
        return OriginGroupExpansionTile(
          origin: origin,
          puzzlesByYear: groups[origin]!,
        );
      },
    );
  }
}
