import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/core/responsive/responsive.dart';

/// A single puzzle list item that handles navigation to the crossword screen.
class PuzzleListTile extends ConsumerWidget {
  const PuzzleListTile({
    required this.title,
    required this.puzzleId,
    super.key,
    this.subtitle,
    this.trailing = const Icon(Icons.chevron_right),
    this.isLoading = false,
    this.hasError = false,
  });

  final String title;
  final String puzzleId;
  final String? subtitle;
  final Widget trailing;
  final bool isLoading;
  final bool hasError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var effectiveTrailing = trailing;
    var effectiveSubtitle = subtitle;

    if (isLoading) {
      effectiveTrailing = SizedBox(
        width: ResponsiveIconSize.md,
        height: ResponsiveIconSize.md,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
      effectiveSubtitle = AppLocalizations.of(context)?.loading ?? 'Loading...';
    } else if (hasError) {
      effectiveTrailing = Icon(
        Icons.error,
        color: Theme.of(context).colorScheme.error,
        size: ResponsiveIconSize.md,
      );
      effectiveSubtitle =
          AppLocalizations.of(context)?.errorLoading ??
          'Error loading metadata';
    }

    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: ResponsiveFontSize.bodyLarge),
      ),
      subtitle: effectiveSubtitle != null && effectiveSubtitle.isNotEmpty
          ? Text(
              effectiveSubtitle,
              style: TextStyle(fontSize: ResponsiveFontSize.bodySmall),
            )
          : null,
      trailing: effectiveTrailing,
      onTap: () {
        ref.read(selectedPuzzleIdProvider.notifier).setSelected(puzzleId);
        final encodedId = Uri.encodeComponent(puzzleId);
        context.go('/crossword?id=$encodedId');
      },
    );
  }
}

/// A list tile that loads metadata asynchronously before displaying.
class MetadataLoadingPuzzleTile extends ConsumerWidget {
  const MetadataLoadingPuzzleTile({required this.descriptor, super.key});

  final PuzzleDescriptor descriptor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = descriptor.path.split('/').last.replaceAll('.json', '');

    // If title differs from token, we already have metadata
    if (descriptor.title != token) {
      return PuzzleListTile(
        title: descriptor.title,
        puzzleId: descriptor.id,
        subtitle: descriptor.subtitle.isNotEmpty ? descriptor.subtitle : null,
      );
    }

    // Otherwise, fetch full metadata
    final meta = ref.watch(puzzleMetadataProvider(descriptor.path));
    return meta.when(
      loading: () => PuzzleListTile(
        title: descriptor.title,
        puzzleId: token,
        isLoading: true,
      ),
      error: (_, _) => PuzzleListTile(
        title: descriptor.title,
        puzzleId: token,
        hasError: true,
      ),
      data: (full) => PuzzleListTile(
        title: full.title,
        puzzleId: full.id,
        subtitle: full.subtitle.isNotEmpty ? full.subtitle : null,
      ),
    );
  }
}

/// Groups puzzles by year within an origin.
class YearGroupExpansionTile extends StatelessWidget {
  const YearGroupExpansionTile({
    required this.year,
    required this.puzzles,
    super.key,
  });

  final String year;
  final List<PuzzleDescriptor> puzzles;

  @override
  Widget build(BuildContext context) {
    final sortedPuzzles = List.of(puzzles)
      ..sort((a, b) => a.title.compareTo(b.title));

    return ExpansionTile(
      title: Padding(
        padding: EdgeInsets.symmetric(vertical: ResponsivePadding.xs),
        child: Text(
          year,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: ResponsiveFontSize.bodySmall,
          ),
        ),
      ),
      initiallyExpanded: false,
      children: sortedPuzzles
          .map((p) => MetadataLoadingPuzzleTile(descriptor: p))
          .toList(),
    );
  }
}

/// Groups puzzles by origin, then by year.
class OriginGroupExpansionTile extends ConsumerWidget {
  const OriginGroupExpansionTile({
    required this.origin,
    required this.puzzlesByYear,
    super.key,
  });

  final String origin;
  final Map<String, List<PuzzleDescriptor>> puzzlesByYear;

  /// Sort years descending (newest first).
  static List<String> sortYears(Iterable<String> years) =>
      years.toList()..sort((a, b) {
        final ai = int.tryParse(a) ?? -9999;
        final bi = int.tryParse(b) ?? -9999;
        return bi.compareTo(ai);
      });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yearKeys = sortYears(puzzlesByYear.keys);

    return ExpansionTile(
      title: Text(
        origin,
        style: TextStyle(fontSize: ResponsiveFontSize.bodyLarge),
      ),
      initiallyExpanded: false,
      children: yearKeys
          .map(
            (year) => YearGroupExpansionTile(
              year: year,
              puzzles: puzzlesByYear[year]!,
            ),
          )
          .toList(),
    );
  }
}

/// An origin tile that loads its puzzle index lazily on expansion.
class LazyOriginExpansionTile extends ConsumerWidget {
  const LazyOriginExpansionTile({required this.origin, super.key});

  final String origin;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ExpansionTile(
    title: Text(
      origin,
      style: TextStyle(fontSize: ResponsiveFontSize.bodyLarge),
    ),
    children: [
      Consumer(
        builder: (context, ref2, _) {
          final idx = ref2.watch(originIndexProvider(origin));
          return idx.when(
            loading: () => Padding(
              padding: EdgeInsets.all(ResponsivePadding.xl),
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => Padding(
              padding: EdgeInsets.all(ResponsivePadding.md),
              child: Text(
                AppLocalizations.of(context)?.errorLoading ?? 'Error loading',
                style: TextStyle(fontSize: ResponsiveFontSize.bodyMedium),
              ),
            ),
            data: (items) {
              final years = _groupByYear(items);
              final yearKeys = OriginGroupExpansionTile.sortYears(years.keys);
              return Column(
                children: yearKeys
                    .map(
                      (year) => YearGroupExpansionTile(
                        year: year,
                        puzzles: years[year]!,
                      ),
                    )
                    .toList(),
              );
            },
          );
        },
      ),
    ],
  );

  Map<String, List<PuzzleDescriptor>> _groupByYear(
    List<PuzzleDescriptor> items,
  ) {
    final years = <String, List<PuzzleDescriptor>>{};
    for (final p in items) {
      final y = p.year.isNotEmpty ? p.year : 'unknown';
      years.putIfAbsent(y, () => []).add(p);
    }
    return years;
  }
}
