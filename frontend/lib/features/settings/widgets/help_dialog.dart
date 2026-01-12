import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/core/responsive/responsive.dart';

/// Help dialog explaining how to play the crossword game
class HelpDialog extends ConsumerWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveOverlay.dialogWidth,
          maxHeight: 85.h,
        ),
        padding: EdgeInsets.all(ResponsivePadding.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: theme.colorScheme.primary,
                  size: ResponsiveIconSize.lg,
                ),
                SizedBox(width: ResponsiveSpacing.sm),
                Expanded(
                  child: Text(
                    l10n?.help ?? 'How to Play',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveFontSize.headlineSmall,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: ResponsiveSpacing.md),
            const Divider(),
            SizedBox(height: ResponsiveSpacing.md),

            // Content
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      context,
                      title: l10n?.howToPlayBasics ?? 'Basics',
                      icon: Icons.lightbulb_outline,
                      items: [
                        l10n?.helpBasic1 ??
                            'Tap a cell to select it and see the clue',
                        l10n?.helpBasic2 ??
                            'Type letters using the on-screen keyboard or your device keyboard',
                        l10n?.helpBasic3 ??
                            'Tap the selected cell again to switch between across/down',
                        l10n?.helpBasic4 ??
                            'Completed words turn green automatically',
                      ],
                    ),
                    SizedBox(height: ResponsiveSpacing.lg),

                    _buildSection(
                      context,
                      title: l10n?.controls ?? 'Controls',
                      icon: Icons.touch_app_outlined,
                      items: [
                        l10n?.helpControl1 ?? 'Tap cells to navigate the grid',
                        l10n?.helpControl2 ??
                            'Use arrow buttons to move between cells',
                        l10n?.helpControl3 ??
                            'Backspace deletes the current letter',
                        l10n?.helpControl4 ?? 'Menu button (⋮) opens settings',
                      ],
                    ),
                    SizedBox(height: ResponsiveSpacing.lg),

                    _buildSection(
                      context,
                      title: l10n?.features ?? 'Features',
                      icon: Icons.star_outline,
                      items: [
                        l10n?.helpFeature1 ??
                            '🔍 Reveal: Show letters for a word or the entire puzzle',
                        l10n?.helpFeature2 ??
                            '🔄 Reset: Clear all your answers and start over',
                        l10n?.helpFeature3 ??
                            '🎨 Themes: Switch between light and dark mode',
                        l10n?.helpFeature4 ??
                            '🌍 Languages: Play puzzles in multiple languages',
                        l10n?.helpFeature5 ??
                            '✨ Generate: Create custom puzzles with AI',
                      ],
                    ),
                    SizedBox(height: ResponsiveSpacing.lg),

                    _buildSection(
                      context,
                      title: l10n?.tips ?? 'Tips',
                      icon: Icons.tips_and_updates_outlined,
                      items: [
                        l10n?.helpTip1 ??
                            'Start with shorter words - they\'re usually easier',
                        l10n?.helpTip2 ??
                            'Look for common letter patterns and word endings',
                        l10n?.helpTip3 ??
                            'Use crossing words to help solve difficult clues',
                        l10n?.helpTip4 ??
                            'Your progress is saved automatically',
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: ResponsiveIconSize.sm,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: ResponsiveSpacing.xs),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveSpacing.sm),
        ...items.map(
          (item) => Padding(
            padding: EdgeInsets.only(
              left: ResponsivePadding.md,
              bottom: ResponsiveSpacing.xs,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•  ',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(child: Text(item, style: theme.textTheme.bodyLarge)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
