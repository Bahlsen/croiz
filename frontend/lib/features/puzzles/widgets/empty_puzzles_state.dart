import 'package:croiz/core/config/feature_flags.dart';
import 'package:croiz/features/generation/widgets/generation_dialog.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

class EmptyPuzzlesState extends ConsumerWidget {
  const EmptyPuzzlesState({
    super.key,
    this.isNoResults = false,
    this.onClearFilters,
  });

  /// If true, indicates puzzles exist but were filtered out.
  /// If false, indicates no puzzles exist in the database/assets.
  final bool isNoResults;

  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final icon =
        isNoResults ? Icons.search_off_rounded : Icons.extension_off_rounded;
    final title =
        isNoResults
            ? (l10n?.noResults ?? 'No puzzles found')
            : (l10n?.zeroPuzzles ?? 'No puzzles yet');
    final desc =
        isNoResults
            ? (l10n?.noResultsDesc ?? 'Try adjusting your search or filters.')
            : (l10n?.zeroPuzzlesDesc ??
                'Generate your first crossword to start playing!');

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 8.h,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            desc,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          if (!isNoResults && FeatureFlags.isGenerationEnabled)
            FilledButton.icon(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (context) => const GenerationDialog(),
                );
              },
              icon: const Icon(Icons.auto_awesome),
              label: Text(l10n?.generateFirst ?? 'Get Started'),
            )
          else if (isNoResults && onClearFilters != null)
            OutlinedButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.filter_list_off),
              label: Text(l10n?.clearFilters ?? 'Clear filters'),
            ),
        ],
      ),
    );
  }
}
